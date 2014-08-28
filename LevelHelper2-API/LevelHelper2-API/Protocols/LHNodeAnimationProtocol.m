//
//  LHNodeAnimationProtocol.m
//  LevelHelper2-Cocos2d-V3
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHNodeAnimationProtocol.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHAnimation.h"

@implementation LHNodeAnimationProtocolImp
{
    NSTimeInterval lastTime;
    
    __weak CCNode* _node;
    
    NSMutableArray* _animations;
     __weak LHAnimation* _activeAnimation;
}

-(void)dealloc{
    _node = nil;
    _activeAnimation = nil;
    
    LH_SAFE_RELEASE(_animations);
    LH_SUPER_DEALLOC();
}

+ (instancetype)animationProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    return LH_AUTORELEASED([[self alloc] initAnimationProtocolImpWithDictionary:dict node:nd]);
}

- (instancetype)initAnimationProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;
        _activeAnimation = nil;
        
        NSArray* animsInfo = [dict objectForKey:@"animations"];
        for(NSDictionary* anim in animsInfo){
            if(!_animations){
                _animations = [[NSMutableArray alloc] init];
            }
            LHAnimation* animation = [LHAnimation animationWithDictionary:anim
                                                                     node:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)_node];
            if([animation isActive]){
                _activeAnimation = animation;
            }
            [_animations addObject:animation];
        }
    }
    return self;
}

-(void)visit{
    
    NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
    float dt = thisTime - lastTime;
    
    if(_activeAnimation){
        if(![_node paused] && [_node isRunningInActiveScene])
        {
            [_activeAnimation updateTimeWithDelta:dt];
        }
    }
    
    lastTime = thisTime;
}

-(void)setActiveAnimation:(LHAnimation*)anim{
    _activeAnimation = anim;
    [_activeAnimation setAnimating:YES];
}

-(LHAnimation*)activeAnimation{
    return _activeAnimation;
}
-(LHAnimation*)animationWithName:(NSString*)animName
{
    for(LHAnimation* anim in _animations){
        if([[anim name] isEqualToString:animName]){
            return anim;
        }
    }
    return nil;
}
@end