//
//  LHSceneDemo.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneDemo.h"
#import "LevelHelper2-API/LHUtils.h"

#import "LHSceneIntroduction.h"
#import "LHSceneCameraTest.h"
#import "LHSceneCameraFollowTest.h"
#import "LHSceneParallaxTest.h"
#import "LHSceneJointsTest.h"
#import "LHSceneRopeJointTest.h"
#import "LHSceneGearJointsTest.h"
#import "LHSceneBodyScaleTest.h"
#import "LHSceneCharacterAnimationTest.h"
#import "LHSceneAssetsTest.h"
#import "LHSceneWaterAreaTest.h"
#import "LHSceneCarTest.h"
#import "LHSceneGravityAreasTest.h"
#import "LHSceneSpriteSheetAnimationTest.h"
#import "LHSceneShapesTest.h"
#import "LHSceneBeziersTest.h"
#import "LHSceneCollisionFilteringTest.h"
#import "LHSceneCollisionHandlingTest.h"
#import "LHSceneUserPropertiesTest.h"
#import "LHSceneAssetsWithJointsTest.h"
#import "LHSceneRemoveOnCollisionTest.h"
#import "LHSceneNodesSubclassingTest.h"

#import "LHSceneUniversalDevicesTest.h"

@implementation LHSceneDemo
{
    NSMutableArray* availableScenes;
}
-(void)dealloc{
    LH_SAFE_RELEASE(availableScenes);
    LH_SUPER_DEALLOC();
}

+ (LHSceneDemo *)scene{
    NSLog(@"DONT USE THIS CLASS DIRECTLY - SUBCLASS");
    return nil;
}
+ (LHSceneDemo *)sceneWithContentOfFile:(NSString*)plistFile{
	return [[self alloc] initWithContentOfFile:plistFile];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    availableScenes = [[NSMutableArray alloc] init];
    
    [availableScenes addObject:[LHSceneIntroduction class]];
    
    [availableScenes addObject:[LHSceneUniversalDevicesTest class]];
    
    [availableScenes addObject:[LHSceneNodesSubclassingTest class]];
    
    [availableScenes addObject:[LHSceneCameraTest class]];
    [availableScenes addObject:[LHSceneCameraFollowTest class]];
    [availableScenes addObject:[LHSceneParallaxTest class]];
    [availableScenes addObject:[LHSceneCharacterAnimationTest class]];

    [availableScenes addObject:[LHSceneRopeJointTest class]];
    
    [availableScenes addObject:[LHSceneAssetsTest class]];
    [availableScenes addObject:[LHSceneAssetsWithJointsTest class]];

//    [availableScenes addObject:[LHSceneCarTest class]];
//    [availableScenes addObject:[LHSceneJointsTest class]];
    [availableScenes addObject:[LHSceneGearJointsTest class]];

    [availableScenes addObject:[LHSceneCollisionFilteringTest class]];
    [availableScenes addObject:[LHSceneWaterAreaTest class]];
    [availableScenes addObject:[LHSceneGravityAreasTest class]];

    [availableScenes addObject:[LHSceneSpriteSheetAnimationTest class]];
    [availableScenes addObject:[LHSceneShapesTest class]];
    [availableScenes addObject:[LHSceneBeziersTest class]];
    [availableScenes addObject:[LHSceneCollisionHandlingTest class]];
    [availableScenes addObject:[LHSceneRemoveOnCollisionTest class]];    
    [availableScenes addObject:[LHSceneUserPropertiesTest class]];
    
    //body scale
    //body positioning
    //body transformations
    
    //collision filtering test
    
    //collision handling test
    //should collide test
    
    //animation delegate test
    
//    [availableScenes addObject:[LHSceneBodyScaleTest class]];
    

    {
        NSInteger demoIdx = [availableScenes indexOfObject:[self class]];
        
        CCLabelTTF* ttf = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Demo %d/%d",(int)demoIdx+1, (int)[availableScenes count]]
                                             fontName:@"Arial"
                                             fontSize:22];
        [ttf setColor:[CCColor blackColor]];
        [ttf setHorizontalAlignment:CCTextAlignmentLeft];
        [ttf setPosition:CGPointMake(60,
                                     self.contentSize.height - 50)];

        [[self uiNode]  addChild:ttf];
    }

    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Previous Demo"];
        button.position = CGPointMake(self.contentSize.width*0.5 - 200, self.contentSize.height - 50);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(previousDemo)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }

    {
        CCButton *button = [CCButton buttonWithTitle:@"Restart"];
        button.position = CGPointMake(self.contentSize.width*0.5, self.contentSize.height - 50);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(restartDemo)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }

    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Next Demo"];
        button.position = CGPointMake(self.contentSize.width*0.5 + 200, self.contentSize.height - 50);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor magentaColor]];
        [button setTarget:self selector:@selector(nextDemo)];
        button.exclusiveTouch = YES;
        [[self uiNode]  addChild:button];
    }
    
    // done
	return self;
}

-(void)restartDemo{
    [[CCDirector sharedDirector] replaceScene:[[self class] scene]];
}

-(void)previousDemo{
    
    int idx = 0;
    for(Class cls in availableScenes)
    {
        if(cls == [self class])
        {
            int nextIdx = idx-1;
            if(nextIdx < 0){
                nextIdx = (int)[availableScenes count] -1;
            }
            
            if(0 <= nextIdx && nextIdx < [availableScenes count] )
            {
                Class goTo = [availableScenes objectAtIndex:nextIdx];
                [[CCDirector sharedDirector] replaceScene:[goTo scene]];
            }
        }
        ++idx;
    }
}

-(void)nextDemo{
    
    int idx = 0;
    for(Class cls in availableScenes)
    {
        if(cls == [self class])
        {
            int nextIdx = idx+1;
            if(nextIdx >= [availableScenes count]){
                nextIdx = 0;
            }
            
            if(0 <= nextIdx && nextIdx < [availableScenes count] )
            {
                Class goTo = [availableScenes objectAtIndex:nextIdx];
                [[CCDirector sharedDirector] replaceScene:[goTo scene]];
            }
        }
        ++idx;
    }
}

@end
