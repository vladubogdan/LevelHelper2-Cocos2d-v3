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

@end
