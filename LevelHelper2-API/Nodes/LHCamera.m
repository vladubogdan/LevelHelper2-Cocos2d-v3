//
//  LHCamera.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHCamera.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHAnimation.h"

@implementation LHCamera
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    BOOL _active;
    BOOL _restricted;
    
    NSString* _followedNodeUUID;
    __weak CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
}

-(void)dealloc{
    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);

    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);

    LH_SUPER_DEALLOC();
}


+ (instancetype)cameraWithDictionary:(NSDictionary*)dict
                              parent:(CCNode *)prnt{
    return LH_AUTORELEASED([[self alloc] initCameraWithDictionary:dict
                                                           parent:prnt]);
}

- (instancetype)initCameraWithDictionary:(NSDictionary*)dict
                                   parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            
#if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
#else
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        _active = [dict boolForKey:@"activeCamera"];
        _restricted = [dict boolForKey:@"restrictToGameWorld"];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

    }
    
    return self;
}

-(BOOL)isActive{
    return _active;
}
-(void)resetActiveState{
    _active = NO;
}
-(void)setActive:(BOOL)value{
    
    NSMutableArray* cameras = [(LHScene*)[self scene] childrenOfType:[LHCamera class]];
    for(LHCamera* cam in cameras){
        [cam resetActiveState];
    }
    _active = value;
    [self setSceneView];
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

-(BOOL)restrictedToGameWorld{
    return _restricted;
}
-(void)setRestrictedToGameWorld:(BOOL)val{
    _restricted = val;
}

-(void)setPosition:(CGPoint)position{
    [super setPosition:[self transformToRestrictivePosition:position]];
}

-(void)setSceneView{
    if(_active)
    {
        CGPoint transPoint = [self transformToRestrictivePosition:[self position]];
        [[self scene] setPosition:transPoint];
    }
}

-(CGPoint)transformToRestrictivePosition:(CGPoint)position
{
    CCNode* followed = [self followedNode];
    if(followed){
        position = [followed position];

        CGPoint anchor = [followed anchorPoint];
        CGSize content = [followed contentSize];
        
        position.x -= content.width*(anchor.x -0.5);
        position.y -= content.height*(anchor.y -0.5);
    }

    CGSize winSize = [(LHScene*)[self scene] contentSize];
    CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];

    
    float x = position.x;
    float y = position.y;
    
    if(!CGRectEqualToRect(CGRectZero, worldRect) && [self restrictedToGameWorld]){
        
        if(x > (worldRect.origin.x + worldRect.size.width)*0.5){
            x = MIN(x, worldRect.origin.x + worldRect.size.width - winSize.width *0.5);
        }
        else{
            x = MAX(x, worldRect.origin.x + winSize.width *0.5);
        }
        
        y = MIN(y, worldRect.origin.y + worldRect.size.height - winSize.height*0.5);
        y = MAX(y, worldRect.origin.y + winSize.height*0.5);
    }
    
    CGPoint pt = CGPointMake(winSize.width*0.5-x,
                             winSize.height*0.5-y);
    
    return pt;
}

-(void)visit
{
    if(![self isActive])return;
    
    [_animationProtocolImp visit];

    if([self followedNode]){
        CGPoint pt = [self transformToRestrictivePosition:[[self followedNode] position]];
        [self setPosition:pt];
    }
    [self setSceneView];
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required

LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION



@end
