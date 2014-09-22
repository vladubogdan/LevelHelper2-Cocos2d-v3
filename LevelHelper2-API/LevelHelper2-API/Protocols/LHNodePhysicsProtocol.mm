//
//  LHNodePhysicsProtocol.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 14/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHNodePhysicsProtocol.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"

#import "LHBezier.h"
#import "LHShape.h"
#import "LHNode.h"

#import "LHNodeProtocol.h"

#import "LHConfig.h"

#import "LHGameWorldNode.h"
#import "CCNode+Transform.h"
#import "LHUINode.h"
#import "LHBackUINode.h"
#import "LHAsset.h"


#if LH_USE_BOX2D

#include "Box2d/Box2D.h"
#include <vector>

#else

//#import "CCPhysics+ObjectiveChipmunk.h"

#endif //LH_USE_BOX2D


@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid;
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end

@interface LHGameWorldNode (LH_PHYSICS_PROTOCOL_CONTACT_REMOVAL)
-(void)removeScheduledContactsWithNode:(CCNode*)node;
@end

@interface LHAsset (LH_ASSET_NODES_PRIVATE_UTILS)
-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid;
@end


@implementation LHNodePhysicsProtocolImp
{
    BOOL originallySensor;
    BOOL scheduledForRemoval;
    
#if LH_USE_BOX2D
    b2Body* _body;
    CGPoint previousScale;
#endif
    __unsafe_unretained CCNode* _node;
}

-(void)dealloc{

    
#if LH_USE_BOX2D
    
    if(_body && _node && [_node respondsToSelector:@selector(isB2WorldDirty)] && ![(LHNode*)_node isB2WorldDirty])
    {
        //node at this point may not have parent so no scene also
        LHBox2dWorld* world = (LHBox2dWorld*)_body->GetWorld();
        if(world){
            LHScene* scene = (LHScene*)LH_ID_BRIDGE_CAST(world->_scene);
            if(scene){
                LHGameWorldNode* gw = [scene gameWorldNode];
                if(gw){
                    [gw removeScheduledContactsWithNode:_node];
                }
            }
        }
        
        //do not remove the body if the scene is deallocing as the box2d world will be deleted
        //so we dont need to do this manualy
        //in some cases the nodes will be retained and removed after the box2d world is already deleted and we may have a crash
        [self removeBody];
    }
#endif
    _node = nil;
        
    LH_SUPER_DEALLOC();
}

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    return LH_AUTORELEASED([[self alloc] initPhysicsProtocolImpWithDictionary:dict node:nd]);
}

-(CCNode*)node{
    return _node;
}

-(LHAsset*)assetParent{
    CCNode* p = _node;
    while(p && [p parent]){
        if([p isKindOfClass:[LHAsset class]])
            return (LHAsset*)p;
        p = [p parent];
    }
    return nil;
}

- (instancetype)initPhysicsProtocolWithNode:(CCNode*)nd
{
    if(self = [super init])
    {
        _node = nd;
        
#if LH_USE_BOX2D
        _body = NULL;
#endif
        
    }
    return self;
}

#if LH_USE_BOX2D

#pragma mark - BOX2D SUPPORT

-(void)setupFixture:(b2FixtureDef*)fixture withInfo:(NSDictionary*)fixInfo
{
    fixture->density     = [fixInfo floatForKey:@"density"];
    fixture->friction    = [fixInfo floatForKey:@"friction"];
    fixture->restitution = [fixInfo floatForKey:@"restitution"];
    fixture->isSensor    = [fixInfo boolForKey:@"sensor"];
    
    fixture->filter.maskBits = [fixInfo intForKey:@"mask"];
    fixture->filter.categoryBits = [fixInfo intForKey:@"category"];
}

- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dictionary node:(CCNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;
        _body = NULL;
        
        NSDictionary* dict = [dictionary objectForKey:@"nodePhysics"];
        
        if(!dict){
            return self;
        }
        
        int shapeType = [dict intForKey:@"shape"];
        int type = [dict intForKey:@"type"];
        
        LHScene* scene = (LHScene*)[_node scene];
        b2World* world = [scene box2dWorld];
        
        b2BodyDef bodyDef;
        bodyDef.type = (b2BodyType)type;
        
        CGPoint position = [_node convertToWorldSpaceAR:CGPointZero];
        b2Vec2 bodyPos = [scene metersFromPoint:position];
        bodyDef.position = bodyPos;

        float angle = [_node globalAngleFromLocalAngle:[_node rotation]];
        bodyDef.angle = CC_DEGREES_TO_RADIANS(-angle);
        
        bodyDef.userData = LH_VOID_BRIDGE_CAST(_node);
        
        _body = world->CreateBody(&bodyDef);
        _body->SetUserData(LH_VOID_BRIDGE_CAST(_node));

        _body->SetFixedRotation([dict boolForKey:@"fixedRotation"]);
        _body->SetGravityScale([dict floatForKey:@"gravityScale"]);

        _body->SetSleepingAllowed([dict boolForKey:@"allowSleep"]);
        _body->SetBullet([dict boolForKey:@"bullet"]);
        
        if([dict objectForKey:@"angularDamping"])//all this properties were added in the same moment
        {
            _body->SetAngularDamping([dict floatForKey:@"angularDamping"]);
            
            _body->SetAngularVelocity([dict floatForKey:@"angularVelocity" ]);//radians/second.
            
            _body->SetLinearDamping([dict floatForKey:@"linearDamping"]);
            
            CGPoint linearVel = [dict pointForKey:@"linearVelocity"];
            _body->SetLinearVelocity(b2Vec2(linearVel.x,linearVel.y));
        }
        
        CGSize sizet = [_node contentSize];
        sizet.width  = [scene metersFromValue:sizet.width];
        sizet.height = [scene metersFromValue:sizet.height];
        
        CGPoint scale = CGPointMake(_node.scaleX, _node.scaleY);
        scale = [_node convertToWorldScale:scale];
        
        previousScale = scale;
        
        sizet.width *= scale.x;
        sizet.height*= scale.y;
        
        b2FixtureDef fixture;
        
        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
        if(fixInfo && _body)
        {
            [self setupFixture:&fixture withInfo:fixInfo];
        }

        
        b2Shape* shape= NULL;

//        NSMutableArray* fixShapes = [NSMutableArray array];
        NSArray* fixturesInfo = nil;
        
        if(shapeType == 0)//RECTANGLE
        {
            shape = new b2PolygonShape();
            ((b2PolygonShape*)shape)->SetAsBox(sizet.width*0.5f, sizet.height*0.5f);
        }
        else if(shapeType == 1)//CIRCLE
        {
            shape = new b2CircleShape();
            ((b2CircleShape*)shape)->m_radius = sizet.width*0.5;
        }
        else if(shapeType == 3)//CHAIN
        {
            if([_node isKindOfClass:[LHBezier class]])
            {
                NSMutableArray* points = [(LHBezier*)_node linePoints];
                
                std::vector< b2Vec2 > verts;
                
                NSValue* lastPt = nil;
                
                for(NSValue* val in points){
                    CGPoint pt = CGPointFromValue(val);
                    pt.x *= scale.x;
                    pt.y *= scale.y;
                    

                    b2Vec2 v2 = [scene metersFromPoint:pt];
                    
                    if(lastPt != nil)
                    {
                        CGPoint oldPt = CGPointFromValue(lastPt);
                        b2Vec2 v1 = b2Vec2(oldPt.x, oldPt.y);
                        
                        if(b2DistanceSquared(v1, v2) > b2_linearSlop * b2_linearSlop)
                        {
                            verts.push_back(v2);
                        }
                    }
                    else{
                        verts.push_back(v2);
                    }
                    
                    lastPt = LHValueWithCGPoint(CGPointMake(v2.x, v2.y));
                    
                }
                
                shape = new b2ChainShape();
                ((b2ChainShape*)shape)->CreateChain (&(verts.front()), (int)verts.size());
            }
        }
        else if(shapeType == 4)//OVAL
        {
            fixturesInfo = [dict objectForKey:@"ovalShape"];
        }
        else if(shapeType == 5)//TRACED
        {
            NSString* fixUUID = [dict objectForKey:@"fixtureUUID"];
            LHScene* scene = (LHScene*)[_node scene];
            fixturesInfo = [scene tracedFixturesWithUUID:fixUUID];
            if(!fixturesInfo){
                LHAsset* asset = [self assetParent];
                if(asset){
                    fixturesInfo = [asset tracedFixturesWithUUID:fixUUID];
                }
            }
        }
        else if(shapeType == 2)//POLYGON
        {
            if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* trianglePoints = [(LHShape*)_node trianglePoints];
                
                for(int i = 0; i < [trianglePoints count]; i+=3)
                {
                    NSValue* valA = [trianglePoints objectAtIndex:i];
                    NSValue* valB = [trianglePoints objectAtIndex:i+1];
                    NSValue* valC = [trianglePoints objectAtIndex:i+2];
                    
                    CGPoint ptA = CGPointFromValue(valA);
                    CGPoint ptB = CGPointFromValue(valB);
                    CGPoint ptC = CGPointFromValue(valC);
                    
                    ptA.x *= scale.x;
                    ptA.y *= scale.y;

                    ptB.x *= scale.x;
                    ptB.y *= scale.y;

                    ptC.x *= scale.x;
                    ptC.y *= scale.y;

                    b2Vec2 *verts = new b2Vec2[3];
                    
                    verts[2] = [scene metersFromPoint:ptA];
                    verts[1] = [scene metersFromPoint:ptB];
                    verts[0] = [scene metersFromPoint:ptC];
                    
                    b2PolygonShape shapeDef;
                    
                    shapeDef.Set(verts, 3);
                    
                    b2FixtureDef fixture;
                    
                    [self setupFixture:&fixture withInfo:fixInfo];
                    
                    fixture.shape = &shapeDef;
                    _body->CreateFixture(&fixture);
                    delete[] verts;
                }
            }
        }
        
        if(fixturesInfo)
        {
            int flipx = scale.x < 0 ? -1 : 1;
            int flipy = scale.y < 0 ? -1 : 1;
            
            for(NSArray* fixPoints in fixturesInfo)
            {
                int count = (int)[fixPoints count];
                if(count > 2)
                {
                    b2Vec2 *verts = new b2Vec2[count];
                    b2PolygonShape shapeDef;
                    
                    int i = 0;
                    for(int j = count-1; j >=0; --j)
                    {
                        const int idx = (flipx < 0 && flipy >= 0) || (flipx >= 0 && flipy < 0) ? count - i - 1 : i;
                        
                        NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                        CGPoint point = LHPointFromString(pointStr);
                        point.x *= scale.x;
                        point.y *= scale.y;
                        
                        point.y = -point.y;
                        
                        verts[idx] = [scene metersFromPoint:point];
                        ++i;
                    }
                    
                    
                    if([self validCentroid:verts count:count])
                    {
                        shapeDef.Set(verts, count);
                        b2FixtureDef fixture;
                        [self setupFixture:&fixture withInfo:fixInfo];                        
                        fixture.shape = &shapeDef;
                        _body->CreateFixture(&fixture);
                    }
                    
                    delete[] verts;
                }
            }
            
        }
        
        if(shape){
            fixture.shape = shape;
            _body->CreateFixture(&fixture);
        }
        
        if(shape){
            delete shape;
            shape = NULL;
        }
    }
    
    return self;
}

