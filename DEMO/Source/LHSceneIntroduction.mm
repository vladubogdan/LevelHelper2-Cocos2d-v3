//
//  LHSceneIntroduction.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneIntroduction.h"

@implementation LHSceneIntroduction

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/introductionScene.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];
    
    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"INTRODUCTION\nUse the Previous and Next buttons to toggle between demos.\nUse the Restart button to start the current demo again.\nInvestigate each demo source file and LevelHelper document file for more info on how it was done.\nYou can find all scene files in the DEMO_DOCUMENTS\\levels folder.\nYou can find all source files in the DemoExamples folder located under Classes in Xcode.\nFor acurate FPS count use a real device.\n\nGo to AppDelegate.m to set your own starting scene."
                                         fontName:@"Arial"
                                         fontSize:20];
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}


@end
