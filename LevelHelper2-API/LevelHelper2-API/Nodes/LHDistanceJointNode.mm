//
//  LHDistanceJointNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHDistanceJointNode.h"
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

#pragma clang diagnostic pop

#endif //LH_USE_BOX2D



@implementation LHDistanceJointNode
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    LHJointNodeProtocolImp* _jointProtocolImp;
    
    float _dampingRatio;
    float _frequency;
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
        
        _dampingRatio   = [dict floatForKey:@"dampingRatio"];
        _frequency      = [dict floatForKey:@"frequency"];
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

#pragma mark - Properties
-(CGFloat)damping{
    return _dampingRatio;
}

-(CGFloat)frequency{
    return _frequency;
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
    CGPoint relativePosB = [_jointProtocolImp localAnchorB];
    
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
        b2Vec2 relativeB = [scene metersFromPoint:relativePosB];
        
        b2Vec2 posA = bodyA->GetWorldPoint(relativeA);
        b2Vec2 posB = bodyB->GetWorldPoint(relativeB);
        
        b2DistanceJointDef jointDef;
        
        jointDef.Initialize(bodyA,
                            bodyB,
                            posA,
                            posB);
        
        jointDef.collideConnected = [_jointProtocolImp collideConnected];
        
        jointDef.frequencyHz  = _frequency;
        jointDef.dampingRatio = _dampingRatio;
        
        b2DistanceJoint* joint = (b2DistanceJoint*)world->CreateJoint(&jointDef);
        
        [_jointProtocolImp setJoint:joint];

#else//chipmunk
        
        if(!nodeA.physicsBody || !nodeB.physicsBody)
            return NO;

        
        float _length = LHDistanceBetweenPoints(nodeA.position, nodeB.position);
        
        CCPhysicsJoint* joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:nodeA.physicsBody
                                                                          bodyB:nodeB.physicsBody
                                                                        anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
                                                                                            relativePosA.y + nodeA.contentSize.height*0.5)
                                                                        anchorB:CGPointMake(relativePosB.x + nodeB.contentSize.width*0.5,
                                                                                            relativePosB.y + nodeB.contentSize.height*0.5)
                                                                    minDistance:_length
                                                                    maxDistance:_length];
        joint.collideBodies = [_jointProtocolImp collideConnected];
        
        [_jointProtocolImp setJoint:joint];
        
#endif//LH_USE_BOX2D

        
        return true;
    }
    return false;
}

@end
