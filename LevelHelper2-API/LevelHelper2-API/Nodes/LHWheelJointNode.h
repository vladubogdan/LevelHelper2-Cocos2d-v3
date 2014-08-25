//
//  LHWheelJointNode.h
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
class b2WheelJoint;
#endif
#else//chipmunk

#endif

/**
 LHWheelJointNode class is used to load a LevelHelper wheel joint.

 WARNING - Prismatic joint is not supported in Chipmunk.
 
 When using Box2d it uses a b2WheelJoint.
 */

@interface LHWheelJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


#pragma mark - Properties
/**
 Returns whether or not the motor is enabled on the joint.
 */
-(BOOL)enableMotor;

/**
 Returns the maximum motor torque.
 */
-(CGFloat)maxMotorTorque;

/**
 Returns the motor speed in degrees.
 */
-(CGFloat)motorSpeed;

/**
 Returns the frequency used on the joint.
 */
-(CGFloat)frequency;

/**
 Returns the damping ratio used on the joint.
 */
-(CGFloat)dampingRatio;

/**
 Returns the axis on which this joint is moving.
 */
-(CGPoint)axis;

@end
