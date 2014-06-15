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
    
    LHSprite* spr = (LHSprite*)[self childNodeWithName:@"hat"];

    NSLog(@"TOUCH BEGAN SPR %@ %f %f", spr, [spr scaleX], [spr scaleY]);
    
}

@end
