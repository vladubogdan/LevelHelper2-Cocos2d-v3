//
//  LHSprite.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSprite.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHAnimation.h"

@implementation LHSprite
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{

    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(_physicsProtocolImp);
    
    LH_SUPER_DEALLOC();
}

+ (instancetype)spriteNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initSpriteNodeWithDictionary:dict
                                                               parent:prnt]);
}


- (instancetype)initSpriteNodeWithDictionary:(NSDictionary*)dict
                                      parent:(CCNode*)prnt{

    LHScene* scene = (LHScene*)[prnt scene];
    
    NSString* imagePath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                  folder:[dict objectForKey:@"relativeImagePath"]
                                                  suffix:[scene currentDeviceSuffix:NO]];

    NSString* plistPath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                  folder:[dict objectForKey:@"relativeImagePath"]
                                                  suffix:[scene currentDeviceSuffix:YES]];
    
    CCTexture* texture = [scene textureWithImagePath:imagePath];
    
    CCSpriteFrame* spriteFrame = nil;
    
    NSString* spriteName = [dict objectForKey:@"spriteName"];
    if(spriteName){
        NSString* atlasName = [[plistPath lastPathComponent] stringByDeletingPathExtension];
        atlasName = [[scene relativePath] stringByAppendingPathComponent:atlasName];
        atlasName = [atlasName stringByAppendingPathExtension:@"plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:atlasName texture:texture];
        spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteName];
    }
    else{
        spriteFrame = [texture createSpriteFrame];
    }

    
    
    
    
    if(self = [super initWithSpriteFrame:spriteFrame]){
        
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
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
            #endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }

        [self setColor:[dict colorForKey:@"colorOverlay"]];
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
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
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];        
    }
    return self;
}

-(void)setSpriteFrameWithName:(NSString*)spriteFrame{
//    if(atlas){
//        SKTexture* texture = [atlas textureNamed:spriteFrame];
//        if(texture){
//            [self setTexture:texture];
//            
//            float xScale = [self xScale];
//            float yScale = [self yScale];
//            
//            [self setXScale:1];
//            [self setYScale:1];
//            
//            [self setSize:texture.size];
//            
//            [self setXScale:xScale];
//            [self setYScale:yScale];
//        }
//    }
}

- (void)visit
{
    [_animationProtocolImp visit];
    
    [super visit];
}

#pragma mark - LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required

LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION


@end
