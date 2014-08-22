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

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/level05-joints.lhplist"];
}


- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
    
    
#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"OTHER JOINTS\nClick to remove joints.\n"
                                         fontName:@"Arial"
                                         fontSize:24];
    
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"OTHER JOINTS\nClick to remove joints.\n\nNot all joints are supported when using CHIPMUNK."
                                         fontName:@"Arial"
                                         fontSize:24];
#endif

    
    
    
    [ttf setColor:[CCColor blackColor]];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - ttf.contentSize.height)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
   
    
    return self;
}

#ifdef __CC_PLATFORM_IOS

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    [self handleJoints];

    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}

#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    [self handleJoints];
    [super mouseDown:theEvent];
}
#endif

-(void)handleJoints
{
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
    
    {
        LHWeldJointNode* wJointNode = (LHWeldJointNode*)[self childNodeWithName:@"WeldJoint1"];
        if(wJointNode){
            NSLog(@"REMOVING THE WELD JOINT %@", [wJointNode name]);
            [wJointNode removeFromParent];
            wJointNode = NULL;
        }
    }
    
    {
        LHPrismaticJointNode* pJointNode = (LHPrismaticJointNode*)[self childNodeWithName:@"PrismaticJoint"];
        if(pJointNode){
            NSLog(@"REMOVING THE PRISMATIC JOINT %@", [pJointNode name]);
            [pJointNode removeFromParent];
            pJointNode = NULL;
        }
    }
}

@end
