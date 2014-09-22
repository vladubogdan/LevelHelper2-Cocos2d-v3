//
//  LHWheelJointNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHWheelJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHConfig.h"
#import "LHGameWorldNode.h"

#if LH_USE_BOX2D
#include "Box2d/Box2D.h"


#else//chipmunk

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

#import "CCPhysics+ObjectiveChipmunk.h"
#import "CCPhysicsJoint+LHAdditionalChipmunkJoints.h"

#pragma clang diagnostic pop

#endif //LH_USE_BOX2D



@implementation LHWheelJointNode
{
    LHNodeProtocolImpl*     _nodeProtocolImp;
    LHJointNodeProtocolImp* _jointProtocolImp;
    
    BOOL _enableMotor;
    
    float _maxMotorTorque;
    float _motorSpeed;
    
    float _frequency;
    float _damping;
    
    CGPoint _axis;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                                     parent:(CCNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                         parent:prnt]);
}

-(instancetype)initWithDictionary:(NSDictionary*)dict
                               parent:(CCNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _jointProtocolImp= [[LHJointNodeProtocolImp alloc] initJointProtocolImpWithDictionary:dict
                                                                                         node:self];
        
        
        _enableMotor = [dict boolForKey:@"enableWheelMotor"];
        
        _frequency  = [dict floatForKey:@"wheelFrequencyHz"];
        _damping    = [dict floatForKey:@"wheelDampingRatio"];
        
        _maxMotorTorque = [dict floatForKey:@"wheelMaxMotorForce"];
        _motorSpeed = [dict floatForKey:@"wheelMotorSpeed"];
        
        _axis = [dict pointForKey:@"axis"];
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

#pragma mark - Properties
-(BOOL)enableMotor{
    return _enableMotor;
}
-(CGFloat)frequency{
    return _frequency;
}
-(CGFloat)dampingRatio{
    return _damping;
}
-(CGFloat)maxMotorTorque{
    return _maxMotorTorque;
}
-(CGFloat)motorSpeed{
    return _motorSpeed;
}
-(CGPoint)axis{
    return _axis;
}

#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION



#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Optional
- (void)visit
{
    if(![_jointProtocolImp nodeA] ||  ![_jointProtocolImp nodeB]){
        [self lateLoading];
    }
    
    [super visit];
}
-(BOOL)lateLoading
{
    [_jointProtocolImp findConnectedNodes];
    
    CCNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
    CCNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
    
    CGPoint relativePosA = [_jointProtocolImp localAnchorA];
    
    if(nodeA && nodeB)
    {
#if LH_USE_BOX2D
        
        LHScene* scene = (LHScene*)[self scene];
        LHGameWorldNode* pNode = (LHGameWorldNode*)[scene gameWorldNode];
        
        b2World* world = [pNode box2dWorld];
        
        if(world == nil)return NO;
        
        b2Body* bodyA = [nodeA box2dBody];
        b2Body* bodyB = [nodeB box2dBody];
        
        if(!bodyA || !bodyB)return NO;
        
        b2Vec2 relativeA = [scene metersFromPoint:relativePosA];
        
        b2Vec2 posA =  bodyA->GetWorldPoint(relativeA);
        
        b2WheelJointDef jointDef;
        
        jointDef.Initialize(bodyA, bodyB, posA, b2Vec2(-_axis.x,-_axis.y));
        
        jointDef.enableMotor    = _enableMotor;
        jointDef.maxMotorTorque = _maxMotorTorque;
        jointDef.motorSpeed     = CC_DEGREES_TO_RADIANS(_motorSpeed*360.0f);
        jointDef.frequencyHz    = _frequency;
        jointDef.dampingRatio   = _damping;
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];

        b2PrismaticJoint* joint = (b2PrismaticJoint*)world->CreateJoint(&jointDef);

        [_jointProtocolImp setJoint:joint];

#else//chipmunk
        
        if(!nodeA.physicsBody || !nodeB.physicsBody)
            return NO;

        NSLog(@"\n\nWARNING: Wheel joint is not supported when using Chipmunk physics engine.\n\n");
        
#pragma unused (relativePosA)

        
//        CCPhysicsJoint* joint = [CCPhysicsJoint connectedPivotJointWithBodyA:nodeA.physicsBody
//                                                                       bodyB:nodeB.physicsBody
//                                                                     anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
//                                                                                         relativePosA.y + nodeA.contentSize.height*0.5)];
        
//        CGPoint relativePosB = [nodeA convertToWorldSpaceAR:relativePosA];
//        relativePosB = [nodeB convertToNodeSpaceAR:relativePosB];
//        
//        
//        
//        CCPhysicsJoint* joint = [CCPhysicsJoint LHPinJointWithBodyA:nodeA.physicsBody
//                                                              bodyB:nodeB.physicsBody
//                                                            anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
//                                                                                relativePosA.y + nodeA.contentSize.height*0.5)
//                                                            anchorB:relativePosB];
        
//        CCPhysicsJoint* joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:nodeA.physicsBody
//                                                                          bodyB:nodeB.physicsBody
//                                                                        anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
//                                                                                            relativePosA.y + nodeA.contentSize.height*0.5)
//                                                                        anchorB:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
//                                                                                            relativePosA.y + nodeA.contentSize.height*0.5)
//                                                                    minDistance:0
//                                                                    maxDistance:0.1];

//        joint.collideBodies = [_jointProtocolImp collideConnected];
        
//        [_jointProtocolImp setJoint:joint];
        
#endif//LH_USE_BOX2D

        
        return true;
    }
    return false;
}

@end
