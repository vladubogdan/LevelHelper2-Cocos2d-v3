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
	return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/level06-ropeJoint.plist"];
}

+(LHSceneRopeJointTest*)sceneWithFile:(NSString*)levelPlistFile
{
    return [[self alloc] initWithContentOfFile:levelPlistFile];
}
- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Make a line to cut the rope joint."
                                         fontName:@"Arial"
                                         fontSize:24];
    [ttf setColor:[CCColor blackColor]];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - ttf.contentSize.height)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    
    return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
//    CGPoint curGravity = [self globalGravity];
//    [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];

    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
@end
