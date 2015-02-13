//
//  LHSceneSkeletalCharacterTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneSkeletalCharacterTest.h"

@implementation LHSceneSkeletalCharacterTest
+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/skeletalCharacter.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    
//#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Skeletal Character Setup.\n"
                                         fontName:@"ArialMT"
                                         fontSize:20];
//#else
//    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"ASSETS DEMO\nAssets are special objects that when edited they will change\nto the new edited state everywhere they are used in your project.\n\nClick to create a new officer (asset) of a random scale and rotation.\n\nChipmunk detected:\nSorry but currently Cocos2d has a bug where it does not update children physics body position.\nWhen using Chipmunk and having physics bodies on children of node transformations will not work correctly.\nSwitch to the Box2d target for correct physics transformations."
//                                         fontName:@"ArialMT"
//                                         fontSize:20];
//#endif

    
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5+60)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}





@end
