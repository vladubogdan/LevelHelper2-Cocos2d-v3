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
    
    
    if(self = [super init]){
        
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
                
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];

        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

        
        
//#if LH_DEBUG
//        CCDrawNode* debug = [CCDrawNode node];
//        [self addChild:debug];
//        [debug setAnchorPoint:CGPointMake(0.5, 0.5)];
//        CGPoint* vertices = new CGPoint[4];
//        vertices[0] = CGPointMake(0, 0);
//        CGSize size = self.contentSize;
//        vertices[1] = CGPointMake(size.width, 0);
//        vertices[2] = CGPointMake(size.width, size.height);
//        vertices[3] = CGPointMake(0, size.height);
//        CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(0, 1, 0, 1)];
//        CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(0, 1, 0, 0.3)];
//        
//        [debug drawPolyWithVerts:vertices
//                           count:4
//                       fillColor:fillColor
//                     borderWidth:1 borderColor:borderColor];
//        
//        delete[] vertices;
//#endif//LH_DEBUG
        
    }
    
    
    
    return self;
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


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
