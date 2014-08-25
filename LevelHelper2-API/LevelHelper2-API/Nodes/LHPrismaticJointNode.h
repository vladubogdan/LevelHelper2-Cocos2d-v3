//
//  LHPrismaticJointNode.h
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
class b2PrismaticJoint;
#endif
#else//chipmunk

#endif

/**
 LHPrismaticJointNode class is used to load a LevelHelper prismatic joint.

 WARNING - Prismatic joint is not supported in Chipmunk.
 
 When using Box2d it uses a b2PrismaticJoint.
 */

@interface LHPrismaticJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
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
 Returns the lower translation limit.
 */
-(CGFloat)lowerTranslation;

/**
 Returns the upper translation limit.
 */
-(CGFloat)upperTranslation;

/**
 Returns the maximum motor force.
 */
-(CGFloat)maxMotorForce;

/**
 Returns the motor speed in degrees.
 */
-(CGFloat)motorSpeed;

/**
 Returns the axis on which this joint is moving.
 */
-(CGPoint)axis;

@end
