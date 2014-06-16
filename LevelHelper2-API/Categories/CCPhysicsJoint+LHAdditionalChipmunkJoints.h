//
//  CCPhysicsJoint+LHAdditionalChipmunkJoints.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 16/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "CCPhysicsJoint.h"
#import "cocos2d.h"

@interface CCPhysicsJoint (LHAdditionalChipmunkJoints)

+ (CCPhysicsJoint *)LHMotorJointWithBodyA:(CCPhysicsBody *)bodyA
                                    bodyB:(CCPhysicsBody *)bodyB
                                     rate:(CGFloat)rate;

+ (CCPhysicsJoint *)LHPinJointWithBodyA:(CCPhysicsBody *)bodyA
                                  bodyB:(CCPhysicsBody *)bodyB
                                anchorA:(CGPoint)anchorA
                                anchorB:(CGPoint)anchorB;

@end
