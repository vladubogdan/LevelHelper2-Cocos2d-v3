//
//  LHPulleyJointNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHJointNodeProtocol.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2PulleyJoint;
#endif
#else//chipmunk
@class CCPhysicsPivotJoint;
#endif

/**
 LHPulleyJointNode class is used to load a LevelHelper pulley joint.

 WARNING - Pulley joint is not supported in Chipmunk.
 
 When using Box2d it uses a b2PulleyJoint.
 */

@interface LHPulleyJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


#pragma mark - Properties
/**
 Returns the first ground anchor in scene coordinates.
 */
-(CGPoint)groundAnchorA;

/**
 Returns the first ground anchor in scene coordinates.
 */
-(CGPoint)groundAnchorB;


@end
