//
//  LHRopeJointNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 27/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHRopeJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "LHAsset.h"
#import "NSDictionary+LHDictionary.h"
#import "LHDrawNode.h"
#import "CCTexture_Private.h"

#import "LHConfig.h"
#import "LHGameWorldNode.h"

#if LH_USE_BOX2D
#include "Box2d/Box2D.h"

#else//chipmunk

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

#import "CCPhysics+ObjectiveChipmunk.h"

#pragma clang diagnostic pop

#endif //LH_USE_BOX2D

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix:(BOOL)keep2x;
@end


double bisection(double g0, double g1, double epsilon,
                 double (*fp)(double, void *), void *data)
{
    if(!data)return 0;
    
    double v0, v1, g, v;
    v0 = fp(g0, data);
    v1 = fp(g1, data);
    
    while(fabs(g1-g0) > fabs(epsilon)){
        g = (g0+g1)/2.0;
        v = fp(g, data);
        if(v == 0.0)
            return g;
        else if(v*v0 < 0.0){
            g1 = g;   v1 = v;
        } else {
            g0 = g;   v0 = v;
        }
    }
    
    return (g0+g1)/2.0;
}

double f(double x, void *data)
{
    if(!data)return 0;
    double *input = (double *)data;
    double secondTerm, delX, delY, L;
    delX  = input[2] - input[0];
    delY  = input[3] - input[1];
    L     = input[4];
    secondTerm = sqrt(L*L - delY*delY)/delX;
    
    return (sinh(x)/x -secondTerm);
}

/* f(x) = y0 + A*(cosh((x-x0)/A) - 1) */
double fcat(double x, void *data)
{
    if(!data)return 0;
    
    double x0, y0, A;
    double *input = (double *)data;
    x0  = input[0];
    y0  = input[1];
    A   = input[2];
    
    return y0 + A*(cosh((x-x0)/A) - 1.0);
}



@implementation LHRopeJointNode
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    LHJointNodeProtocolImp* _jointProtocolImp;
    
    int     _segments;
    CGRect  _colorInfo;
    BOOL    _canBeCut;
    BOOL    _removeAfterCut;
    float   _alphaValue;
    float   _thickness;
    float   _fadeOutDelay;
    float   _length;
    float   _vRepetitions;
    float   _uRepetitions;
    
    LHDrawNode* __weak ropeShape; //nil if rope is not draw
    
    LHDrawNode* __weak cutAShapeNode;
    LHDrawNode* __weak cutBShapeNode;
    
#if LH_USE_BOX2D
    b2RopeJoint* cutJointA;
    b2RopeJoint* cutJointB;
    b2Body* cutBodyA;
    b2Body* cutBodyB;
    
#else//chipmunk
    CCPhysicsJoint* __weak cutJointA;
    CCPhysicsJoint* __weak cutJointB;
#endif
    
    float cutJointALength;
    float cutJointBLength;
    NSTimeInterval cutTimer;
    BOOL wasCutAndDestroyed;
}

-(void)dealloc{

    ropeShape = nil;

    cutAShapeNode = nil;
    cutBShapeNode = nil;
    
#if LH_USE_BOX2D
    
#else//chipmunk
    cutJointA = nil;
    cutJointB = nil;
#endif
    
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict parent:prnt]);
}

-(instancetype)initWithDictionary:(NSDictionary*)dict
                               parent:(CCNode*)prnt
{
    if(self = [super init]){
     
        [prnt addChild:self];
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        

        _jointProtocolImp= [[LHJointNodeProtocolImp alloc] initJointProtocolImpWithDictionary:dict
                                                                                         node:self];

        
        _thickness = [dict floatForKey:@"thickness"];
        _segments = [dict intForKey:@"segments"];
        
        _canBeCut = [dict boolForKey:@"canBeCut"];
        _fadeOutDelay = [dict floatForKey:@"fadeOutDelay"];
        _removeAfterCut = [dict boolForKey:@"removeAfterCut"];
        
        if([dict boolForKey:@"shouldDraw"])
        {
            LHDrawNode* shape = [LHDrawNode node];
            [self addChild:shape];
            ropeShape = shape;
            
            NSString* imgRelPath = [dict objectForKey:@"relativeImagePath"];
            if(imgRelPath && [dict boolForKey:@"useTexture"]){
                LHScene* scene = (LHScene*)[prnt scene];
                
                NSString* filename = [imgRelPath lastPathComponent];
                NSString* foldername = [[imgRelPath stringByDeletingLastPathComponent] lastPathComponent];
                
                NSString* imagePath = [LHUtils imagePathWithFilename:filename
                                                              folder:foldername
                                                              suffix:[scene currentDeviceSuffix:NO]];
                
                CCTexture* texture = [scene textureWithImagePath:imagePath];
                
                ropeShape.texture = texture;
                ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
                [texture setTexParameters: &texParams];
            }
        }
        _colorInfo = [dict rectForKey:@"colorOverlay"];
        _colorInfo.size.height = [dict floatForKey:@"alpha"]/255.0f;
        _alphaValue = [dict floatForKey:@"alpha"]/255.0f;
        
        _length = [dict floatForKey:@"length"];
        
        CGPoint uvRep = [dict pointForKey:@"uvRepetitions"];
        _uRepetitions = uvRep.x;
        _vRepetitions = uvRep.y;
        
    }
    return self;
}

