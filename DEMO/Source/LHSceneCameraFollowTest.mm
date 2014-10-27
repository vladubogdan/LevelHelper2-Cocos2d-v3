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
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"CAMERA FOLLOW DEMO\nDemonstrate a camera following an object (the tire sprite).\nThe camera is restricted and cannot go outside the game world rectangle.\nNotice how on the sides the candy will no longer be in the center and the camera stops following it.\nThe blue sky is added to the Back User Interface so it will always be on screen in the back.\nThis text is added in the Front User Interface node, so it will always be on screen.\n\nClick a position to look at it.\nUse left buttons for more actions."
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
        button.position = CGPointMake(10, self.contentSize.height - 200);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(zoomIn)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Zoom Out"];
        button.position = CGPointMake(10, self.contentSize.height - 250);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(zoomOut)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Reset Zoom"];
        button.position = CGPointMake(10, self.contentSize.height - 300);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(resetZoom)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Flip Gravity"];
        button.position = CGPointMake(10, self.contentSize.height - 350);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(flipGravity)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Reset Look At"];
        button.position = CGPointMake(10, self.contentSize.height - 400);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(resetLookAt)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }

    {
        CCButton *button = [CCButton buttonWithTitle:@"Toggle Follow Wheel"];
        button.position = CGPointMake(10, self.contentSize.height - 450);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        button.label.horizontalAlignment = CCTextAlignmentLeft;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(toggleFollowNode:)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Look At Another Node"];
        button.position = CGPointMake(10, self.contentSize.height - 500);
        button.anchorPoint = CGPointMake(0, 0);
        button.preferredSize = CGSizeMake(120, 50);
        button.label.fontSize = 32;
        button.label.horizontalAlignment = CCTextAlignmentLeft;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(lookAtAnotherNode:)];
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
        
        if([camera isLookingAt])
        {
            [ttfZoomLevel setString:[NSString stringWithFormat:@"Zoom %f\nIs Looking At Something!", [camera zoomValue]]];
        }
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

-(void)resetZoom{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        [camera zoomToValue:1 inSeconds:1];
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

-(IBAction)toggleFollowNode:(CCButton*)sender
{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        if(nil != [camera followedNode])
        {
            [camera followNode:nil];
            [sender setTitle:@"Toggle Follow Node (not following)"];
        }
        else
        {
            LHSprite* carTyre = (LHSprite*)[self childNodeWithName:@"carTyre"];
            [camera followNode:carTyre];
            [sender setTitle:@"Toggle Follow Node (following sprite)"];
        }
    }
}

-(void)resetLookAt
{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        if([camera isLookingAt])
        {
            [camera resetLookAtInSeconds:4];
            [camera zoomByValue:-0.5 inSeconds:4];
        }
    }
}

-(void)lookAtAnotherNode:(CCButton*)sender
{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        if(false == [camera isLookingAt])
        {
            CCNode* lookAtNode = [[self scene] childNodeWithName:@"lookAtTire"];
            [camera lookAtNode:lookAtNode inSeconds:4];
            
            [camera zoomByValue:0.5 inSeconds:4];
        }
    }
}

#ifdef __CC_PLATFORM_IOS
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint touchLocationInGWCoordinates = [[self gameWorldNode] convertToNodeSpaceAR:touchLocation];
    
    [self doLookAtWithGameWorldNodeCoordinate:touchLocationInGWCoordinates];
    
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
#else
-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint touchLocation = [theEvent locationInNode:self];
    CGPoint touchLocationInGWCoordinates = [[self gameWorldNode] convertToNodeSpaceAR:touchLocation];
    
    [self doLookAtWithGameWorldNodeCoordinate:touchLocationInGWCoordinates];
    
    //dont forget to call super
    [super mouseDown:theEvent];
}
#endif

-(void)doLookAtWithGameWorldNodeCoordinate:(CGPoint)touchLocationInGWCoordinates
{
    LHCamera* camera = (LHCamera*)[self childNodeWithName:@"UntitledCamera"];
    if(camera){
        if(false == [camera isLookingAt])
        {
            [camera lookAtPosition:touchLocationInGWCoordinates inSeconds:4];
            [camera zoomByValue:0.5 inSeconds:4];
        }
    }
}


@end
