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

#import "LHConfig.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2D.h"
#include <vector>
#endif
#endif //LH_USE_BOX2D

@implementation LHNodePhysicsProtocolImp
{
#if LH_USE_BOX2D
    b2Body* _body;
    NSDictionary* _bodyInfo;//used when scale is changed - we recreate the body
#endif
    __weak CCNode* _node;
}

-(void)dealloc{
    _node = nil;
#if LH_USE_BOX2D
    LH_SAFE_RELEASE(_bodyInfo);
#endif
    
    LH_SUPER_DEALLOC();
}

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    return LH_AUTORELEASED([[self alloc] initPhysicsProtocolImpWithDictionary:dict node:nd]);
}

#if LH_USE_BOX2D

#pragma mark - BOX2D SUPPORT

- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dictionary node:(CCNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;
        _body = NULL;
        
        NSDictionary* dict = [dictionary objectForKey:@"nodePhysics"];
        
        if(!dict){
            return self;
        }
        
        _bodyInfo = [[NSDictionary alloc] initWithDictionary:dict];
        
        
        int shapeType = [dict intForKey:@"shape"];
        int type = [dict intForKey:@"type"];
        
        LHScene* scene = (LHScene*)[_node scene];
        b2World* world = [scene box2dWorld];
        

        b2BodyDef bodyDef;
        bodyDef.type = (b2BodyType)type;
        
        CGPoint position = [_node convertToNodeSpaceAR:CGPointZero];
        b2Vec2 bodyPos = [scene metersFromPoint:position];
        bodyDef.position = bodyPos;


        float angle = [_node rotation];
        bodyDef.angle = CC_DEGREES_TO_RADIANS(angle);

//        bodyDef.userData = self;
        _body = world->CreateBody(&bodyDef);
//        _body->SetUserData(self);
//        _body->SetFixedRotation([self physics].fixedRotation);
//        _body->SetGravityScale([self physics].gravityScale.floatValue);
//        _body->SetSleepingAllowed([self physics].allowSleep);
//        _body->SetBullet([self physics].bullet);
        
        CGSize sizet = [_node contentSize];
        sizet.width  = [scene metersFromValue:sizet.width];
        sizet.height = [scene metersFromValue:sizet.height];
        
        float scaleX = [_node scaleX];
        float scaleY = [_node scaleY];

        
        sizet.width *= scaleX;
        sizet.height*= scaleY;
        
        b2FixtureDef fixture;
        
        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
        if(fixInfo && _body)
        {
            fixture.density     = [fixInfo floatForKey:@"density"];
            fixture.friction    = [fixInfo floatForKey:@"friction"];
            fixture.restitution = [fixInfo floatForKey:@"restitution"];
            fixture.isSensor    = [fixInfo boolForKey:@"sensor"];
//            fixture.filter.maskBits = [fixInfo mask].intValue;
//            fixture.filter.categoryBits = [fixInfo category].intValue;

            
//            NSArray* collisionCats = [fixInfo objectForKey:@"collisionCategories"];
//            NSArray* ignoreCats = [fixInfo objectForKey:@"ignoreCategories"];
//            if(!ignoreCats || [ignoreCats count] == 0){
//                collisionCats = nil;
//                ignoreCats = nil;
//            }
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
                
                for(NSValue* val in points){
                    CGPoint pt = CGPointFromValue(val);
                    pt.x *= scaleX;
                    pt.y *= scaleY;
                    
                    verts.push_back([scene metersFromPoint:pt]);
                }
                
                shape = new b2ChainShape();
                ((b2ChainShape*)shape)->CreateChain (&(verts.front()), (int)verts.size());
            }
//            else if([_node isKindOfClass:[LHShape class]])
//            {
//                NSArray* points = [(LHShape*)_node outlinePoints];
//                
//                NSValue* firstValue = nil;
//                NSValue* prevValue = nil;
//                for(NSValue* val in points){
//                    
//                    if(prevValue)
//                    {
//                        CGPoint ptA = CGPointFromValue(prevValue);
//                        CGPoint ptB = CGPointFromValue(val);
//                        CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
//                                                                           to:ptB
//                                                                 cornerRadius:0];
//                        [fixShapes addObject:shape];
//                    }
//                    
//                    if(nil == firstValue){
//                        firstValue = val;
//                    }
//                    prevValue = val;
//                }
//                
//                //close the shape
//                if(prevValue && firstValue){
//                    CGPoint ptA = CGPointFromValue(prevValue);
//                    CGPoint ptB = CGPointFromValue(firstValue);
//                    CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
//                                                                       to:ptB
//                                                             cornerRadius:0];
//                    [fixShapes addObject:shape];
//                }
//                
//                _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
//            }
//            else{
//                type = 0;
//                
//                CGPoint offset = CGPointMake(0, 0);
//                CGRect bodyRect = CGRectMake(offset.x,
//                                             offset.y,
//                                             _node.contentSize.width,
//                                             _node.contentSize.height);
//                
//                _node.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:bodyRect
//                                                               cornerRadius:0];
//            }
            
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
                    
                    ptA.x *= scaleX;
                    ptA.y *= scaleY;

                    ptB.x *= scaleX;
                    ptB.y *= scaleY;

                    ptC.x *= scaleX;
                    ptC.y *= scaleY;

                    b2Vec2 *verts = new b2Vec2[3];
                    
                    verts[2] = [scene metersFromPoint:ptA];
                    verts[1] = [scene metersFromPoint:ptB];
                    verts[0] = [scene metersFromPoint:ptC];
                    
                    b2PolygonShape shapeDef;
                    
                    shapeDef.Set(verts, 3);
                    
                    b2FixtureDef fixture;
                    
                    fixture.density     = [fixInfo floatForKey:@"density"];
                    fixture.friction    = [fixInfo floatForKey:@"friction"];
                    fixture.restitution = [fixInfo floatForKey:@"restitution"];
                    fixture.isSensor    = [fixInfo boolForKey:@"sensor"];
                    
                    //                    fixture.filter.maskBits = [fixInfo mask].intValue;
                    //                    fixture.filter.categoryBits = [fixInfo category].intValue;
                    
                    fixture.shape = &shapeDef;
                    _body->CreateFixture(&fixture);
                    delete[] verts;
                }
            }
        }
        
        if(fixturesInfo)
        {
            int flipx = [_node scaleX] < 0 ? -1 : 1;
            int flipy = [_node scaleY] < 0 ? -1 : 1;
            
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
                        point.x *= scaleX;
                        point.y *= scaleY;
                        
                        point.y = -point.y;
                        
                        verts[idx] = [scene metersFromPoint:point];
                        ++i;
                    }
                    
                    shapeDef.Set(verts, count);
                    
                    b2FixtureDef fixture;
                    
                    fixture.density     = [fixInfo floatForKey:@"density"];
                    fixture.friction    = [fixInfo floatForKey:@"friction"];
                    fixture.restitution = [fixInfo floatForKey:@"restitution"];
                    fixture.isSensor    = [fixInfo boolForKey:@"sensor"];
                    