-(void)removeFromParent{
    
    LHScene* scene = (LHScene*)[self scene];
    if(scene)
    {
        LHGameWorldNode* pNode = [scene gameWorldNode];
        if(pNode)
        {
#if LH_USE_BOX2D
        
            //if we dont have the scene it means the scene was changed so the box2d world will be deleted, deleting the joints also - safe
            //if we do have the scene it means the node was deleted so we need to delete the joint manually
            //if we dont have the scene it means
            b2World* world = [pNode box2dWorld];
            if(world){
                if(cutJointA)
                {
                    world->DestroyJoint(cutJointA);
                    cutJointA = NULL;
                }
                if(cutBodyA){
                    world->DestroyBody(cutBodyA);
                    cutBodyA = NULL;
                }
                
                if(cutJointB)
                {
                    world->DestroyJoint(cutJointB);
                    cutJointB = NULL;
                }
                if(cutBodyB){
                    world->DestroyBody(cutBodyB);
                    cutBodyB = NULL;
                }
            }
#else //chipmunk
        
            if(cutJointA){
                [cutJointA tryRemoveFromPhysicsNode:pNode];
                cutJointA = nil;
            }
            
            if(cutJointB){
                [cutJointB tryRemoveFromPhysicsNode:pNode];
                cutJointB = nil;
            }
        
#endif
        }
    }
    
    LH_SAFE_RELEASE(_jointProtocolImp);

    [super removeFromParent];
}

-(BOOL)canBeCut{
    return _canBeCut;
}


