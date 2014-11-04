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
    float minZoomValue;
    NSTimeInterval zoomStartTime;
    
    BOOL lookingAt;
    BOOL resetingLookAt;
    CGPoint lookAtPosition;
    __weak CCNode* _lookAtNode;
    
    CGPoint startLookAtPosition;
    float lookAtTime;
    NSTimeInterval lookAtStartTime;
    
    BOOL _zoomsOnPinch;

    CGPoint _centerPosition;//camera pos or followed node position (used by resetLookAt)
    CGPoint _viewPosition;//actual camera view position
    
    NSString* _followedNodeUUID;
    __weak CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
}

-(BOOL)wasUpdated{
    return wasUpdated;
}

-(void)dealloc{
    _followedNode = nil;
    _lookAtNode = nil;
    
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
        
        CGRect worldRect = [(LHScene*)[self scene] gameWorldRect];
        
        CGSize worldSize = worldRect.size;
        if(worldSize.width < 0)
            worldSize.width = -worldSize.width;
        
        if(worldSize.height < 0)
            worldSize.height = -worldSize.height;
        
        minZoomValue = 0.1;
        if([self restrictedToGameWorld]){
            if(winSize.width < worldSize.width || winSize.height < worldSize.height){
                if(worldSize.width > worldSize.height){
                    minZoomValue = winSize.height/worldSize.height;
                }
                else{
                    minZoomValue = winSize.width/worldSize.width;
                }
            }
        }
        
        _zoomsOnPinch = [dict boolForKey:@"zoomOnPinchOrScroll"];    
//        float zoomVal = [dict boolForKey:@"zoomValue"];
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
        CGPoint transPoint = [self transformToRestrictivePosition:[self position]];

        LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
        
        if(zooming)
        {
            NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
            float zoomUnit = (currentTimer - zoomStartTime)/reachZoomTime;
            float deltaZoom = startZoomValue + (reachZoomValue - startZoomValue)*zoomUnit;
            
            if(reachZoomValue < minZoomValue){
                reachZoomValue = minZoomValue;
            }
            
            [[(LHScene*)[self scene] gameWorldNode] setScale:deltaZoom];
            
            if(zoomUnit >= 1.0f){
                [[(LHScene*)[self scene] gameWorldNode] setScale:reachZoomValue];
                zooming = false;
            }
        }

        [gwNode setPosition:transPoint];
    }
}

-(CGPoint)transformToRestrictivePosition:(CGPoint)position
{
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];

    CGPoint transPoint = position;
    
    _viewPosition = transPoint;
    _centerPosition = transPoint;
    
    CGSize winSize = [(LHScene*)[self scene] contentSize];
    CGPoint halfWinSize = CGPointMake(winSize.width * 0.5f, winSize.height * 0.5f);

    CCNode* followed = [self followedNode];
    if(followed){

        CGPoint worldPoint = [followed convertToWorldSpaceAR:CGPointZero];
        CGPoint gwNodePos = [gwNode convertToNodeSpaceAR:worldPoint];
        
        _viewPosition = gwNodePos;
        _centerPosition = transPoint;
        
        CGPoint scaledMidpoint = ccpMult(gwNodePos, gwNode.scale);
        transPoint = ccpSub(halfWinSize, scaledMidpoint);
    }
    
    
    
    if(lookingAt)
    {
        NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
        float lookAtUnit = (currentTimer - lookAtStartTime)/lookAtTime;

        if(_lookAtNode)
        {
            LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
            CGPoint worldPoint = [_lookAtNode convertToWorldSpaceAR:CGPointZero];
            lookAtPosition = [gwNode convertToNodeSpaceAR:worldPoint];
        }
        
        float newX = startLookAtPosition.x + (lookAtPosition.x - startLookAtPosition.x)*lookAtUnit;
        float newY = startLookAtPosition.y + (lookAtPosition.y - startLookAtPosition.y)*lookAtUnit;
        CGPoint gwNodePos = CGPointMake(newX, newY);
        
        if(lookAtUnit >= 1.0f){
            gwNodePos = lookAtPosition;
        }
        
        _viewPosition = gwNodePos;
        
        CGPoint scaledMidpoint = ccpMult(gwNodePos, gwNode.scale);
        transPoint = ccpSub(halfWinSize, scaledMidpoint);
        
    }
    
    if(resetingLookAt)
    {
        NSTimeInterval currentTimer = [NSDate timeIntervalSinceReferenceDate];
        float lookAtUnit = (currentTimer - lookAtStartTime)/lookAtTime;
        
        float newX = startLookAtPosition.x + (_centerPosition.x - startLookAtPosition.x)*lookAtUnit;
        float newY = startLookAtPosition.y + (_centerPosition.y - startLookAtPosition.y)*lookAtUnit;
        CGPoint gwNodePos = CGPointMake(newX, newY);
        
        if(lookAtUnit >= 1.0f){
            gwNodePos = lookAtPosition;
            resetingLookAt = false;
            lookingAt = false;
            _lookAtNode = nil;
        }
        
        _viewPosition = gwNodePos;
        
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
    
    return transPoint;
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
        
        if(reachZoomValue < minZoomValue){
            reachZoomValue = minZoomValue;
        }
        zoomStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
}

