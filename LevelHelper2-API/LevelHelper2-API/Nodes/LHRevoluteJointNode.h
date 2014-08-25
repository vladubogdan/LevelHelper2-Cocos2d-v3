//
//  LHRevoluteJointNode.h
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
class b2RevoluteJoint;
#endif
#else//chipmunk
@class CCPhysicsPivotJoint;
#endif

/**
 LHRevoluteJointNode class is used to load a LevelHelper revolute joint.

 WARNING - Revolute joint is not supported in Chipmunk.
 
 When using Box2d it uses a b2RevoluteJoint.
 */

@interface LHRevoluteJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

-(instancetype)initWithDictionary:(NSDictionary*)dict
                               parent:(CCNode*)prnt;



#pragma mark - Properties
/**
 Returns whether or not the limit is enabled on the joint.
 */
-(BOOL)enableLimit;

/**
 Returns whether or not the motor is enabled on the joint.
 */
-(BOOL)enableMotor;

/**
 Returns the lower angle limit
 */
-(CGFloat)lowerAngle;

/**
 Returns the upper angle limit
 */
-(CGFloat)upperAngle;


/**
 Returns the maximum motor torque
 */
-(CGFloat)maxMotorTorque;

/**
 Returns the motor speed.
 */
-(CGFloat)motorSpeed;


@end
