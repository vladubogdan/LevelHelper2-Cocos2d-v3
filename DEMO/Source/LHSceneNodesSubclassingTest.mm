//
//  LHSceneNodesSubclassingTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneNodesSubclassingTest.h"

#import "BlueRobotSprite.h"

@implementation LHSceneNodesSubclassingTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/subclassingDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"NODES SUBLCASSING DEMO\nAll node types available in LevelHelper can be subclassed in order to add your own game logic.\nCheck LHSceneNodesSubclassingTest for how to do it.\nBlue robot is of class \"BlueRobotSprite\" while the pink robot is a generic \"LHSprite\" class.\nThe node is of class \"MyCustomNode\" and the blue outline is draw by the custom class."
                                         fontName:@"Arial"
                                         fontSize:20];
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5-180)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}

-(Class)createNodeObjectForSubclassWithName:(NSString *)subclassTypeName superTypeName:(NSString *)superTypeName
{
    //you may ask why doesn't LevelHelper2-API do this - thats because the API does not have access to your own classes. NSClassFromString will return nil if the class in question is not imported in the file where it's executed.
    
    //DO NOT FORGET TO #import your class header.
    return NSClassFromString(subclassTypeName);
}

@end