-(void)cutWithLineFromPointA:(CGPoint)ptA
                    toPointB:(CGPoint)ptB
{
    
    if(cutJointA || cutJointB) return; //dont cut again
    if(![_jointProtocolImp joint])return;
     
    CGPoint a = [self anchorA];
    CGPoint b = [self anchorB];
     
    CGPoint relativePosA = [_jointProtocolImp localAnchorA];
    CGPoint relativePosB = [_jointProtocolImp localAnchorB];
    
    
    ptA = [self convertToNodeSpace:ptA];
    ptB = [self convertToNodeSpace:ptB];
    
    
    BOOL flipped = NO;
    NSMutableArray* rPoints = [self ropePointsFromPointA:a
                                                toPointB:b
                                              withLength:_length
                                                segments:_segments
                                                 flipped:&flipped];
    
    NSValue* prevValue = nil;
    float cutLength = 0.0f;
    for(NSValue* val in rPoints)
    {
     if(prevValue)
     {
         CGPoint ropeA = CGPointFromValue(prevValue);
         CGPoint ropeB = CGPointFromValue(val);
         
         cutLength += LHDistanceBetweenPoints(ropeA, ropeB);
         
         NSValue* interVal = LHLinesIntersection(ropeA, ropeB, ptA, ptB);

         if(interVal)
         {
             CGPoint interPt = CGPointFromValue(interVal);

             //need to destroy the joint and create 2 other joints
             if([_jointProtocolImp joint])
             {
             
                 cutTimer = [NSDate timeIntervalSinceReferenceDate];
             
                 CCNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
                 CCNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
                 
             
                 float length = _length;
             
                 [_jointProtocolImp removeJoint];
             
                 if(ropeShape)
                 {
                     LHDrawNode* shapeA = [LHDrawNode node];
                     [self addChild:shapeA];
                     cutAShapeNode = shapeA;
                     
                     LHDrawNode* shapeB = [LHDrawNode node];
                     [self addChild:shapeB];
                     cutBShapeNode = shapeB;
                     
                     cutAShapeNode.texture = ropeShape.texture;
                     cutBShapeNode.texture = ropeShape.texture;
                     
                     [ropeShape removeFromParent];
                     ropeShape = nil;
                 }
                 
                 

                 //create a new body at cut position and a joint between bodyA and this new body
                 {
                     
                    #if LH_USE_BOX2D
                     LHScene* scene = [self scene];
                     LHGameWorldNode* pNode = [scene gameWorldNode];
                     b2World* world = [pNode box2dWorld];
                     interPt = [self convertToWorldSpace:interPt];
                     b2Vec2 bodyPos = [scene metersFromPoint:interPt];
                     
                     b2BodyDef bodyDef;
                     bodyDef.type = b2_dynamicBody;
                     bodyDef.position = bodyPos;
                     cutBodyA = world->CreateBody(&bodyDef);
                     cutBodyA->SetFixedRotation(NO);
                     cutBodyA->SetGravityScale(1);
                     cutBodyA->SetSleepingAllowed(YES);
                     
                     b2FixtureDef fixture;
                     fixture.density = 1.0f;
                     fixture.friction = 0.2;
                     fixture.restitution = 0.2;
                     fixture.isSensor = YES;
                     
                     float radius = [scene metersFromValue:_thickness];
                     
                     b2Shape* shape = new b2CircleShape();
                     ((b2CircleShape*)shape)->m_radius = radius*0.5;
                     
                     if(shape){
                         fixture.shape = shape;
                         cutBodyA->CreateFixture(&fixture);
                     }
                     
                     if(shape){
                         delete shape;
                         shape = NULL;
                     }
                     
                     //create joint
                     b2RopeJointDef jointDef;
                     
                     jointDef.localAnchorA = [scene metersFromPoint:relativePosA];
                     jointDef.localAnchorB = b2Vec2(0,0);
                     
                     jointDef.bodyA = [nodeA box2dBody];// bodyA;
                     jointDef.bodyB = cutBodyA;
                     
                     if(!flipped){
                         cutJointALength = cutLength;
                     }
                     else{
                         cutJointALength = length - cutLength;
                     }
                     jointDef.maxLength = [scene metersFromValue:cutJointALength];
                     jointDef.collideConnected = [_jointProtocolImp collideConnected];
                     
                     cutJointA = (b2RopeJoint*)world->CreateJoint(&jointDef);
                     cutJointA->SetUserData(LH_VOID_BRIDGE_CAST(self));
                     
                     
                    #else //chipmunk
                     
                        CCNode* cutNodeA = [CCNode node];
                     
                         cutNodeA.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:3
                                                                            andCenter:CGPointZero];
                         cutNodeA.physicsBody.type = CCPhysicsBodyTypeDynamic;
                         cutNodeA.position = interPt;
                         cutNodeA.physicsBody.density = 0.1;
                         //                        cutBodyA.physicsBody.sensor = YES;
                         
                         CGPoint anchorA  = CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
                                                        relativePosA.y + nodeA.contentSize.height*0.5);
                         
                         [self addChild:cutNodeA];
                         
                         if(!flipped){
                             cutJointALength = cutLength;
                         }
                         else{
                             cutJointALength = length - cutLength;
                         }

                        cutJointA = [CCPhysicsJoint connectedDistanceJointWithBodyA:nodeA.physicsBody
                                                                               bodyB:cutNodeA.physicsBody
                                                                             anchorA:anchorA
                                                                             anchorB:CGPointZero
                                                                         minDistance:0
                                                                         maxDistance:cutJointALength];
                    #endif//LH_USE_BOX2D
                 }
                 
                 //create a new body at cut position and a joint between bodyB and this new body
                 {
                     
                     
                    #if LH_USE_BOX2D
                     LHScene* scene = [self scene];
                     LHGameWorldNode* pNode = [scene gameWorldNode];
                     b2World* world = [pNode box2dWorld];
                     
                     b2Vec2 bodyPos = [scene metersFromPoint:interPt];
                     b2BodyDef bodyDef;
                     bodyDef.type = b2_dynamicBody;
                     bodyDef.position = bodyPos;
                     cutBodyB = world->CreateBody(&bodyDef);
                     cutBodyB->SetFixedRotation(NO);
                     cutBodyB->SetGravityScale(1);
                     cutBodyB->SetSleepingAllowed(YES);
                     
                     b2FixtureDef fixture;
                     fixture.density = 1.0f;
                     fixture.friction = 0.2;
                     fixture.restitution = 0.2;
                     fixture.isSensor = YES;
                     
                     float radius = [scene metersFromValue:_thickness];
                     
                     b2Shape* shape = new b2CircleShape();
                     ((b2CircleShape*)shape)->m_radius = radius*0.5;
                     
                     if(shape){
                         fixture.shape = shape;
                         cutBodyB->CreateFixture(&fixture);
                     }
                     
                     if(shape){
                         delete shape;
                         shape = NULL;
                     }
                     
                     //create joint
                     b2RopeJointDef jointDef;
                     
                     jointDef.localAnchorA = b2Vec2(0,0);
                     jointDef.localAnchorB = [scene metersFromPoint:relativePosB];
                     
                     jointDef.bodyA = cutBodyB;
                     jointDef.bodyB = [nodeB box2dBody];
                     
                     if(!flipped){
                         cutJointBLength = length - cutLength;
                     }
                     else{
                         cutJointBLength = cutLength;
                     }
                     jointDef.maxLength = [scene metersFromValue:cutJointBLength];
                     
                     jointDef.collideConnected = [_jointProtocolImp collideConnected];
                     
                     cutJointB = (b2RopeJoint*)world->CreateJoint(&jointDef);
                     cutJointB->SetUserData(LH_VOID_BRIDGE_CAST(self));
                     
                    #else //chipmunk
                        CCNode* cutNodeB = [CCNode node];
                     
                         cutNodeB.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:3
                         andCenter:CGPointZero];
                         cutNodeB.physicsBody.type = CCPhysicsBodyTypeDynamic;
                         cutNodeB.position = interPt;
                         cutNodeB.physicsBody.density = 0.1;
                         //                        cutBodyB.physicsBody.sensor = YES;
                         
                         [self addChild:cutNodeB];
                         
                         if(!flipped){
                             cutJointBLength = length - cutLength;
                         }
                         else{
                             cutJointBLength = cutLength;
                         }
                         
                         CGPoint anchorB = CGPointMake(relativePosB.x + nodeB.contentSize.width*0.5,
                                               relativePosB.y + nodeB.contentSize.height*0.5);
                     
                         cutJointB = [CCPhysicsJoint connectedDistanceJointWithBodyA:cutNodeB.physicsBody
                                                                               bodyB:nodeB.physicsBody
                                                                             anchorA:CGPointZero
                                                                             anchorB:anchorB
                                                                         minDistance:0
                                                                         maxDistance:cutJointBLength];
                     
                    #endif//LH_USE_BOX2D
                     
                 }
            }
     
            [[self scene] didCutRopeJoint:self];
            return;
         }
     }
     prevValue = val;
    }
}

