//
//  LHSceneSpriteSheetAnimationTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneSpriteSheetAnimationTest.h"

@implementation LHSceneSpriteSheetAnimationTest

+ (LHSceneDemo *)scene
{
	return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/spriteSheetAnimationDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"SPRITE SHEET ANIMATION DEMO\nThe tilt effect is done by animating the rotation."
                                         fontName:@"Arial"
                                         fontSize:24];
    
    
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - 120)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    
    // done
	return self;
}


@end
