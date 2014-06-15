//
//  LHBodyScaleTestScene.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHBodyScaleTestScene.h"

@implementation LHBodyScaleTestScene

+ (LHBodyScaleTestScene *)scene
{
	return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/level01.plist"];
//    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/level02-assetTest.plist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
    // done
	return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    {
        LHSprite* spr = (LHSprite*)[self childNodeWithName:@"hat"];
        NSLog(@"SHAPE NODE %@ %f %f", spr, [spr scaleX], [spr scaleY]);
        
        [spr setScaleX:[spr scaleX]+0.1];
        [spr setScaleY:[spr scaleY]+0.2];
    }

    {
        LHSprite* candy = (LHSprite*)[self childNodeWithName:@"candy"];
        NSLog(@"CIRCLE NODE %@ %f X %f", candy, [candy scale], [candy scaleX]);
        [candy setScale:[candy scale]+0.1];
    }


    {
        LHSprite* rectSpr = (LHSprite*)[self childNodeWithName:@"thumb_tack_2"];
        
        NSLog(@"RECT NODE %@ %f X %f", rectSpr, [rectSpr scaleX], [rectSpr scaleY]);
        [rectSpr setScaleX:[rectSpr scaleX]+0.1];
        [rectSpr setScaleY:[rectSpr scaleY]+0.2];
    }

    {
        LHBezier* chainNode = (LHBezier*)[self childNodeWithName:@"UntitledBezier"];

        NSLog(@"CHAIN NODE %@ %f X %f", chainNode, [chainNode scaleX], [chainNode scaleY]);
        [chainNode setScaleX:[chainNode scaleX]+0.1];
        [chainNode setScaleY:[chainNode scaleY]+0.2];
    }
    
}


@end