#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION



-(void)drawRopeShape:(LHDrawNode*)shape
             anchorA:(CGPoint)anchorA
             anchorB:(CGPoint)anchorB
              length:(float)length
            segments:(int)no_segments
{
    if(shape)
    {
        BOOL isFlipped = NO;
        NSMutableArray* rPoints = [self ropePointsFromPointA:anchorA
                                                    toPointB:anchorB
                                                  withLength:length
                                                    segments:no_segments
                                                     flipped:&isFlipped];
        
        NSMutableArray* sPoints = [self shapePointsFromRopePoints:rPoints
                                                        thickness:_thickness
                                                        isFlipped:isFlipped];
        
        
        NSValue* prevA = nil;
        NSValue* prevB = nil;
        float prevV = 0.0f;
        if(isFlipped){
            prevV = 1.0f;
        }
        
        float currentLength = 0;
        
        NSMutableArray* triangles = [NSMutableArray array];
        NSMutableArray* uvPoints = [NSMutableArray array];
        
        for(int i = 0; i < [sPoints count]; i+=2)
        {
            NSValue* valA = [sPoints objectAtIndex:i];
            NSValue* valB = [sPoints objectAtIndex:i+1];
            
            if(prevA && prevB)
            {
                CGPoint pa = CGPointFromValue(prevA);
                CGPoint a = CGPointFromValue(valA);
                
                [triangles addObject:prevA];
                [triangles addObject:valA];
                [triangles addObject:valB];

                [triangles addObject:valB];
                [triangles addObject:prevA];
                [triangles addObject:prevB];
                
                currentLength += LHDistanceBetweenPoints(pa, a);
                
                float texV = (currentLength/_length)*_vRepetitions;
                if(isFlipped){
                    texV = 1.0f - (currentLength/_length)*_vRepetitions;
                }

                [uvPoints addObject:LHValueWithCGPoint(CGPointMake(1.0f*_uRepetitions, prevV))];
                [uvPoints addObject:LHValueWithCGPoint(CGPointMake(1.0f*_uRepetitions, texV))];
                [uvPoints addObject:LHValueWithCGPoint(CGPointMake(0.0f, texV))];
                
                [uvPoints addObject:LHValueWithCGPoint(CGPointMake(0.0f, texV))];
                [uvPoints addObject:LHValueWithCGPoint(CGPointMake(1.0f*_uRepetitions, prevV))];
                [uvPoints addObject:LHValueWithCGPoint(CGPointMake(0.0f, prevV))];
                
                prevV = texV;

            }
            prevA = valA;
            prevB = valB;
        }
        
        CCColor* color  = [CCColor colorWithRed:_colorInfo.origin.x
                                          green:_colorInfo.origin.y
                                           blue:_colorInfo.size.width
                                          alpha:_alphaValue];

        
        [shape setShapeTriangles:triangles
                        uvPoints:uvPoints
                           color:color];
    }
}


