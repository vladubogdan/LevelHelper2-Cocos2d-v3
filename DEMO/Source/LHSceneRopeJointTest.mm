//
//  LHSceneRopeJointTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneRopeJointTest.h"

@implementation LHSceneRopeJointTest

+ (LHSceneRopeJointTest *)scene
{
	return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/ropeJointDemo.lhplist"];
}
- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"ROPE JOINTS DEMO\nThe left most joint has a bigger z value then the sprites so its draw on top.\nThe middle joint does not use a texture.\nThe right most joint can be cut - Make a line to cut it.\nWatch the console for didCutRopeJoint notification."
                                         fontName:@"Arial"
                                         fontSize:24];
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    return self;
}
-(void)didCutRopeJoint:(LHRopeJointNode *)joint
{
    NSLog(@"DID CUT ROPE JOINT %@", [joint name]);
}

@end
