//
//  LHSceneCameraFollowTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneCameraFollowTest.h"

@implementation LHSceneCameraFollowTest
{
    BOOL didChangeX;
}
+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/cameraFollowDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"CAMERA FOLLOW DEMO\nDemonstrate a camera following an object (the tire sprite).\nThe camera is restricted and cannot go outside the game world rectangle.\nNotice how on the sides the candy will no longer be in the center and the camera stops following it.\nThe blue sky is added to the Back User Interface so it will always be on screen in the back.\nThis text is added in the Front User Interface node, so it will always be on screen.\n\nClick to change the gravity direction."
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

#ifdef __CC_PLATFORM_IOS
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint curGravity = [self globalGravity];
    if(didChangeX){
        [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
        didChangeX = false;
    }
    else{
        didChangeX = true;
        [self setGlobalGravity:CGPointMake(-curGravity.x, curGravity.y)];
    }


    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
#else
-(void)mouseDown:(NSEvent *)theEvent{

    CGPoint curGravity = [self globalGravity];
    if(didChangeX){
        [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
        didChangeX = false;
    }
    else{
        didChangeX = true;
        [self setGlobalGravity:CGPointMake(-curGravity.x, curGravity.y)];
    }
    
    
    //dont forget to call super
    [super mouseDown:theEvent];
}
#endif

@end
