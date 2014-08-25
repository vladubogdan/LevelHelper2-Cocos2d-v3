//
//  LHBackUINode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
/**
 LHBackUINode class is used to load the UI elements.
 */


@interface LHBackUINode : CCNode <LHNodeProtocol>

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

@end