//                    fixture.filter.maskBits = [fixInfo mask].intValue;
//                    fixture.filter.categoryBits = [fixInfo category].intValue;
                    
                    fixture.shape = &shapeDef;
                    _body->CreateFixture(&fixture);
                    delete[] verts;
                }
            }
            
        }
//        if([fixShapes count] > 0){
//            _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
//        }
//        
//        if(type == 0)//static
//        {
//            [_node.physicsBody setType:CCPhysicsBodyTypeStatic];
//        }
//        else if(type == 1)//kinematic
//        {
//        }
//        else if(type == 2)//dynamic
//        {
//            [_node.physicsBody setType:CCPhysicsBodyTypeDynamic];
//        }
//        
//        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
//        if(fixInfo && _node.physicsBody)
//        {
//            NSArray* collisionCats = [fixInfo objectForKey:@"collisionCategories"];
//            NSArray* ignoreCats = [fixInfo objectForKey:@"ignoreCategories"];
//            if(!ignoreCats || [ignoreCats count] == 0){
//                collisionCats = nil;
//                ignoreCats = nil;
//            }
//            
//            if([fixShapes count] > 0)
//            {
//                for(CCPhysicsShape* shape in fixShapes)
//                {
//                    shape.density = [fixInfo floatForKey:@"density"];
//                    shape.friction = [fixInfo floatForKey:@"friction"];
//                    shape.elasticity = [fixInfo floatForKey:@"restitution"];
//                    shape.sensor = [fixInfo boolForKey:@"sensor"];
//                    
//                    if(ignoreCats)
//                        [shape setCollisionCategories:ignoreCats];//member of
//                    if(collisionCats)
//                        [shape setCollisionMask:collisionCats];//wants to collide with
//                }
//            }
//            else{
//                
//                if(ignoreCats)
//                    [_node.physicsBody setCollisionCategories:ignoreCats];//member of
//                if(collisionCats)
//                    [_node.physicsBody setCollisionMask:collisionCats];//wants to collide with
//                
//                if(shape != 3){
//                    _node.physicsBody.density = [fixInfo floatForKey:@"density"];
//                    _node.physicsBody.friction = [fixInfo floatForKey:@"friction"];
//                    _node.physicsBody.elasticity = [fixInfo floatForKey:@"restitution"];
//                    _node.physicsBody.sensor = [fixInfo boolForKey:@"sensor"];
//                }
//            }
//            
//            if(_node.physicsBody.type == CCPhysicsBodyTypeDynamic)
//                _node.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
//            
//            if([dict intForKey:@"gravityScale"] == 0){
//                _node.physicsBody.affectedByGravity = NO;
//            }
//        }
        
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

static inline CGAffineTransform b2BodyToParentTransform(CCNode *node, LHNodePhysicsProtocolImp *physicsImp)
{
	return CGAffineTransformConcat(physicsImp.absoluteTransform, CGAffineTransformInvert(NodeToB2BodyTransform(node.parent)));
}
static inline CGAffineTransform NodeToB2BodyTransform(CCNode *node)
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	for(CCNode *n = node; n; n = n.parent){
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

    if(![_node isKindOfClass:[LHShape class]] && ![_node isKindOfClass:[LHBezier class]])//whats going on here? Why?
        transform = CGAffineTransformTranslate(transform, - _node.contentSize.width*0.5*_node.scaleX, - _node.contentSize.height*0.5*_node.scaleY);

	return transform;
}

-(void)updateTransform
{
    if([self body])
    {
        CGPoint worldPos = [_node convertToWorldSpaceAR:CGPointZero];
        b2Vec2 b2Pos = [(LHScene*)[_node scene] metersFromPoint:worldPos];
        _body->SetTransform(b2Pos, CC_DEGREES_TO_RADIANS(-[_node rotation]));
    }
}

-(void)updateScale{
    
}

#pragma mark - CHIPMUNK SUPPORT
////////////////////////////////////////////////////////////////////////////////
#else //chipmunk

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
            NSArray* collisionCats = [fixInfo objectForKey:@"collisionCategories"];
            NSArray* ignoreCats = [fixInfo objectForKey:@"ignoreCategories"];
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
        
        
    }
    return self;
}

#endif //LH_USE_BOX2D

@end
