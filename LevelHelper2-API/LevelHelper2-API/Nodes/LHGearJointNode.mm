//
//  LHGearJointNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHGearJointNode.h"
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



@implementation LHGearJointNode
{
    LHNodeProtocolImpl*     _nodeProtocolImp;
    LHJointNodeProtocolImp* _jointProtocolImp;
 
    NSString* _jointAUUID;
    NSString* _jointBUUID;
    
    __weak CCNode<LHJointNodeProtocol>* _jointA;
    __weak CCNode<LHJointNodeProtocol>* _jointB;
    
    float   _ratio;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_jointProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    _jointA = nil;
    _jointB = nil;
    
    LH_SAFE_RELEASE(_jointAUUID);
    LH_SAFE_RELEASE(_jointBUUID);
    
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

        if([dict objectForKey:@"jointAUUID"])
            _jointAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"jointAUUID"]];
        
        if([dict objectForKey:@"jointBUUID"])
            _jointBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"jointBUUID"]];

        _ratio = [dict floatForKey:@"gearRatio"];
    }
    return self;
}

-(void)removeFromParent{
    LH_SAFE_RELEASE(_jointProtocolImp);
    [super removeFromParent];
}

#pragma mark - Properties



#pragma mark - LHJointNodeProtocol Required
LH_JOINT_PROTOCOL_COMMON_METHODS_IMPLEMENTATION
LH_JOINT_PROTOCOL_SPECIFIC_PHYSICS_ENGINE_METHODS_IMPLEMENTATION



#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Optional
-(void)findConnectedJoints
{
    if(!_jointAUUID || !_jointBUUID)
        return;
    
    LHScene* scene = (LHScene*)[self scene];
    
    if([[self parent] respondsToSelector:@selector(childNodeWithUUID:)])
    {
        _jointA = (CCNode<LHJointNodeProtocol>*)[(id<LHNodeProtocol>)[self parent] childNodeWithUUID:_jointAUUID];
        _jointB = (CCNode<LHJointNodeProtocol>*)[(id<LHNodeProtocol>)[self parent] childNodeWithUUID:_jointBUUID];
    }
    else{
        _jointA = (CCNode<LHJointNodeProtocol>*)[scene childNodeWithUUID:_jointAUUID];
        _jointB = (CCNode<LHJointNodeProtocol>*)[scene childNodeWithUUID:_jointBUUID];
    }
}

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
    
    [self findConnectedJoints];
    
    CCNode<LHNodePhysicsProtocol>* nodeA = [_jointProtocolImp nodeA];
    CCNode<LHNodePhysicsProtocol>* nodeB = [_jointProtocolImp nodeB];
    
    if(nodeA && nodeB && _jointA && _jointB)
    {
#if LH_USE_BOX2D
        
        LHScene* scene = (LHScene*)[self scene];
        LHGameWorldNode* pNode = (LHGameWorldNode*)[scene gameWorldNode];
        
        b2World* world = [pNode box2dWorld];
        
        if(world == nil)return NO;
        
        b2Body* bodyA = [nodeA box2dBody];
        b2Body* bodyB = [nodeB box2dBody];
        
        if(!bodyA || !bodyB)return NO;
        
        b2Joint* jtA = [_jointA joint];
        b2Joint* jtB = [_jointB joint];
        
        
        b2GearJointDef jointDef;
        
        jointDef.joint1 = jtA;
        jointDef.joint2 = jtB;
        jointDef.bodyA = bodyA;
        jointDef.bodyB = bodyB;
        jointDef.ratio = _ratio;

        jointDef.collideConnected = [_jointProtocolImp collideConnected];

        b2GearJoint* joint = (b2GearJoint*)world->CreateJoint(&jointDef);

        [_jointProtocolImp setJoint:joint];

#else//chipmunk
        
        if(!nodeA.physicsBody || !nodeB.physicsBody)
            return NO;

        NSLog(@"\n\nWARNING: Gear joint is not supported when using Chipmunk physics engine.\n\n");
        
        
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
