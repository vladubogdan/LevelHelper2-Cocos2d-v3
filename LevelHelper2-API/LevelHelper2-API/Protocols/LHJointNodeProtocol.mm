//
//  LHJointNodeProtocol.mm
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 16/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHJointNodeProtocol.h"
#import "LHScene.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHGameWorldNode.h"
#import "LHConfig.h"
#import "LHNode.h"

#if LH_USE_BOX2D
#include "Box2d/Box2D.h"
#else

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

#import "CCPhysics+ObjectiveChipmunk.h"

#pragma clang diagnostic pop

#endif //LH_USE_BOX2D


@implementation LHJointNodeProtocolImp
{
    __weak CCNode<LHJointNodeProtocol>* _node;
    
    
#if LH_USE_BOX2D
    b2Joint* _joint;
#else
    __weak CCPhysicsJoint* _joint;
#endif
    
    CGPoint _relativePosA;
    CGPoint _relativePosB;
    
    NSString* _nodeAUUID;
    NSString* _nodeBUUID;
    
    __unsafe_unretained CCNode<LHNodePhysicsProtocol>* _nodeA;
    __unsafe_unretained CCNode<LHNodePhysicsProtocol>* _nodeB;

    BOOL _collideConnected;
}

-(void)dealloc{

#if LH_USE_BOX2D
    if(_joint && _node && [_node respondsToSelector:@selector(isB2WorldDirty)] && ![(LHNode*)_node isB2WorldDirty])
    {
        //do not remove the joint if the scene is deallocing as the box2d world will be deleted
        //so we dont need to do this manualy
        //in some cases the nodes will be retained and removed after the box2d world is already deleted and we may have a crash
        [self removeJoint];
    }
#else
    [self removeJoint];
#endif
    
    _node = nil;
    
    _nodeA = nil;
    _nodeB = nil;
    
    LH_SAFE_RELEASE(_nodeAUUID);
    LH_SAFE_RELEASE(_nodeBUUID);
    
    LH_SUPER_DEALLOC();
    
}

+ (instancetype)jointProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode<LHJointNodeProtocol>*)nd{
    return LH_AUTORELEASED([[self alloc] initJointProtocolImpWithDictionary:dict node:nd]);
}
- (instancetype)initJointProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode<LHJointNodeProtocol>*)nd{
    
    if(self = [super init])
    {
        _joint = NULL;
        _node = nd;
        
        if([dict objectForKey:@"relativePosA"])//certain joints do not have an anchor (e.g. gear joint)
            _relativePosA = [dict pointForKey:@"relativePosA"];

        if([dict objectForKey:@"relativePosB"])//certain joints do not have a second anchor
            _relativePosB = [dict pointForKey:@"relativePosB"];
        
        if([dict objectForKey:@"spriteAUUID"]){//maybe its a dummy joint
            _nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        }
        else{
            NSLog(@"WARNING: Joint %@ is not connected to a node", [dict objectForKey:@"name"]);
        }
        
        if([dict objectForKey:@"spriteBUUID"]){//maybe its a dummy joint
            _nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        }
        else{
            NSLog(@"WARNING: Joint %@ is not connected to a node", [dict objectForKey:@"name"]);
        }

        _collideConnected = [dict boolForKey:@"collideConnected"];
    }
    return self;
}


#pragma mark - Common Physics Engines
-(void)findConnectedNodes
{
    if(!_nodeAUUID || !_nodeBUUID)
        return;
    
    LHScene* scene = (LHScene*)[_node scene];

    if([[_node parent] respondsToSelector:@selector(childNodeWithUUID:)])
    {
        _nodeA = (CCNode<LHNodePhysicsProtocol>*)[(id<LHNodeProtocol>)[_node parent] childNodeWithUUID:_nodeAUUID];
        _nodeB = (CCNode<LHNodePhysicsProtocol>*)[(id<LHNodeProtocol>)[_node parent] childNodeWithUUID:_nodeBUUID];
    }

    if(!_nodeA){
        _nodeA = (CCNode<LHNodePhysicsProtocol>*)[scene childNodeWithUUID:_nodeAUUID];
    }
    
    if(!_nodeB){
        _nodeB = (CCNode<LHNodePhysicsProtocol>*)[scene childNodeWithUUID:_nodeBUUID];
    }
}

-(CCNode<LHNodePhysicsProtocol>*)nodeA{
    return _nodeA;
}
-(CCNode<LHNodePhysicsProtocol>*)nodeB{
    return _nodeB;
}

-(CGPoint)localAnchorA{
    return CGPointMake( _relativePosA.x*[_nodeA scaleX],
                       -_relativePosA.y*[_nodeA scaleY]);
}
-(CGPoint)localAnchorB{
    return CGPointMake( _relativePosB.x*[_nodeB scaleX],
                       -_relativePosB.y*[_nodeB scaleY]);
}

-(CGPoint)anchorA{
    CGPoint pt = [_nodeA convertToWorldSpaceAR:CGPointMake(_relativePosA.x,
                                                          -_relativePosA.y)];
    
    return [_node convertToNodeSpaceAR:pt];
}

-(CGPoint)anchorB{
    CGPoint pt = [_nodeB convertToWorldSpaceAR:CGPointMake(_relativePosB.x,
                                                          -_relativePosB.y)];
    
    return [_node convertToNodeSpaceAR:pt];
}

-(BOOL)collideConnected{
    return _collideConnected;
}

-(void)removeJoint{
    
    LHScene* scene = (LHScene*)[_node scene];
    if(scene)
    {
        //if we dont have the scene it means the scene was changed so the box2d world will be deleted, deleting the joints also - safe
        //if we do have the scene it means the node was deleted so we need to delete the joint manually
#if LH_USE_BOX2D
        if(_joint){
            LHGameWorldNode* pNode = [scene gameWorldNode];
        
            //if we dont have the scene it means
            b2World* world = [pNode box2dWorld];
            
            if(world){

                _joint->SetUserData(NULL);
                world->DestroyJoint(_joint);
                _joint = NULL;
            }
        }
#else
        if(_joint){
            [_joint tryRemoveFromPhysicsNode:[scene physicsNode]];
            _joint = nil;
        }
#endif
    }
}

#pragma mark - Box2d Support
#if LH_USE_BOX2D
-(void)setJoint:(b2Joint*)val{
    _joint = val;
    _joint->SetUserData(LH_VOID_BRIDGE_CAST(_node));
}
-(b2Joint*)joint{
    return _joint;
}

#pragma mark - Chipmunk Support
#else//chipmunk

-(void)setJoint:(CCPhysicsJoint*)val{
    _joint = val;
}
-(CCPhysicsJoint*)joint{
    return _joint;
}

#endif//LH_USE_BOX2D

@end