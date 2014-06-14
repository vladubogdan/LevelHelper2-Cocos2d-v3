//
//  LHParallaxLayer.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHParallaxLayer.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHParallax.h"

@implementation LHParallaxLayer
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    
    float _xRatio;
    float _yRatio;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SUPER_DEALLOC();
}


+ (instancetype)parallaxLayerWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initParallaxLayerWithDictionary:dict
                                                                  parent:prnt]);
}

- (instancetype)initParallaxLayerWithDictionary:(NSDictionary*)dict
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
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZOrder:z];
        
        _xRatio = [dict floatForKey:@"xRatio"];
        _yRatio = [dict floatForKey:@"yRatio"];

        
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
    }
    
    return self;
}

-(float)xRatio{
    return _xRatio;
}

-(float)yRatio{
    return _yRatio;
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
