//
//  LHSceneBeziersTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneBeziersTest.h"

@implementation LHSceneBeziersTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/beziersDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"BEZIERS DEMO\nBeziers can be used to draw line shapes.\nBy disabling control points you can have part of the bezier as a straight line.\nIn LevelHelper, select a bezier and hold control to edit it.Right click to toggle control points.\nYou can draw the outline of a shape using beziers and then make that outline into a shape."
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
