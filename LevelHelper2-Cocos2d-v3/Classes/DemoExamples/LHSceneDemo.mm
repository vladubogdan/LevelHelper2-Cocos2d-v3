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

@implementation LHSceneDemo

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
    

    CGSize designSize = [[CCDirector sharedDirector] designSize];
    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Previous Demo"];
        button.position = CGPointMake(150, designSize.height - 50);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor redColor]];
        [button setTarget:self selector:@selector(previousDemo)];
        button.exclusiveTouch = NO;
        [[self uiNode]  addChild:button];
    }

    {
        CCButton *button = [CCButton buttonWithTitle:@"Restart"];
        button.position = CGPointMake(designSize.width*0.5, designSize.height - 50);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor redColor]];
        [button setTarget:self selector:@selector(restartDemo)];
        button.exclusiveTouch = NO;
        [[self uiNode]  addChild:button];
    }

    
    {
        CCButton *button = [CCButton buttonWithTitle:@"Next Demo"];
        button.position = CGPointMake(designSize.width - 120, designSize.height - 50);
        button.preferredSize = CGSizeMake(90, 90);
        button.label.fontSize = 32;
        [button setColor:[CCColor redColor]];
        [button setTarget:self selector:@selector(nextDemo)];
        button.exclusiveTouch = NO;
        [[self uiNode]  addChild:button];
    }
    
    // done
	return self;
}

-(void)nextDemo
{
    NSLog(@"DONT USE THIS CLASS DIRECTLY - SUBCLASS");
}
-(void)restartDemo{
    [[CCDirector sharedDirector] replaceScene:[[self class] scene]];
}
-(void)previousDemo
{
    NSLog(@"DONT USE THIS CLASS DIRECTLY - SUBCLASS");
}

@end
