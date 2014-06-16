//
//  LHSceneJointsTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneJointsTest.h"

@implementation LHSceneJointsTest

+ (LHSceneJointsTest *)scene
{
	return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/level05-joints.plist"];
}

+(LHSceneJointsTest*)sceneWithFile:(NSString*)levelPlistFile
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
    
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Click to remove joints.\n"
                                         fontName:@"Arial"
                                         fontSize:24];
    [ttf setColor:[CCColor blackColor]];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - ttf.contentSize.height)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    
    return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    {
        LHDistanceJointNode* dJointNode = (LHDistanceJointNode*)[self childNodeWithName:@"testDistanceJoint"];
        if(dJointNode){
            NSLog(@"REMOVING THE DISTANCE JOINT %@", [dJointNode name]);
            [dJointNode removeFromParent];
            dJointNode = NULL;
        }
    }
    
    {
        LHRevoluteJointNode* rJointNode = (LHRevoluteJointNode*)[self childNodeWithName:@"RevoluteJoint"];
        if(rJointNode){
            NSLog(@"REMOVING THE REVOLUTE JOINT %@", [rJointNode name]);
            [rJointNode removeFromParent];
            rJointNode = NULL;
        }
    }

    {
        LHPulleyJointNode* pJointNode = (LHPulleyJointNode*)[self childNodeWithName:@"PulleyJoint"];
        if(pJointNode){
            NSLog(@"REMOVING THE PULLEY JOINT %@", [pJointNode name]);
            [pJointNode removeFromParent];
            pJointNode = NULL;
        }
    }

//    CGPoint curGravity = [self globalGravity];
//    [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];

    
//    [[CCDirector sharedDirector] replaceScene:[LHSceneJointsTest scene]];
    
    
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
@end
