//
//  LHNodePhysicsProtocol.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 14/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LHConfig.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2Body;
#endif
#endif //LH_USE_BOX2D

typedef enum
{
	LH_STATIC_BODY = 0,
	LH_KINEMATIC_BODY,//not available in chipmunk - wil used dynamic instead
	LH_DYNAMIC_BODY,
    LH_NO_PHYSICS
    
} LH_PHYSICS_TYPE;


@protocol LHNodePhysicsProtocol <NSObject>

@required

/**
 Returns the type of the physics body.
 @return A LH_PHYSICS_TYPE enum value; 0 = static, 1 = Kinematic (not available in Chipmunk), 2 = Dynamic, 3 = No Physics
 */
-(int)physicsType;

/**
 Set the physics body type; 
 Note: On Box2d setting a body to No Physics type will not actually delete the body but will make it inactive. It will no longer participate in physics simulation, but it will still exist in order to make it dynamic/static later on.
 Node: On Chipmunk setting a body to No Physics will make it static and sensor. Setting it back to static/dynamic will set the initial sensor state.

 If you really want to delete the body use the appropriate method to do so. After deleting the body you will no longer be able to set it back again until you recreate the Cocos2d node.
 
 @param type A LH_PHYSICS_TYPE enum value. 0 = static, 1 = Kinematic (not available in Chipmunk), 2 = Dynamic, 3 = No Physics
 */
-(void)setPhysicsType:(int)type;

/**
 Removed the physics body from the node. The Cocos2d node will still be alive. If you want to remove the node also call "removeFromParent" instead.
 Note that you won't be able to recreate the body after removal without recreating the entire Cocos2d node. If you need the physics body at a later time you may want
 to change the physics type to No Physics.
*/
-(void)removeBody;

#if LH_USE_BOX2D
#ifdef __cplusplus

/**
 Returns the Box2d body created on this sprite or NULL if sprite has no physics.
 */
-(b2Body*)box2dBody;
#endif
#endif //LH_USE_BOX2D


@end


@interface LHNodePhysicsProtocolImp : NSObject

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;
- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;

-(CCNode*)node;

-(int)bodyType;
-(void)setBodyType:(int)type;

-(void)removeBody;

-(void)visit;

#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2Body*)body;
-(CGAffineTransform)nodeTransform;
-(CGAffineTransform)absoluteTransform;
-(void)updateTransform;
-(CGPoint)position;
-(float)rotation;
-(void)updateScale;
#endif
#endif //LH_USE_BOX2D

@end

#define LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION  \
-(b2Body*)box2dBody\
{\
    return [_physicsProtocolImp body];\
}\
- (CGAffineTransform)nodeToParentTransform\
{\
    if([_physicsProtocolImp body])\
        _transform = [_physicsProtocolImp nodeTransform];\
        \
        return [super nodeToParentTransform];\
}\
-(void)setPosition:(CGPoint)position\
{\
    [super setPosition:position];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateTransform];\
    }\
}\
-(CGPoint)position{\
    if([_physicsProtocolImp body]){\
        return [_physicsProtocolImp position];\
    }\
    return [super position];\
}\
-(void)setRotation:(float)rotation\
{\
    [super setRotation:rotation];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateTransform];\
    }\
}\
-(float)rotation{\
    if([_physicsProtocolImp body]){\
        return [_physicsProtocolImp rotation];\
    }\
    return [super rotation];\
}\
-(void)setScale:(float)scale{\
    [super setScale:scale];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateScale];\
    }\
}\
-(void)setScaleX:(float)scaleX{\
    [super setScaleX:scaleX];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateScale];\
    }\
}\
-(void)setScaleY:(float)scaleY{\
    [super setScaleY:scaleY];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateScale];\
    }\
}

#define LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION  \
-(int)physicsType{\
    return [_physicsProtocolImp bodyType];\
}\
-(void)setPhysicsType:(int)type{\
    [_physicsProtocolImp setBodyType:type];\
}\
-(void)removeBody{\
    [_physicsProtocolImp removeBody];\
}


