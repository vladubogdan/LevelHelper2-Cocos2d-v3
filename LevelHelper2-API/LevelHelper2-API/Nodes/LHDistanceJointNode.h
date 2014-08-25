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

 When using Cocos2d/Chipmunk it uses a CCPhysicsSlideJoint joint.
 
 When using Box2d it uses a b2DistanceJoint object.
 */

@interface LHDistanceJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

-(instancetype)initWithDictionary:(NSDictionary*)dict
                               parent:(CCNode*)prnt;


#pragma mark - Properties
/**
 Returns the damping ratio of the joint.
 */
-(CGFloat)damping;

/**
 Returns the frequency of the joint.
 */
-(CGFloat)frequency;

@end
