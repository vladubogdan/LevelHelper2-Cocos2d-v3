//
//  LHRevoluteJointNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHRevoluteJointNode.h"
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



@implementation LHRevoluteJointNode
{
    LHNodeProtocolImpl*     _nodeProtocolImp;
    LHJointNodeProtocolImp* _jointProtocolImp;
    
    BOOL _enableLimit;
    BOOL _enableMotor;
    
    float _lowerAngle;
    float _upperAngle;
    
    float _maxMotorTorque;
    float _motorSpeed;
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
        
        
        _enableLimit = [dict boolForKey:@"enableLimit"];
        _enableMotor = [dict boolForKey:@"enableMotor"];
        

        _lowerAngle = -[dict floatForKey:@"lowerAngle"];
        _upperAngle = -[dict floatForKey:@"upperAngle"];
        
        _maxMotorTorque = [dict floatForKey:@"maxMotorTorque"];
        _motorSpeed = CC_DEGREES_TO_RADIANS(-360.0*[dict floatForKey:@"motorSpeed"]);
        
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

#pragma mark - Properties
-(BOOL)enableLimit{
    return _enableLimit;
}
-(BOOL)enableMotor{
    return _enableMotor;
}
-(CGFloat)lowerAngle{
    return _lowerAngle;
}
-(CGFloat)upperAngle{
    return _upperAngle;
}
-(CGFloat)maxMotorTorque{
    return _maxMotorTorque;
}
-(CGFloat)motorSpeed{
    return _motorSpeed;
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
        b2Vec2 posA = bodyA->GetWorldPoint(relativeA);
        
        b2RevoluteJointDef jointDef;
        
        jointDef.Initialize(bodyA,
                            bodyB,
                            posA);
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];

        jointDef.enableLimit = _enableLimit;
        jointDef.enableMotor = _enableMotor;
        
        
        if(_lowerAngle < _upperAngle){
            jointDef.lowerAngle = CC_DEGREES_TO_RADIANS(_lowerAngle);
            jointDef.upperAngle = CC_DEGREES_TO_RADIANS(_upperAngle);
        }
        else{
            jointDef.lowerAngle = CC_DEGREES_TO_RADIANS(_upperAngle);
            jointDef.upperAngle = CC_DEGREES_TO_RADIANS(_lowerAngle);
        }

        
        jointDef.maxMotorTorque = _maxMotorTorque;
        jointDef.motorSpeed = _motorSpeed;
        
        b2RevoluteJoint* joint = (b2RevoluteJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];

#else//chipmunk
        
        if(!nodeA.physicsBody || !nodeB.physicsBody)
            return NO;

        NSLog(@"\n\nWARNING: Revolute joint is not supported when using Chipmunk physics engine.\n\n");
        
        CCPhysicsJoint* joint = [CCPhysicsJoint connectedPivotJointWithBodyA:nodeA.physicsBody
                                                                       bodyB:nodeB.physicsBody
                                                                     anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
                                                                                         relativePosA.y + nodeA.contentSize.height*0.5)];
        joint.collideBodies = [_jointProtocolImp collideConnected];
        
        [_jointProtocolImp setJoint:joint];
        
#endif//LH_USE_BOX2D

        
        return true;
    }
    return false;
}

@end