-(b2Body*)body{
    return _body;
}

-(int)bodyType{
    if(_body){
        return (int)_body->GetType();
    }
    return (int)LH_NO_PHYSICS;
}
-(void)setBodyType:(int)type{
    if(_body){
        if(type != LH_NO_PHYSICS)
        {
            _body->SetActive(true);
            _body->SetType((b2BodyType)type);
        }
        else{
            _body->SetType((b2BodyType)0);
            _body->SetActive(false);
        }
        //for no physics - we should do something else
    }
}

-(NSArray*) jointList{
    NSMutableArray* array = [NSMutableArray array];
    if(_body != NULL){
        b2JointEdge* jtList = _body->GetJointList();
        while (jtList) {
            if(jtList->joint && jtList->joint->GetUserData())
            {
                CCNode* ourNode = (LHNode*)LH_ID_BRIDGE_CAST(jtList->joint->GetUserData());
                if(ourNode != NULL)
                    [array addObject:ourNode];
                }
            jtList = jtList->next;
        }
    }
    return array;
}
-(bool) removeAllAttachedJoints{
    NSArray* list = [self jointList];
    if(list){
        for(CCNode* jt in list){
            [jt removeFromParent];
        }
        return true;
    }
    return false;
}


-(void)removeBody{
    
    if(_body){
        b2World* world = _body->GetWorld();
        if(world){
            _body->SetUserData(NULL);
            if(!world->IsLocked()){
                [self removeAllAttachedJoints];
                world->DestroyBody(_body);
                _body = NULL;
                scheduledForRemoval = false;
            }
            else{
                scheduledForRemoval = true;
            }
        }
    }
}

