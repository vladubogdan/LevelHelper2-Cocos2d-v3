//
//  LHSceneUniversalDevicesTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneUniversalDevicesTest.h"

@implementation LHSceneUniversalDevicesTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/devices.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CGSize winSizePixels = [[CCDirector sharedDirector] viewSizeInPixels];
    
    CGSize designSize  = [[CCDirector sharedDirector] designSize];
    
    NSString* txt = [NSString stringWithFormat:@"UNIVERSAL DEVICES DEMO: Win size in pixels %dx%d, Design Size %dx%d", (int)winSizePixels.width, (int)winSizePixels.height, (int)designSize.width, (int)designSize.height];
    
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:txt
                                         fontName:@"Arial"
                                         fontSize:20];
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5-180)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}


@end
