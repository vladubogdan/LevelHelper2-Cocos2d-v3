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
#import "LHConfig.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix:(BOOL)keep2x;
@end


@implementation LHSprite
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}


-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
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
        
        [self setColor:[dict colorForKey:@"colorOverlay"]];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];        
    }
    return self;
}

-(void)setSpriteFrameWithName:(NSString*)spriteFrameName{
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
    if(spriteFrame){
        [self setSpriteFrame:spriteFrame];
    }
}

- (void)visit
{
    [_physicsProtocolImp visit];
    [_animationProtocolImp visit];
    
    [super visit];
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION



#pragma mark - LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION


@end