-(int)gravityDirectionAngle{
    CGPoint gravityVector = [self scene].physicsNode.gravity;
    double angle1 = atan2(gravityVector.x, -gravityVector.y);
    double angle1InDegrees = (angle1 / M_PI) * 180.0;
    int finalAngle = (360 - (int)angle1InDegrees) %  360;
    return finalAngle;
}

-(NSMutableArray*)ropePointsFromPointA:(CGPoint)a
                              toPointB:(CGPoint)b
                            withLength:(float)ropeLength
                              segments:(float)numOfSegments
                               flipped:(BOOL*)flipped
{
    double data[5]; /* x1 y1 x2 y2 L */
    double constants[3];  /* x0 y0 A */
    double x0, y0, A;
    double delX, delY, guess1, guess2;
    double Q, B, K;
    double step, x;
    
    float gravityAngle = -[self gravityDirectionAngle];
    CGPoint c = CGPointMake((a.x + b.x)*0.5, (a.y + b.y)*0.5);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformTranslate(transform, c.x, c.y);
    transform = CGAffineTransformRotate(transform, gravityAngle);
    transform = CGAffineTransformTranslate(transform, -c.x, -c.y);
    

    CGPoint ar = CGPointApplyAffineTransform(a, transform);
    CGPoint br = CGPointApplyAffineTransform(b, transform);
    
    data[0] = ar.x;
    data[1] = ar.y; /* 1st point */
    data[2] = br.x;
    data[3] = br.y; /* 2nd point */
    
    BOOL ropeIsFlipped = NO;
    
    if(ar.x > br.x){
        data[2] = ar.x;
        data[3] = ar.y; /* 1st point */
        data[0] = br.x;
        data[1] = br.y; /* 2nd point */
        
        CGPoint temp = a;
        a = b;
        b = temp;
        
        ropeIsFlipped = YES;
    }
    
    if(flipped)
        *flipped = ropeIsFlipped;
    
    NSMutableArray* rPoints = [NSMutableArray array];
    
    data[4] = ropeLength;   /* string length */
    
    delX = data[2]-data[0];
    delY = data[3]-data[1];
    /* length of string should be larger than distance
     * between given points */
    if(data[4] <= sqrt(delX * delX + delY * delY)){
        data[4] = sqrt(delX * delX + delY * delY) +0.01;
    }
    
    Q = sqrt(data[4]*data[4] - delY*delY)/delX;
    
    guess1 = log(Q + sqrt(Q*Q-1.0));
    guess2 = sqrt(6.0*(Q-1.0));
    
    B = bisection(guess1, guess2, 1e-6, f, data);
    A = delX/(2*B);
    
    K = (0.5*delY/A)/sinh(0.5*delX/A);
    x0 = data[0] + delX/2.0 - A*asinh(K);
    y0 = data[1] - A*(cosh((data[0]-x0)/A) - 1.0);
    
    //x0, y0 is the lower point of the rope
    constants[0] = x0;
    constants[1] = y0;
    constants[2] = A;
    
    
    /* write curve points on output stream stdout */
    step = (data[2]-data[0])/numOfSegments;
    
    
    transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, c.x, c.y);
    transform = CGAffineTransformRotate(transform, -gravityAngle);
    transform = CGAffineTransformTranslate(transform, -c.x, -c.y);
    
    CGPoint prevPt = CGPointZero;
    x = data[0];
    for(float x= data[0]; x <  data[2]; )
    {
        CGPoint point = CGPointMake(x, fcat(x, constants));
        point = CGPointApplyAffineTransform(point, transform);
        [rPoints addObject:LHValueWithCGPoint(point)];
        if(CGPointEqualToPoint(point, prevPt)){
            break;//safety check
        }
        prevPt = point;
        x += step;
    }
    
    CGPoint lastPt = CGPointFromValue([rPoints lastObject]);
    
    if(!CGPointEqualToPoint(CGPointMake((int)b.x, (int)b.y),
                            CGPointMake((int)lastPt.x, (int)lastPt.y)))
    {
        [rPoints addObject:LHValueWithCGPoint(b)];
    }
    
    if(!ropeIsFlipped && [rPoints count] > 0){
        CGPoint firstPt = CGPointFromValue([rPoints objectAtIndex:0]);
        
        if(!CGPointEqualToPoint(CGPointMake((int)a.x, (int)a.y),
                                CGPointMake((int)firstPt.x, (int)firstPt.y)))
        {
            [rPoints insertObject:LHValueWithCGPoint(a) atIndex:0];
        }
    }
    
    return rPoints;
}

