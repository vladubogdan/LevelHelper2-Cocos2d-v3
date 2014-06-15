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
#import "LHConfig.h"
#import "LHAnimation.h"

@implementation LHNode
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
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];

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

- (void)visit
{
    [_animationProtocolImp visit];
    [_physicsProtocolImp visit];
    
    [super visit];
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D

#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
