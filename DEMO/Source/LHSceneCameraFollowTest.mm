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
    CCLabelTTF* ttfZoomLevel;
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

    ttfZoomLevel = [CCLabelTTF labelWithString:@"Zoom 1.0"
                                         fontName:@"Arial"
                                         fontSize:20];
    [ttfZoomLevel setColor:[CCColor blackColor]];
    [ttfZoomLevel setHorizontalAlignment:CCTextAlignmentCenter];
    [ttfZoomLevel setPosition:CGPointMake(self.contentSize.width*0.5,
                                          100)];
    
    [[self uiNode] addChild:ttfZoomLevel];//add the text to the ui element as we dont want it to move with the camera
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Zoom In"];
        button.position = CGPointMake(100, self.contentSize.height - 200);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(zoomIn)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Zoom Out"];
        button.position = CGPointMake(100, self.contentSize.height - 300);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(zoomOut)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Flip Gravity"];
        button.position = CGPointMake(100, self.contentSize.height - 400);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(flipGravity)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    // done
	return self;
}

-(void)update:(CCTime)delta
{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        //this are equivalent way of getting the current camera zoom level
        //[ttfZoomLevel setString:[NSString stringWithFormat:@"Zoom %f", [[self gameWorldNode] scale]]];
        //or
        [ttfZoomLevel setString:[NSString stringWithFormat:@"Zoom %f", [camera zoomValue]]];
    }
}

-(void)zoomOut{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        [camera zoomByValue:-0.5 inSeconds:1];
//        [camera zoomToValue:1 inSeconds:1];
    }
}

-(void)zoomIn{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        [camera zoomByValue:0.5 inSeconds:1];
//        [camera zoomToValue:3 inSeconds:1];
    }
}

-(void)flipGravity
{
    CGPoint curGravity = [self globalGravity];
//    if(didChangeX){
        [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
//        didChangeX = false;
//    }
//    else{
//        didChangeX = true;
//        [self setGlobalGravity:CGPointMake(-curGravity.x, curGravity.y)];
//    }
}


@end
