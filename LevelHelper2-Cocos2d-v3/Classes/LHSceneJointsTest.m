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
    
    // done
	return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    LHDistanceJointNode* dJointNode = (LHDistanceJointNode*)[self childNodeWithName:@"testDistanceJoint"];
    if(dJointNode){
        NSLog(@"REMOVING THE DISTANCE JOINT %@", [dJointNode name]);
        [dJointNode removeFromParent];
        dJointNode = NULL;
    }
    
//    [[CCDirector sharedDirector] replaceScene:[LHSceneJointsTest scene]];
    

    
    //[super touchBegan:touch withEvent:event];
}
@end