-(void)zoomToValue:(float)value inSeconds:(float)second
{
    if(_active)
    {
        zooming = true;
        reachZoomTime = second;
        startZoomValue = [[[self scene] gameWorldNode] scale];
        reachZoomValue = value;
        
        if(reachZoomValue < minZoomValue){
            reachZoomValue = minZoomValue;
        }
        zoomStartTime = [NSDate timeIntervalSinceReferenceDate];
    }
}

-(float)zoomValue
{
    return [[[self scene] gameWorldNode] scale];
}

-(void)setZoomValue:(float)val
{
    CGPoint transPoint = [self transformToRestrictivePosition:[self position]];
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    [[(LHScene*)[self scene] gameWorldNode] setScale:val];
    [gwNode setPosition:transPoint];
}


-(void)lookAtPosition:(CGPoint)gwPosition inSeconds:(float)seconds
{
    if(lookingAt == true){
        NSLog(@"Camera is already looking somewhere. Please first reset lookAt by calling resetLookAt");
        return;
    }
    
    lookAtPosition = gwPosition;
    startLookAtPosition = _viewPosition;
    
    lookAtStartTime = [NSDate timeIntervalSinceReferenceDate];
    lookAtTime = seconds;
    lookingAt = true;
}

-(void)lookAtNode:(CCNode*)node inSeconds:(float)seconds
{
    if(lookingAt == true){
        NSLog(@"Camera is already looking somewhere. Please first reset lookAt by calling resetLookAt");
        return;
    }

    _lookAtNode = node;
    
    startLookAtPosition = _viewPosition;
    
    lookAtStartTime = [NSDate timeIntervalSinceReferenceDate];
    lookAtTime = seconds;
    lookingAt = true;
}

-(void)resetLookAt
{
    [self resetLookAtInSeconds:0];
}

-(void)resetLookAtInSeconds:(float)seconds
{
    if(lookingAt != true){
        NSLog(@"[ lookAtPosition: inSeconds:] must be used first. Cannot reset camera look.");
        return;
    }
    
    startLookAtPosition = lookAtPosition;
    
    if(_lookAtNode)
    {
        LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
        CGPoint worldPoint = [_lookAtNode convertToWorldSpaceAR:CGPointZero];
        startLookAtPosition = [gwNode convertToNodeSpaceAR:worldPoint];
        _lookAtNode = nil;
    }
    
    lookAtPosition = _centerPosition;

    lookAtStartTime = [NSDate timeIntervalSinceReferenceDate];
    lookAtTime = seconds;
    lookingAt = true;
    resetingLookAt = true;
}

-(BOOL)isLookingAt{
    return lookingAt;
}

-(void)setUsePinchOrScrollWheelToZoom:(BOOL)value{
    _zoomsOnPinch = value;
}

-(BOOL)usePinchOrScrollWheelToZoom{
    return _zoomsOnPinch;
}

-(void)pinchZoomWithScaleDelta:(float)delta center:(CGPoint)scaleCenter
{
    LHGameWorldNode* gwNode = [[self scene] gameWorldNode];
    
    float newScale = [gwNode scale] + delta;

    if(newScale < minZoomValue){
        newScale = minZoomValue;
    }
    
    scaleCenter = [gwNode convertToNodeSpaceAR:scaleCenter];
    
    CGPoint oldCenterPoint = ccp(scaleCenter.x * gwNode.scale, scaleCenter.y * gwNode.scale);
    gwNode.scale = newScale;
    CGPoint newCenterPoint = ccp(scaleCenter.x * gwNode.scale, scaleCenter.y * gwNode.scale);
    
    CGPoint centerPointDelta = ccpSub(oldCenterPoint, newCenterPoint);
    self.position = ccpAdd(self.position, centerPointDelta);
    
    [self visit];
}



#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required

LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION



@end