-(void)visit{
    if(_body && scheduledForRemoval){
        [self removeBody];
    }
    
    if(_body){
        CGAffineTransform trans = b2BodyToParentTransform(_node, self);
        CGPoint localPos = CGPointApplyAffineTransform([_node anchorPointInPoints], trans);
        [((LHNode*)_node) updatePosition:localPos];
        [((LHNode*)_node) updateRotation:[_node localAngleFromGlobalAngle:CC_RADIANS_TO_DEGREES(-_body->GetAngle())]];
    }
}


static inline CGAffineTransform b2BodyToParentTransform(CCNode *node, LHNodePhysicsProtocolImp *physicsImp)
{
	return CGAffineTransformConcat(physicsImp.absoluteTransform, CGAffineTransformInvert(NodeToB2BodyTransform(node.parent)));
}
static inline CGAffineTransform NodeToB2BodyTransform(CCNode *node)
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	for(CCNode *n = node; n && ![n isKindOfClass:[LHGameWorldNode class]]
                            && ![n isKindOfClass:[LHBackUINode class]]
                            && ![n isKindOfClass:[LHUINode class]];
        n = n.parent){
		transform = CGAffineTransformConcat(transform, n.nodeToParentTransform);
	}
	return transform;
}

- (CGAffineTransform)nodeTransform
{
    if([self body]){
        CGAffineTransform rigidTransform = b2BodyToParentTransform(_node, self);
		return CGAffineTransformConcat(CGAffineTransformMakeScale([_node scaleX], [_node scaleY]), rigidTransform);
    }
    return CGAffineTransformIdentity;//should never get here
}

-(CGAffineTransform)absoluteTransform {
    CGAffineTransform transform = CGAffineTransformIdentity;
    LHScene* scene = (LHScene*)[_node scene];
    b2Vec2 b2Pos = [self body]->GetPosition();
    CGPoint globalPos = [scene pointFromMeters:b2Pos];

    transform = CGAffineTransformTranslate(transform, globalPos.x, globalPos.y);
    transform = CGAffineTransformRotate(transform, [self body]->GetAngle());

    transform = CGAffineTransformTranslate(transform, - _node.contentSize.width*0.5, - _node.contentSize.height*0.5);

	return transform;
}

