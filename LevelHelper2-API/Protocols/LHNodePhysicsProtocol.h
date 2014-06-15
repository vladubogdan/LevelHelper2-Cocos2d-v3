//
//  LHNodePhysicsProtocol.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 14/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LHConfig.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2Body;
#endif
#endif //LH_USE_BOX2D

@protocol LHNodePhysicsProtocol <NSObject>

@end


@interface LHNodePhysicsProtocolImp : NSObject

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;
- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;

#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2Body*)body;
-(CGAffineTransform)nodeTransform;
-(CGAffineTransform)absoluteTransform;
-(void)updateTransform;
-(void)updateScale;
#endif
#endif //LH_USE_BOX2D


@end

#define LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION  \
- (CGAffineTransform)nodeToParentTransform \
{\
    if([_physicsProtocolImp body])\
        _transform = [_physicsProtocolImp nodeTransform];\
        \
        return [super nodeToParentTransform];\
}\
-(void)setPosition:(CGPoint)position\
{\
    [super setPosition:position];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateTransform];\
    }\
}\
-(void)setRotation:(float)rotation\
{\
    [super setRotation:rotation];\
    if([_physicsProtocolImp body]){\
        [_physicsProtocolImp updateTransform];\
    }\
}