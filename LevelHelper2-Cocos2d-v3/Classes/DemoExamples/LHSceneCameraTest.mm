//
//  LHSceneCameraTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneCameraTest.h"
#import "LHSceneJointsTest.h"
#import "LHBodyScaleTestScene.h"

@implementation LHSceneCameraTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/tst.plist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"CAMERA DEMO\nTouch to change the gravity.\nThis text is added as a UI element (will not move with camera)."
                                         fontName:@"Arial"
                                         fontSize:24];
    [ttf setColor:[CCColor blackColor]];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - ttf.contentSize.height)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    
    CGPoint curGravity = [self globalGravity];
    
    NSLog(@"CHANGING GRAVITY DIRECTION %f %f", curGravity.x, curGravity.y);
    
    [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
    
    [super touchBegan:touch withEvent:event];
}

-(void)previousDemo{
    [[CCDirector sharedDirector] replaceScene:[LHBodyScaleTestScene scene]];
}
-(void)nextDemo{
    [[CCDirector sharedDirector] replaceScene:[LHSceneJointsTest scene]];
}
@end
