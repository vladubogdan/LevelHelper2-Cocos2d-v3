//
//  LHDistanceJointNode.h
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
class b2DistanceJoint;
#endif
#else//chipmunk
@class CCPhysicsSlideJoint;
#endif

/**
 LHDistanceJointNode class is used to load a LevelHelper distance joint.
 When using Chipmunk it uses a Slide joint.
 When using Box2d it uses a b2Distance joint.
 */

@interface LHDistanceJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)distanceJointNodeWithDictionary:(NSDictionary*)dict
                                        parent:(CCNode*)prnt;

#pragma mark - Properties
/**
 Returns the damping ratio of the SpriteKit joint.
 */
-(CGFloat)damping;

/**
 Returns the frequency of the SpriteKit joint.
 */
-(CGFloat)frequency;


#pragma mark - Box2d Support
#if LH_USE_BOX2D

/**
 Returns the actual Box2D joint that connects the two bodies together.
 */
#ifdef __cplusplus
-(b2DistanceJoint*)joint;
#endif

#else
#pragma mark - Chipmunk Support
/**
 Returns the actual Cocos2d/Chipmunk joint that connects the two bodies together.
 */
-(CCPhysicsSlideJoint*)joint;
#endif//LH_USE_BOX2D

@end
