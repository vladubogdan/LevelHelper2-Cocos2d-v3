//
//  BlueRobotSprite.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 25/08/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "BlueRobotSprite.h"
#import "cocos2d.h"

@implementation BlueRobotSprite

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt{
    
    self = [super initWithDictionary:dict parent:prnt];
    if(self)
    {
        //init your content here
        NSLog(@"Did create object of type %@ with name %@", NSStringFromClass([self class]), [self name]);
    }
    return self;
}



@end
