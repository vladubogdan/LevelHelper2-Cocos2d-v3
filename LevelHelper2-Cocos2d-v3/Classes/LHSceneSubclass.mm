//
//  IntroScene.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneSubclass.h"

//THIS CLASS SERVERS AS AN EXAMPLE ON HOW TO SUBCLASS LHSCENE
//YOU CAN LOOK IN THE DemoExamples for more

@implementation LHSceneSubclass

+ (LHSceneSubclass *)scene
{
	return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/level01.plist"];
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

#if __CC_PLATFORM_IOS

#if COCOS2D_VERSION >= 0x00030300
-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
#else
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
#endif//cocos2d_version
{
    
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}

#endif


@end
