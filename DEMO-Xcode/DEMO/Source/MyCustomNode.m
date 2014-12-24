//
//  MyCustomNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 25/08/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "MyCustomNode.h"

@implementation MyCustomNode

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
        
        [self addChildRepresentation];
    }
    return self;
}

-(void) addChildRepresentation
{
    CCDrawNode* gw = [CCDrawNode node];
    
    CGSize selfSize = [self contentSize];
    
    [gw drawSegmentFrom:CGPointMake(selfSize.width, 0)
                     to:CGPointMake(selfSize.width, selfSize.height)
                 radius:1
                  color:[CCColor blueColor]];
    
    [gw drawSegmentFrom:CGPointMake(0, 0)
                     to:CGPointMake(0, selfSize.height)
                 radius:1
                  color:[CCColor blueColor]];
    
    [gw drawSegmentFrom:CGPointMake(0, selfSize.height)
                     to:CGPointMake(selfSize.width, selfSize.height)
                 radius:1
                  color:[CCColor blueColor]];

    [gw drawSegmentFrom:CGPointMake(0, 0)
                     to:CGPointMake(selfSize.width, 0)
                 radius:1
                  color:[CCColor blueColor]];

    [self addChild:gw];
}

@end
