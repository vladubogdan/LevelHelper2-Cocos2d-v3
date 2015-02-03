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
	return [[self alloc] initWithContentOfFile:@"LH2-Published/example.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */

    {
        CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Welcome to"
                                             fontName:@"ArialMT"
                                             fontSize:40];
        
        [ttf setColor:[CCColor blackColor]];
        [ttf setHorizontalAlignment:CCTextAlignmentCenter];
        [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                     self.contentSize.height*0.5+120)];
        //add the text to the ui element as we dont want it to move with the camera
        [[self uiNode] addChild:ttf];
    }

    {
        CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"LevelHelper 2"
                                             fontName:@"ArialMT"
                                             fontSize:80];
        
        [ttf setColor:[CCColor blackColor]];
        [ttf setHorizontalAlignment:CCTextAlignmentCenter];
        [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                     self.contentSize.height*0.5+60)];
        //add the text to the ui element as we dont want it to move with the camera
        [[self uiNode] addChild:ttf];
    }
    {
        CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Run the DEMO target for examples.\nCheck LHSceneSubclass.mm to learn how to load a level.\nVisit www.gamedevhelper.com for more learn resources."
                                             fontName:@"ArialMT"
                                             fontSize:20];

        [ttf setColor:[CCColor blackColor]];
        [ttf setHorizontalAlignment:CCTextAlignmentCenter];
        [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                     self.contentSize.height*0.5-60)];
        //add the text to the ui element as we dont want it to move with the camera
        [[self uiNode] addChild:ttf];     
    }
    
    
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
