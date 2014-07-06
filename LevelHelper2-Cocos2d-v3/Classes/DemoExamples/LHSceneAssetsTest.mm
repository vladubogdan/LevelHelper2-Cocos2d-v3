//
//  LHSceneAssetsTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneAssetsTest.h"

@implementation LHSceneAssetsTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/assetsDemo.plist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"ASSETS DEMO\nAssets are special objects that when edited they will change\nto the new edited state everywhere they are used in your project.\n\nClick to create a new officer (asset) of a random scale and rotation."
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
float randomFloat(float Min, float Max){
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint location = [touch locationInNode:self];
    
    
    LHAsset* asset = [LHAsset createWithName:@"myNewAsset"
                               assetFileName:@"DEMO_PUBLISH_FOLDER/OfficerAsset.lhasset"
                                      parent:[self gameWorldNode]];
    asset.position = location;
    
    asset.scaleX = randomFloat(0.15, 0.8f);
    asset.scaleY = randomFloat(0.15, 0.8f);
    
    float zRot = randomFloat(-45, 45.0f);
    
    asset.rotation = zRot;

    
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}

@end