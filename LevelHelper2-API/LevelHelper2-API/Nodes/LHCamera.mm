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
#import "LHGameWorldNode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end


@implementation LHCamera
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    BOOL wasUpdated;
    
    BOOL _active;
    BOOL _restricted;
    
    BOOL zooming;
    float startZoomValue;
    float reachZoomValue;
    float reachZoomTime;
    NSTimeInterval zoomStartTime;
    
    
    NSString* _followedNodeUUID;
    __weak CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
}

-(BOOL)wasUpdated{
    return wasUpdated;
}

-(void)dealloc{
    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);

    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);

    LH_SUPER_DEALLOC();
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                              parent:(CCNode *)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                           parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        wasUpdated = false;
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        _active     = [dict boolForKey:@"activeCamera"];
        _restricted = [dict boolForKey:@"restrictToGameWorld"];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

        CGPoint newPos = [self position];
        CGSize winSize = [[self scene] contentSize];
        newPos = CGPointMake(winSize.width*0.5  - newPos.x,
                             winSize.height*0.5 - newPos.y);

        [super setPosition:[self transformToRestrictivePosition:newPos]];
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
    if(_active){
        [super setPosition:[self transformToRestrictivePosition:position]];
    }
    else{
        [super setPosition:position];
    }
}

-(void)setSceneView{
    if(_active)
    {
        CGPoint originalTransformed = [self transformToRestrictivePosition:[self position]];
        CGPoint transPoint = originalTransformed;
        
        LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
        
        CGSize winSize = [(LHScene*)[self scene] contentSize];

        if(zooming)
        {
            NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
            float zoomUnit = (currentTimer - zoomStartTime)/reachZoomTime;
            float deltaZoom = startZoomValue + (reachZoomValue - startZoomValue)*zoomUnit;
            [[(LHScene*)[self scene] gameWorldNode] setScale:deltaZoom];
            
            if(zoomUnit >= 1.0f){
                zooming = false;
            }
        }
        
        
        CCNode* followed = [self followedNode];
        if(followed){
            
            CGPoint halfWinSize = CGPointMake(winSize.width * 0.5f, winSize.height * 0.5f);
            
            CGPoint worldPoint = [followed convertToWorldSpaceAR:CGPointZero];
            CGPoint gwNodePos = [gwNode convertToNodeSpaceAR:worldPoint];

            CGPoint scaledMidpoint = ccpMult(gwNodePos, gwNode.scale);
            transPoint = ccpSub(halfWinSize, scaledMidpoint);
        }
        
        float x = transPoint.x;
        float y = transPoint.y;
        
        CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];
        
        worldRect.origin.x *= gwNode.scale;
        worldRect.origin.y *= gwNode.scale;
        worldRect.size.width *= gwNode.scale;
        worldRect.size.height *= gwNode.scale;

        if(!CGRectEqualToRect(CGRectZero, worldRect) && [self restrictedToGameWorld]){
            
            x = MAX(x, winSize.width*0.5 - (worldRect.origin.x + worldRect.size.width - winSize.width *0.5));
            x = MIN(x, winSize.width*0.5 - (worldRect.origin.x + winSize.width *0.5));
            
            y = MIN(y, winSize.height*0.5 - (worldRect.origin.y + worldRect.size.height + (winSize.height*0.5)));
            y = MAX(y, winSize.height*0.5 - (worldRect.origin.y - winSize.height*0.5));
        }
        
        transPoint.x = x;
        transPoint.y = y;


        [gwNode setPosition:transPoint];
    }
}

-(CGPoint)transformToRestrictivePosition:(CGPoint)position
{
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    float scale = [gwNode scale];

    CCNode* followed = [self followedNode];
    if(followed){
        position = [followed convertToWorldSpaceAR:CGPointZero];
        gwNode.scale = 1.0f;
        position = [[[self scene] gameWorldNode] convertToNodeSpaceAR:position];
        gwNode.scale = scale;
    }

    CGSize winSize = [(LHScene*)[self scene] contentSize];
    CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];

    float x = position.x;
    float y = position.y;

//    worldRect.origin.x *= scale;
//    worldRect.origin.y *= scale;
//    worldRect.size.width *= scale;
//    worldRect.size.height *= scale;

    if(!CGRectEqualToRect(CGRectZero, worldRect) && [self restrictedToGameWorld]){
        
        if(x > (worldRect.origin.x + worldRect.size.width)*0.5){
            x = MIN(x, worldRect.origin.x + worldRect.size.width - winSize.width *0.5);
        }
        else{
            x = MAX(x, worldRect.origin.x + winSize.width *0.5);
        }
        
        y = MAX(y, worldRect.origin.y + worldRect.size.height + winSize.height*0.5);
        y = MIN(y, worldRect.origin.y - winSize.height*0.5);
    }
    
    
    CGPoint pt = CGPointMake(winSize.width*0.5 - x,
                             winSize.height*0.5- y);
    
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
    
     wasUpdated = true;
}

-(void)zoomByValue:(float)value inSeconds:(float)second
{
    if(_active)
    {
        zooming = true;
        reachZoomTime = second;
        startZoomValue = [[[self scene] gameWorldNode] scale];
        reachZoomValue = value + startZoomValue;
        zoomStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required

LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION



@end
