//
//  CCPhysicsJoint+LHAdditionalChipmunkJoints.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 16/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "CCPhysicsJoint+LHAdditionalChipmunkJoints.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

#import "CCPhysics+ObjectiveChipmunk.h"

#pragma clang diagnostic pop

@interface CCNode(Private)
-(CGAffineTransform)nonRigidTransform;
@end

#pragma mark - Pin Joint

@interface LHPhysicsPinJoint : CCPhysicsJoint
@end

@implementation LHPhysicsPinJoint {
    ChipmunkPinJoint *_constraint;
    CGPoint _anchorA, _anchorB;
}

- (id)initWithBodyA:(CCPhysicsBody *)bodyA
              bodyB:(CCPhysicsBody *)bodyB
            anchorA:(CGPoint)anchorA
            anchorB:(CGPoint)anchorB;
{
    if ((self = [super init])){
        _constraint = [ChipmunkPinJoint pinJointWithBodyA:bodyA.body
                                                    bodyB:bodyB.body
                                                  anchorA:CCP_TO_CPV(anchorA)
                                                  anchorB:CCP_TO_CPV(anchorB)];
        _constraint.userData = self;
        
        _anchorA = anchorA;
		_anchorB = anchorB;
    }
    
    return self;
}

- (ChipmunkConstraint *)constraint
{
    return _constraint;
}

- (void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
    CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	_constraint.anchorA = CCP_TO_CPV(CGPointApplyAffineTransform(_anchorA, bodyA.node.nonRigidTransform));
	_constraint.anchorB = CCP_TO_CPV(CGPointApplyAffineTransform(_anchorB, bodyB.node.nonRigidTransform));
}

@end



#pragma mark - Simple Motor Joint

@interface LHPhysicsSimpleMotorJoint : CCPhysicsJoint
@end

@implementation LHPhysicsSimpleMotorJoint {
    ChipmunkSimpleMotor *_constraint;
}

- (id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB rate:(CGFloat)rate
{
    if ((self = [super init])){
        _constraint = [ChipmunkSimpleMotor simpleMotorWithBodyA:bodyA.body
                                                          bodyB:bodyB.body
                                                           rate:rate];
        _constraint.userData = self;
    }
    
    return self;
}

- (ChipmunkConstraint *)constraint
{
    return _constraint;
}

- (void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{

}

@end

#pragma mark -

@implementation CCPhysicsJoint (LHAdditionalChipmunkJoints)

+ (CCPhysicsJoint *)LHMotorJointWithBodyA:(CCPhysicsBody *)bodyA
                                    bodyB:(CCPhysicsBody *)bodyB
                                     rate:(CGFloat)rate
{
    CCPhysicsJoint *joint = [[LHPhysicsSimpleMotorJoint alloc] initWithBodyA:bodyA bodyB:bodyB rate:rate];
    
    [bodyA addJoint:joint];
    [bodyB addJoint:joint];
    
    [bodyA.physicsNode.space smartAdd:joint];
    
    return joint;
}

+ (CCPhysicsJoint *)LHPinJointWithBodyA:(CCPhysicsBody *)bodyA
                                  bodyB:(CCPhysicsBody *)bodyB
                                anchorA:(CGPoint)anchorA
                                anchorB:(CGPoint)anchorB
{
    CCPhysicsJoint *joint = [[LHPhysicsPinJoint alloc] initWithBodyA:bodyA
                                                               bodyB:bodyB
                                                             anchorA:anchorA
                                                             anchorB:anchorB];
    
    [bodyA addJoint:joint];
    [bodyB addJoint:joint];
    
    [bodyA.physicsNode.space smartAdd:joint];
    
    return joint;
}

@end