-(NSMutableArray*)shapePointsFromRopePoints:(NSArray*)rPoints
                                  thickness:(float)thick
                                  isFlipped:(BOOL)flipped
{
    NSMutableArray* shapePoints = [NSMutableArray array];
    
    bool first = true;
    bool added = false;
    NSValue* prvVal = nil;
    for(NSValue* val in rPoints){
        CGPoint pt = CGPointFromValue(val);
        
        if(prvVal)
        {
            CGPoint prevPt = CGPointFromValue(prvVal);
            
            NSArray* points = [self thickLinePointsFrom:prevPt
                                                    end:pt
                                                  width:thick];
            
            if((val == [rPoints lastObject]) && !added){
                if(flipped){
                    [shapePoints addObject:[points objectAtIndex:0]];//G
                    [shapePoints addObject:[points objectAtIndex:1]];//B
                }
                else{
                    [shapePoints addObject:[points objectAtIndex:1]];//G
                    [shapePoints addObject:[points objectAtIndex:0]];//B
                }
                added = true;
            }
            else{
                if(flipped){
                    [shapePoints addObject:[points objectAtIndex:2]];//C
                    [shapePoints addObject:[points objectAtIndex:3]];//P
                }
                else{
                    [shapePoints addObject:[points objectAtIndex:3]];//C
                    [shapePoints addObject:[points objectAtIndex:2]];//P
                }
            }
            first = false;
        }
        prvVal = val;
    }
    
    return shapePoints;
}

-(NSArray*)thickLinePointsFrom:(CGPoint)start
                           end:(CGPoint)end
                         width:(float)width
{
    float dx = start.x - end.x;
    float dy = start.y - end.y;
    
    CGPoint rightSide = CGPointMake(dy, -dx);
    if (LHPointLength(rightSide) > 0) {
        rightSide = LHPointNormalize(rightSide);
        rightSide = LHPointScaled(rightSide, width*0.5);
    }
    
    CGPoint leftSide = CGPointMake(-dy, dx);
    if (LHPointLength(leftSide) > 0) {
        leftSide = LHPointNormalize(leftSide);
        leftSide = LHPointScaled(leftSide, width*0.5);
    }
    
    CGPoint one     = LHPointAdd(leftSide, start);
    CGPoint two     = LHPointAdd(rightSide, start);
    CGPoint three   = LHPointAdd(rightSide, end);
    CGPoint four    = LHPointAdd(leftSide, end);
    
    NSMutableArray* array = [NSMutableArray array];
    
    //G+B
    [array addObject:LHValueWithCGPoint(CGPointMake(four.x, four.y))];
    [array addObject:LHValueWithCGPoint(CGPointMake(three.x, three.y))];
    
    //C+P
    [array addObject:LHValueWithCGPoint(CGPointMake(one.x, one.y))];
    [array addObject:LHValueWithCGPoint(CGPointMake(two.x, two.y))];
    
    return array;
}

