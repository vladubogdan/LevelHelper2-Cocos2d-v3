//
//  LHParallax.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHParallax.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHParallaxLayer.h"
#import "LHAnimation.h"
#import "LHGameWorldNode.h"
#import "LHUINode.h"
#import "LHCamera.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end

@interface LHCamera (LH_PARALLAX_FOLLOW_CAMERA_CHECK)
-(BOOL)wasUpdated;
@end

@interface LHParallaxLayer (LH_PARALLAX_DELTA_MOVEMENT)
-(CGPoint)initialPosition;
@end


@implementation LHParallax
{
    CGPoint lastPosition;
    
    LHNodeProtocolImpl* _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    NSString* _followedNodeUUID;
    __weak CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
    CGPoint initialPosition;
}

-(void)dealloc{
    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                         parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
                
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
    }
    
    return self;
}

-(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode{
    if(_followedNodeUUID && _followedNode == nil){
        _followedNode = (CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(LHScene*)[self scene] childNodeWithUUID:_followedNodeUUID];
        if(_followedNode){
            LH_SAFE_RELEASE(_followedNodeUUID);
        }
    }
    return _followedNode;
}
-(void)followNode:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node{
    _followedNode = node;
}

-(void)transformLayerPositions
{
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    
    float oldScale = gwNode.scale;
    gwNode.scale = 1.0f;
    
    CGPoint parallaxPos = [self position];
    CCNode* followed = [self followedNode];
    if(followed){
        
        if([followed isKindOfClass:[LHCamera class]]){
            if(![(LHCamera*)followed wasUpdated])return;
        }
        
        CGPoint worldPoint = [followed convertToWorldSpaceAR:CGPointZero];
        
        if([followed isKindOfClass:[LHCamera class]]){

            [(LHCamera*)followed setZoomValue:1];
            
            CGSize winSize = [(LHScene*)[self scene] contentSize];
            worldPoint = CGPointMake(winSize.width*0.5, winSize.height*0.5);
        }
        
        parallaxPos = [gwNode convertToNodeSpaceAR:worldPoint];
    }
    
    if(CGPointEqualToPoint(initialPosition, CGPointZero)){
        initialPosition = parallaxPos;
    }
    
    
    if(!CGPointEqualToPoint(lastPosition, parallaxPos))
    {
        CGPoint deltaPos = CGPointMake(initialPosition.x - parallaxPos.x,
                                       initialPosition.y - parallaxPos.y);
        
        for(LHParallaxLayer* nd in [self children])
        {
            if([nd isKindOfClass:[LHParallaxLayer class]])
            {
                CGPoint initialPos = [nd initialPosition];
                
                CGPoint pt = CGPointMake(initialPos.x - deltaPos.x*(nd.xRatio),
                                         initialPos.y - deltaPos.y*(nd.yRatio));
                [nd setPosition:pt];
            }
        }
    }
    
    lastPosition = parallaxPos;
    
    gwNode.scale = oldScale;
    if(followed&& [followed isKindOfClass:[LHCamera class]]){
        [(LHCamera*)followed setZoomValue:oldScale];
    }
}

-(void)lateLoading{
    [self followedNode];//find the followed node if any
}

#if COCOS2D_VERSION >= 0x00030300
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    [_animationProtocolImp visit];
    [self transformLayerPositions];
    
    if(renderer)
        [super visit:renderer parentTransform:parentTransform];
}
#else
- (void)visit
{
    [_animationProtocolImp visit];
    [self transformLayerPositions];
    [super visit];

}
#endif//cocos2d_version


#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required

LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION



@end