-(void)updateTransform
{
    if([self body])
    {
        CGPoint worldPos = [[_node parent] convertToWorldSpace:[_node position]];
        worldPos = [[(LHScene*)[_node scene] gameWorldNode] convertToNodeSpace:worldPos];
        CGPoint gWPos = [[(LHScene*)[_node scene] gameWorldNode] position];
        
        worldPos = CGPointMake(worldPos.x - gWPos.x,
                               worldPos.y - gWPos.y);
        
        b2Vec2 b2Pos = [(LHScene*)[_node scene] metersFromPoint:worldPos];
        _body->SetTransform(b2Pos, CC_DEGREES_TO_RADIANS(-[_node globalAngleFromLocalAngle:[_node rotation]]));
        _body->SetAwake(true);
    }
}
-(BOOL) validCentroid:(b2Vec2*)vs count:(int)count
{
    if(count < 3 || count > b2_maxPolygonVertices)
        return false;
    
	int32 n = b2Min(count, b2_maxPolygonVertices);
    
	// Perform welding and copy vertices into local buffer.
	b2Vec2 ps[b2_maxPolygonVertices];
	int32 tempCount = 0;
	for (int32 i = 0; i < n; ++i)
	{
		b2Vec2 v = vs[i];
        
		bool unique = true;
		for (int32 j = 0; j < tempCount; ++j)
		{
			if (b2DistanceSquared(v, ps[j]) < 0.5f * b2_linearSlop)
			{
				unique = false;
				break;
			}
		}
        
		if (unique)
		{
			ps[tempCount++] = v;
		}
	}
    
	n = tempCount;
	if (n < 3)
	{
        return false;
	}
    
    return true;
}

-(void)updateScale{
    
    if(_body){
        
        float scaleX = [_node scaleX];
        float scaleY = [_node scaleY];
        
        CGPoint globalScale = [_node convertToWorldScale:CGPointMake(scaleX, scaleY)];
        scaleX = globalScale.x;
        scaleY = globalScale.y;
        
        if(previousScale.x == scaleX && previousScale.y == scaleY){
            return;
        }
        
        if(scaleX < 0.01 && scaleX > -0.01){
            NSLog(@"WARNING - SCALE Y value CANNOT BE 0 - BODY WILL NOT GET SCALED.");
            return;
        }

        if(scaleY < 0.01 && scaleY > -0.01){
            NSLog(@"WARNING - SCALE X value CANNOT BE 0 - BODY WILL NOT GET SCALED.");
            return;
        }

        b2Fixture* fix = _body->GetFixtureList();
        while (fix) {
            
            b2Shape* shape = fix->GetShape();
            
            int flipx = scaleX < 0 ? -1 : 1;
            int flipy = scaleY < 0 ? -1 : 1;
            
            if(shape->GetType() == b2Shape::e_polygon)
            {
                b2PolygonShape* polShape = (b2PolygonShape*)shape;
                int32 count = polShape->GetVertexCount();
                
                b2Vec2* newVertices = new b2Vec2[count];
                
                for(int i = 0; i < count; ++i)
                {
                    const int idx = (flipx < 0 && flipy >= 0) || (flipx >= 0 && flipy < 0) ? count - i - 1 : i;
                    
                    b2Vec2 pt = polShape->GetVertex(i);
                    
                    if(scaleX - previousScale.x != 0)
                    {
                        pt.x /= previousScale.x;
                        pt.x *= scaleX;
                    }

                    if(scaleY - previousScale.y)
                    {
                        pt.y /= previousScale.y;
                        pt.y *= scaleY;
                    }
                    
                    newVertices[idx] = pt;
                }
                
                BOOL valid = [self validCentroid:newVertices count:count];
                if(!valid) {
                    //flip
                    b2Vec2* flippedVertices = new b2Vec2[count];
                    for(int i = 0; i < count; ++i)
                    {
                        flippedVertices[i] = newVertices[count - i - 1];
                    }
                    delete[] newVertices;
                    newVertices = flippedVertices;
                }
                
                polShape->Set(newVertices, count);
                delete[] newVertices;
            }
            
            if(shape->GetType() == b2Shape::e_circle)
            {
                b2CircleShape* circleShape = (b2CircleShape*)shape;
                float radius = circleShape->m_radius;
                
                float newRadius = radius/previousScale.x*scaleX;
                circleShape->m_radius = newRadius;
            }
            
            
            if(shape->GetType() == b2Shape::e_edge)
            {
                b2EdgeShape* edgeShape = (b2EdgeShape*)shape;
#pragma unused (edgeShape)
                NSLog(@"EDGE SHAPE");
            }
            
            if(shape->GetType() == b2Shape::e_chain)
            {
                b2ChainShape* chainShape = (b2ChainShape*)shape;
                
                b2Vec2* vertices = chainShape->m_vertices;
                int32 count = chainShape->m_count;
                
                for(int i = 0; i < count; ++i)
                {
                    b2Vec2 pt = vertices[i];
                    b2Vec2 newPt = b2Vec2(pt.x/previousScale.x*scaleX, pt.y/previousScale.y*scaleY);
                    vertices[i] = newPt;
                }
            }
            
            
            fix = fix->GetNext();
        }
        
        previousScale = CGPointMake(scaleX, scaleY);
    }
}