- (void)visit
{
    if(![_jointProtocolImp nodeA] ||  ![_jointProtocolImp nodeB]){
        [self lateLoading];
    }
    
    CGPoint anchorA = [self anchorA];
    CGPoint anchorB = [self anchorB];
    
    if(isnan(anchorA.x) || isnan(anchorA.y) || isnan(anchorB.x) || isnan(anchorB.y)){
        return;
    }
    
    if(ropeShape){
        [self drawRopeShape:ropeShape
                    anchorA:anchorA
                    anchorB:anchorB
                     length:_length
                   segments:_segments];
    }
    
    NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
    
    if(_removeAfterCut && cutAShapeNode && cutBShapeNode){
        
        float unit = (currentTimer - cutTimer)/_fadeOutDelay;
        _alphaValue = _colorInfo.size.height;
        _alphaValue -=_alphaValue*unit;
        
        if(unit >=1){
            [self removeFromParent];
            return;
        }
    }

    if(cutAShapeNode){

#if LH_USE_BOX2D
        b2Vec2 pos      = cutBodyA->GetPosition();
        LHScene* scene  = [self scene];
        CGPoint worldPos= [scene pointFromMeters:pos];
        CGPoint B       =  [self convertToNodeSpaceAR:worldPos];
#else
        CGPoint pt = [cutJointA.bodyB.node convertToWorldSpaceAR:CGPointZero];
        CGPoint B  = [self convertToNodeSpaceAR:pt];
#endif
        [self drawRopeShape:cutAShapeNode
                    anchorA:anchorA
                    anchorB:B
                     length:cutJointALength
                   segments:_segments];
    }
    
    if(cutBShapeNode){
#if LH_USE_BOX2D
        b2Vec2 pos      = cutBodyB->GetPosition();
        LHScene* scene  = [self scene];
        CGPoint worldPos= [scene pointFromMeters:pos];
        CGPoint A       =  [self convertToNodeSpaceAR:worldPos];
#else
        CGPoint pt = [cutJointB.bodyA.node convertToWorldSpaceAR:CGPointZero];
        CGPoint A  = [self convertToNodeSpaceAR:pt];
#endif
        
        [self drawRopeShape:cutBShapeNode
                    anchorA:A
                    anchorB:anchorB
                     length:cutJointBLength
                   segments:_segments];
    }
    
    [super visit];
}

#pragma mark LHNodeProtocol Optional

-(BOOL)lateLoading
{
    [_jointProtocolImp findConnectedNodes];
    
    CCNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
    CCNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
    
    CGPoint relativePosA = [_jointProtocolImp localAnchorA];
    CGPoint relativePosB = [_jointProtocolImp localAnchorB];
    
    if(nodeA && nodeB)
    {
#if LH_USE_BOX2D

        LHScene* scene = [self scene];
        LHGameWorldNode* pNode = [scene gameWorldNode];
        b2World* world = [pNode box2dWorld];
        if(world == nil)return NO;
        
        b2Body* bodyA = [nodeA box2dBody];
        b2Body* bodyB = [nodeB box2dBody];
        
        if(!bodyA || !bodyB)return NO;
        
        b2Vec2 posA = [scene metersFromPoint:relativePosA];
        b2Vec2 posB = [scene metersFromPoint:relativePosB];
        
        b2RopeJointDef jointDef;
        
        jointDef.localAnchorA = posA;
        jointDef.localAnchorB = posB;
        
        jointDef.bodyA = bodyA;
        jointDef.bodyB = bodyB;
        
        jointDef.maxLength = [scene metersFromValue:_length];
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];
        
        b2RopeJoint* joint = (b2RopeJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];
        
#else//chipmunk
        
        if(!nodeA.physicsBody || !nodeB.physicsBody)
            return NO;
        

        CCPhysicsJoint* joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:nodeA.physicsBody
                                                                          bodyB:nodeB.physicsBody
                                                                        anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
                                                                                            relativePosA.y + nodeA.contentSize.height*0.5)
                                                                        anchorB:CGPointMake(relativePosB.x + nodeB.contentSize.width*0.5,
                                                                                            relativePosB.y + nodeB.contentSize.height*0.5)
                                                                    minDistance:0
                                                                    maxDistance:_length];
        joint.collideBodies = [_jointProtocolImp collideConnected];
        
        [_jointProtocolImp setJoint:joint];
        
#endif//LH_USE_BOX2D
        
        return true;
    }
    
    return false;
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
