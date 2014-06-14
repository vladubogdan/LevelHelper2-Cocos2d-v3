//
//  LHNodePhysicsProtocol.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 14/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol LHNodePhysicsProtocol <NSObject>

@end


@interface LHNodePhysicsProtocolImp : NSObject

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;
- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;

@end

#define LH_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION  \
