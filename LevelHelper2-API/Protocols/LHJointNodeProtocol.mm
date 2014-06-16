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
#import "LHPhysicsNode.h"
#import "LHConfig.h"

#if LH_USE_BOX2D
#include "Box2D.h"
#else

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wreturn-type-c-linkage"

#import "CCPhysics+ObjectiveChipmunk.h"

#pragma clang diagnostic pop

#endif //LH_USE_BOX2D


@implementation LHJointNodeProtocolImp
{
    __unsafe_unretained CCNode<LHJointNodeProtocol>* _node;
    
    
#if LH_USE_BOX2D
    b2Joint* _joint;
#else
    __unsafe_unretained CCPhysicsJoint* _joint;
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

    LHScene* scene = (LHScene*)[_node scene];
    
    if(scene)
    {
        //if we dont have the scene it means the scene was changed so the box2d world will be deleted, deleting the joints also - safe
        //if we do have the scene it means the node was deleted so we need to delete the joint manually
#if LH_USE_BOX2D
        if(_joint){
            LHPhysicsNode* pNode = [scene gameWorldNode];

            //if we dont have the scene it means
            b2World* world = [pNode box2dWorld];
            
            if(world){
            
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
        
        _relativePosA = [dict pointForKey:@"relativePosA"];
        _relativePosB = [dict pointForKey:@"relativePosB"];
        
        _nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        _nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];

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
    else{
        _nodeA = (CCNode<LHNodePhysicsProtocol>*)[scene childNodeWithUUID:_nodeAUUID];
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
    return CGPointMake( _relativePosA.x,
                       -_relativePosA.y);
}
-(CGPoint)localAnchorB{
    return CGPointMake( _relativePosB.x,
                       -_relativePosB.y);
}

-(CGPoint)anchorA{
    CGPoint pt = [_nodeA convertToWorldSpaceAR:CGPointMake(_relativePosA.x,
                                                          -_relativePosA.y)];
    
    return [_nodeA.parent convertToNodeSpaceAR:pt];
}

-(CGPoint)anchorB{
    CGPoint pt = [_nodeB convertToWorldSpaceAR:CGPointMake(_relativePosB.x,
                                                          -_relativePosB.y)];
    
    return [_nodeB.parent convertToNodeSpaceAR:pt];
}

-(BOOL)collideConnected{
    return _collideConnected;
}

#pragma mark - Box2d Support
#if LH_USE_BOX2D
-(void)setJoint:(b2Joint*)val{
    _joint = val;
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