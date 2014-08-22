//
//  NSDictionary+LHDictionary.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 25/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cocos2d.h"

@class CCColor;

@interface NSDictionary (LHDictionary)

-(float)    floatForKey:(NSString*)key;
-(int)      intForKey:(NSString*)key;
-(bool)     boolForKey:(NSString*)key;
-(CGPoint)  pointForKey:(NSString*)key;
-(CGRect)   rectForKey:(NSString*)key;
-(CGSize)   sizeForKey:(NSString*)key;
-(CCColor*) colorForKey:(NSString*)key;
-(NSString*)stringForKey:(id)key;

@end
