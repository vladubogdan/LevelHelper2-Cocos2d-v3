//
//  LHSceneCharacterAnimationTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneCharacterAnimationTest.h"

@implementation LHSceneCharacterAnimationTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/characterAnimation.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"CHARACTER ANIMATION DEMO\nDemonstrate a character animation.\nThis demo also uses per device positioning.\nChange the device and run this demo again\nto see how the character is placed in a different position on each device.\nPer device positioning is mostly useful for User Interface elements,\nlike a life bar that you always want to be displayed in the top right corner."
                                         fontName:@"Arial"
                                         fontSize:20];
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5+60)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}

#ifdef __CC_PLATFORM_IOS

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    [self tougleAnimation];
    
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
#else

-(void)mouseDown:(NSEvent *)theEvent{
    
//    [self gameWorldNode].paused = ![self gameWorldNode].paused;
    
    [self tougleAnimation];
    
    [super mouseDown:theEvent];
}

#endif

-(void)tougleAnimation{
    LHNode* officerNode = (LHNode*)[self childNodeWithName:@"Officer"];
    if(officerNode){
        LHAnimation* anim = [officerNode activeAnimation];
        [anim setAnimating:![anim animating]];
        NSLog(@"ANIMATION: %@ %@.", [anim animating] ? @"Playing" : @"Pausing", [anim name]);
    }
}


@end