#pragma mark - CHIPMUNK SUPPORT
////////////////////////////////////////////////////////////////////////////////
#else //chipmunk

-(int)bodyType{
    if([_node physicsBody]){
        if([[_node physicsBody] type] == CCPhysicsBodyTypeDynamic){
            return (int)LH_DYNAMIC_BODY;
        }
        else{
            return (int)LH_STATIC_BODY;
        }
    }
    return (int)LH_NO_PHYSICS;
}
-(void)setBodyType:(int)type{
    if([_node physicsBody]){
        
//        LHScene* scene = (LHScene*)[_node scene];
//        LHPhysicsNode* pNode = (LHPhysicsNode*)[scene physicsNode];
//        cpSpace* space = [pNode chipmunkSpace];
//        ChipmunkBody* body = [[_node physicsBody] body];
//        cpBody*  body = [[[_node physicsBody] body] body];
        
        if(type == LH_STATIC_BODY)
        {
            [[_node physicsBody] setSensor:originallySensor];
            [[_node physicsBody] setType:CCPhysicsBodyTypeStatic];
        }
        else if(type == LH_DYNAMIC_BODY || type == LH_KINEMATIC_BODY)
        {
            [[_node physicsBody] setSensor:originallySensor];
            [[_node physicsBody] setType:CCPhysicsBodyTypeDynamic];
        }
        else if(type == LH_NO_PHYSICS)
        {
            [[_node physicsBody] setSensor:YES];
            [[_node physicsBody] setType:CCPhysicsBodyTypeStatic];
            
//            ChipmunkSpace* sp = [body space];
//            [body removeFromSpace:[body space]];
//            
//            [sp reindexStatic];
            
//            - (void)addToSpace:(ChipmunkSpace *)space;
//            - (void)removeFromSpace:(ChipmunkSpace *)space;
//            if(cpSpaceContainsBody(space, body))
//            {
//                cpSpaceRemoveBody(space, body);
//            }
        }
    }
}

-(void)removeBody{
    
    if([_node physicsBody])
    {
        [_node setPhysicsBody:nil];        
    }
}

-(void)visit{
    //nothing to do for chipmunk
}

- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dictionary node:(CCNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;

        NSDictionary* dict = [dictionary objectForKey:@"nodePhysics"];
        
        if(!dict){
            return self;
        }
        
        int shape = [dict intForKey:@"shape"];
        int type = [dict intForKey:@"type"];
        
        NSMutableArray* fixShapes = [NSMutableArray array];
        
        NSArray* fixturesInfo = nil;
        
        if(shape == 0)//RECTANGLE
        {
            CGPoint offset = CGPointMake(0, 0);
            CGRect bodyRect = CGRectMake(offset.x,
                                         offset.y,
                                         _node.contentSize.width,
                                         _node.contentSize.height);
            
            _node.physicsBody = [CCPhysicsBody bodyWithRect:bodyRect cornerRadius:0];            
        }
        else if(shape == 1)//CIRCLE
        {
            CGPoint offset = CGPointMake(_node.contentSize.width*0.5,
                                         _node.contentSize.height*0.5);
            _node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:_node.contentSize.width*0.5
                                                           andCenter:offset];
        }
        else if(shape == 3)//CHAIN
        {
            if([_node isKindOfClass:[LHBezier class]])
            {
                NSMutableArray* points = [(LHBezier*)_node linePoints];
                
                NSValue* prevValue = nil;
                for(NSValue* val in points){
                    
                    if(prevValue)
                    {
                        CGPoint ptA = CGPointFromValue(prevValue);
                        CGPoint ptB = CGPointFromValue(val);
                        CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
                                                                           to:ptB
                                                                 cornerRadius:0];
                        [fixShapes addObject:shape];
                    }
                    
                    prevValue = val;
                }
                
                _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
            }
            else if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* points = [(LHShape*)_node outlinePoints];
                
                NSValue* firstValue = nil;
                NSValue* prevValue = nil;
                for(NSValue* val in points){
                    
                    if(prevValue)
                    {
                        CGPoint ptA = CGPointFromValue(prevValue);
                        CGPoint ptB = CGPointFromValue(val);
                        
                        CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
                                                                           to:ptB
                                                                 cornerRadius:0];
                        [fixShapes addObject:shape];
                    }
                    
                    if(nil == firstValue){
                        firstValue = val;
                    }
                    prevValue = val;
                }
                
                //close the shape
                if(prevValue && firstValue){
                    CGPoint ptA = CGPointFromValue(prevValue);
                    CGPoint ptB = CGPointFromValue(firstValue);

                    CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
                                                                       to:ptB
                                                             cornerRadius:0];
                    [fixShapes addObject:shape];
                }
                
                _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
            }
            else{
                type = 0;
                
                CGPoint offset = CGPointMake(0, 0);
                CGRect bodyRect = CGRectMake(offset.x,
                                             offset.y,
                                             _node.contentSize.width,
                                             _node.contentSize.height);
                
                _node.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:bodyRect
                                                              cornerRadius:0];
            }
            
        }
        else if(shape == 4)//OVAL
        {
            fixturesInfo = [dict objectForKey:@"ovalShape"];
        }
        else if(shape == 5)//TRACED
        {
            NSString* fixUUID = [dict objectForKey:@"fixtureUUID"];
            LHScene* scene = (LHScene*)[_node scene];
            fixturesInfo = [scene tracedFixturesWithUUID:fixUUID];
            if(!fixturesInfo){
                LHAsset* asset = [self assetParent];
                if(asset){
                    fixturesInfo = [asset tracedFixturesWithUUID:fixUUID];
                }
            }
        }
        else if(shape == 2)//POLYGON
        {
            
            if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* trianglePoints = [(LHShape*)_node trianglePoints];
                
                for(int i = 0; i < [trianglePoints count]; i+=3)
                {
                    NSValue* valA = [trianglePoints objectAtIndex:i];
                    NSValue* valB = [trianglePoints objectAtIndex:i+1];
                    NSValue* valC = [trianglePoints objectAtIndex:i+2];
                    
                    CGPoint ptA = CGPointFromValue(valA);
                    CGPoint ptB = CGPointFromValue(valB);
                    CGPoint ptC = CGPointFromValue(valC);
                    
                    CGPoint points[3];
                    
                    points[0] = ptA;
                    points[1] = ptB;
                    points[2] = ptC;
                    
                    
                    CCPhysicsShape* shape = [CCPhysicsShape polygonShapeWithPoints:points count:3 cornerRadius:0];
                    [fixShapes addObject:shape];
                }
            }
        }
        
        if(fixturesInfo)
        {
            for(NSArray* fixPoints in fixturesInfo)
            {
                int count = (int)[fixPoints count];
                CGPoint points[count];
                
                int i = count - 1;
                for(int j = 0; j< count; ++j)
                {
                    NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                    CGPoint point = LHPointFromString(pointStr);
                    
                    point.x += _node.contentSize.width*0.5;
                    point.y -= _node.contentSize.height*0.5;
                    point.y = -point.y;
                    
                    
                    points[j] = point;
                    i = i-1;
                }
                
                CCPhysicsShape* shape = [CCPhysicsShape polygonShapeWithPoints:points count:count cornerRadius:0];
                [fixShapes addObject:shape];
            }
        }
        if([fixShapes count] > 0){
            _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
        }
        
        if(type == 0)//static
        {
            [_node.physicsBody setType:CCPhysicsBodyTypeStatic];
        }
        else if(type == 1)//kinematic
        {
        }
        else if(type == 2)//dynamic
        {
            [_node.physicsBody setType:CCPhysicsBodyTypeDynamic];
        }
        
        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
        if(fixInfo && _node.physicsBody)
        {
            
            if([dict objectForKey:@"angularDamping"])//all this properties were added in the same moment
            {
                [_node.physicsBody setAngularVelocity:[dict floatForKey:@"angularVelocity" ]];
                
                //_body->SetAngularDamping([dict floatForKey:@"angularDamping"]);
                //_body->SetLinearDamping([dict floatForKey:@"linearDamping"]);
                
                CGPoint linearVel = [dict pointForKey:@"linearVelocity"];
                [_node.physicsBody setVelocity:linearVel];
            }
            
            
            originallySensor = [fixInfo boolForKey:@"sensor"];
            
            NSArray* collisionCats = [fixInfo objectForKey:@"collisionCategories"];
            NSArray* ignoreCats = [fixInfo objectForKey:@"ignoreCategories"];

//            NSLog(@"SPRITE %@", [_node name]);
//            NSLog(@"COLLISION CAT %@", collisionCats);
//            NSLog(@"IGNORE CAT %@", ignoreCats);

            if(!ignoreCats || [ignoreCats count] == 0){
                collisionCats = nil;
                ignoreCats = nil;
            }
            
            
            
            if([fixShapes count] > 0)
            {
                for(CCPhysicsShape* shape in fixShapes)
                {
                    shape.density = [fixInfo floatForKey:@"density"];
                    shape.friction = [fixInfo floatForKey:@"friction"];
                    shape.elasticity = [fixInfo floatForKey:@"restitution"];
                    shape.sensor = [fixInfo boolForKey:@"sensor"];
                    
                    if(ignoreCats)
                        [shape setCollisionCategories:ignoreCats];//member of
                    if(collisionCats)
                        [shape setCollisionMask:collisionCats];//wants to collide with
                }
            }
            else{
                
                if(ignoreCats)
                    [_node.physicsBody setCollisionCategories:ignoreCats];//member of
                if(collisionCats)
                    [_node.physicsBody setCollisionMask:collisionCats];//wants to collide with
                
                if(shape != 3){
                    _node.physicsBody.density = [fixInfo floatForKey:@"density"];
                    _node.physicsBody.friction = [fixInfo floatForKey:@"friction"];
                    _node.physicsBody.elasticity = [fixInfo floatForKey:@"restitution"];
                    _node.physicsBody.sensor = [fixInfo boolForKey:@"sensor"];
                }
            }
            
            if(_node.physicsBody.type == CCPhysicsBodyTypeDynamic)
                _node.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
            
            if([dict intForKey:@"gravityScale"] == 0){
                _node.physicsBody.affectedByGravity = NO;
            }
        }
        
        _node.physicsBody.collisionType = @"Default";
        
        
    }
    return self;
}

#endif //LH_USE_BOX2D

@end
