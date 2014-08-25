//
//  LHNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodePhysicsProtocol.h"
/**
 LHNode class is used to load a node object from a level file.
 */


@interface LHNode : CCNode <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


@end
