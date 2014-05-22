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

@implementation LHParallax
{
    NSTimeInterval lastTime;
    
    CGPoint lastPosition;
    
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    NSString* _followedNodeUUID;
    CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* _followedNode;
    
    NSMutableArray* _animations;
    __weak LHAnimation* activeAnimation;

}

-(void)dealloc{
    _followedNode = nil;
    LH_SAFE_RELEASE(_followedNodeUUID);
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_userProperty);
    LH_SAFE_RELEASE(_tags);
    
    LH_SAFE_RELEASE(_animations);
    activeAnimation = nil;

    
    LH_SUPER_DEALLOC();
}


+ (instancetype)parallaxWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initParallaxWithDictionary:dict
                                                             parent:prnt]);
}

- (instancetype)initParallaxWithDictionary:(NSDictionary*)dict
                                    parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
                
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];
    
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        
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
        
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZOrder:z];
                                
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        if(childrenInfo)
        {
            for(NSDictionary* childInfo in childrenInfo)
            {
                CCNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                            parent:self];
#pragma unused (node)
            }
        }

        [self setPosition:pos];
        
        NSString* followedUUID = [dict objectForKey:@"followedNodeUUID"];
        if(followedUUID){
            _followedNodeUUID = [[NSString alloc] initWithString:followedUUID];
        }
        
        [LHUtils createAnimationsForNode:self
                         animationsArray:&_animations
                         activeAnimation:&activeAnimation
                          fromDictionary:dict];

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

-(void)visit
{
    NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
    float dt = thisTime - lastTime;
    
    if(activeAnimation){
        [activeAnimation updateTimeWithDelta:dt];
    }
    
    [self transformLayerPositions];
    
    [super visit];
    
    lastTime = thisTime;
}
-(void)transformLayerPositions
{
    CGPoint parallaxPos = [self position];
    CCNode* followed = [self followedNode];
    if(followed){
        parallaxPos = [followed position];
        
        CGPoint anchor = [followed anchorPoint];
        CGSize content = [followed contentSize];
        
        parallaxPos.x -= content.width*(anchor.x -0.5);
        parallaxPos.y -= content.height*(anchor.y -0.5);

        CGSize winSize = [(LHScene*)[self scene] contentSize];
        
        parallaxPos.x = parallaxPos.x - winSize.width*0.5;
        parallaxPos.y = parallaxPos.y - winSize.height*0.5;
    }
    
    if(CGPointEqualToPoint(lastPosition, CGPointZero)){
        lastPosition = parallaxPos;
    }
    
    if(!CGPointEqualToPoint(lastPosition, parallaxPos))
    {
        CGPoint deltaPos = CGPointMake(parallaxPos.x - lastPosition.x,
                                       parallaxPos.y - lastPosition.y);

        for(LHParallaxLayer* nd in [self children])
        {
            if([nd isKindOfClass:[LHParallaxLayer class]])
            {

                CGPoint curPos = [nd position];
                
                CGPoint pt = CGPointMake(curPos.x + deltaPos.x*(-nd.xRatio),
                                         curPos.y + deltaPos.y*(-nd.yRatio));
                [nd setPosition:pt];
            }
        }
    }
    lastPosition = parallaxPos;
}


#pragma mark LHNodeProtocol Required

-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(CCNode*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any{
    return [LHScene childrenWithTags:tagValues containsAny:any forNode:self];
}


-(NSMutableArray*)childrenOfType:(Class)type{
    return [LHScene childrenOfType:type
                           forNode:self];
}

#pragma mark - LHNodeAnimationProtocol
-(void)setActiveAnimation:(LHAnimation*)anim{
    activeAnimation = anim;
}


@end
