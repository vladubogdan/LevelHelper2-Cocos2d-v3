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


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                         parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    if(self = [super init]){
                
        [prnt addChild:self];
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
                
        _xRatio = [dict floatForKey:@"xRatio"];
        _yRatio = [dict floatForKey:@"yRatio"];

        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
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
