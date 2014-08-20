//
//  LHJointNodeProtocol.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 16/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LHConfig.h"
#import "LHNodePhysicsProtocol.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2Joint;
#endif//cpp
#else

#endif//LH_USE_BOX2D


/**
 LevelHelper 2 joint nodes conform to this protocol.
 */
@protocol LHJointNodeProtocol <NSObject>

@required

/**
 Returns the point where the joint is connected with the first body. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the point where the joint is connected with the second body. In scene coordinates.
 */
-(CGPoint)anchorB;

/**
 Returns the actual Box2d or Cocos2d/Chipmunk joint object.
 */
#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2Joint*)joint;
#endif

#else//chipmunk
-(CCPhysicsJoint*)joint;
#endif//LH_USE_BOX2D

@end


@interface LHJointNodeProtocolImp : NSObject

+ (instancetype)jointProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode<LHJointNodeProtocol>*)nd;
- (instancetype)initJointProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode<LHJointNodeProtocol>*)nd;

-(void)findConnectedNodes;

-(CCNode<LHNodePhysicsProtocol>*)nodeA;
-(CCNode<LHNodePhysicsProtocol>*)nodeB;

-(CGPoint)localAnchorA;
-(CGPoint)localAnchorB;

-(CGPoint)anchorA;
-(CGPoint)anchorB;

-(BOOL)collideConnected;

-(void)removeJoint;

#if LH_USE_BOX2D

#ifdef __cplusplus
-(void)setJoint:(b2Joint*)val;
-(b2Joint*)joint;
#endif

#else//chipmunk

-(void)setJoint:(CCPhysicsJoint*)val;
-(CCPhysicsJoint*)joint;

#endif//LH_USE_BOX2D

#define LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION  \
-(CGPoint)anchorA{\
    return [_jointProtocolImp anchorA];\
}\
-(CGPoint)anchorB{\
    return [_jointProtocolImp anchorB];\
}

#if LH_USE_BOX2D

#define LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION  \
-(b2Joint*)joint{\
    return [_jointProtocolImp joint];\
}

#else//chipmunk

#define LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION  \
-(CCPhysicsJoint*)joint{\
return [_jointProtocolImp joint];\
}

#endif


@end
