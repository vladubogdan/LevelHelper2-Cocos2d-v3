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

@implementation LHSceneCameraTest

+ (LHSceneCameraTest *)scene
{
	return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/level03-camera.plist"];
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
    
    
    CGPoint curGravity = [self globalGravity];
    
    NSLog(@"CHANGING GRAVITY DIRECTION %f %f", curGravity.x, curGravity.y);
    
    [self setGlobalGravity:CGPointMake(curGravity.x, -curGravity.y)];
    
    [super touchBegan:touch withEvent:event];
}
@end
