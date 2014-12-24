//
//  LHSceneAssetsWithJointsTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneAssetsWithJointsTest.h"

@implementation LHSceneAssetsWithJointsTest
+ (LHSceneDemo *)scene{
//        return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/introductionScene.lhplist"];
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/simpleCar.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    
#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"CAR ASSETS DEMO\nAnother asset demo. This time demonstrating an asset containing joints.\n\nClick to create a new car of a random rotation."
                                         fontName:@"ArialMT"
                                         fontSize:20];
    [ttf setColor:[CCColor blackColor]];
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"CAR ASSETS DEMO\nSorry this demo is not available when using Chipmunk.\nPlease switch to the Box2d target inside Xcode."
                                         fontName:@"ArialMT"
                                         fontSize:20];
    [ttf setColor:[CCColor redColor]];
#endif

    
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5+60)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}

-(float)randomFloat:(float)Min max:(float)Max
{
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

#if __CC_PLATFORM_IOS

#if COCOS2D_VERSION >= 0x00030300
-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
#else
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
#endif//cocos2d_version
{
    
    [self createAssetAtLocation:[touch locationInNode:self]];
    
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
#else
-(void)mouseDown:(NSEvent *)theEvent{
    
    [self createAssetAtLocation:[theEvent locationInNode:self]];
    
    [super mouseDown:theEvent];
}

#endif

-(void)createAssetAtLocation:(CGPoint)location
{
    LHAsset* asset = [LHAsset createWithName:@"myNewAsset"
                               assetFileName:@"PUBLISH_FOLDER/carAsset.lhasset"
                                      parent:[self gameWorldNode]];
    asset.position = location;
    
    //NOTE: you should not scale nodes containig joints or nodes that are connected to joints.
    //The joints will break or will have strange behaviour..
    //The only way to use scale is to scale the node prior creating the joint - so from inside LevelHelper 2 app.
    
    float zRot = [self randomFloat:-60 max:60.0f];
    asset.rotation = zRot;
}

@end
