//
//  LHNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHNode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"

#import "LHAnimation.h"

@implementation LHNode
{
    NSTimeInterval  lastTime;

    LHNodeProtocolImpl* _nodeProtocolImp;
    
    NSMutableArray* _animations;
    __weak LHAnimation* activeAnimation;
}

-(void)dealloc{
    activeAnimation = nil;
    LH_SAFE_RELEASE(_animations);

    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initNodeWithDictionary:dict
                                                         parent:prnt]);
}

- (instancetype)initNodeWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        
        self.contentSize = [dict sizeForKey:@"size"];
        
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
        
        float alpha = [dict floatForKey:@"alpha"];
        [self setOpacity:alpha/255.0f];
        
        float rot = [dict floatForKey:@"rotation"];
        [self setRotation:rot];
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZOrder:z];
        
        [LHUtils loadPhysicsFromDict:[dict objectForKey:@"nodePhysics"]
                             forNode:self];

        CGPoint scl = [dict pointForKey:@"scale"];
        [self setScaleX:scl.x];
        [self setScaleY:scl.y];
        
        CGPoint anchor = [dict pointForKey:@"anchor"];
        anchor.y = 1.0f - anchor.y;
        [self setAnchorPoint:anchor];
        
        [self setPosition:pos];
        
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
        
        [LHUtils createAnimationsForNode:self
                         animationsArray:&_animations
                         activeAnimation:&activeAnimation
                          fromDictionary:dict];

    }
    
    return self;
}

- (void)visit
{
    NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
    float dt = thisTime - lastTime;
    
    if(activeAnimation){
        [activeAnimation updateTimeWithDelta:dt];
    }
    
    [super visit];
    
    lastTime = thisTime;
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol
-(void)setActiveAnimation:(LHAnimation*)anim{
    activeAnimation = anim;
}
@end
