//
//  LHSceneBodyScaleTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneBodyScaleTest.h"

@implementation LHSceneBodyScaleTest

+ (LHSceneBodyScaleTest *)scene
{
	return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/level01.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
    
    
#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"PHYSICS SCALE DEMO\nTest physics body scaling.\nTouch left side to scale objects down.\nTouch right side to scale objects up."
                                         fontName:@"Arial"
                                         fontSize:24];
    
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"PHYSICS SCALE DEMO\nTest physics body scaling.\nTouch left side to scale objects down.\nTouch right side to scale objects up.\nWhen using Chipmunk scale is done using Cocos2d API (does not work correctly\n check Box2d example for difference)."
                                         fontName:@"Arial"
                                         fontSize:24];
#endif

    
    [ttf setColor:[CCColor whiteColor]];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - ttf.contentSize.height)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    // done
	return self;
}

#ifdef __CC_PLATFORM_IOS

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint pt = [touch locationInNode:self];
    [self scaleSpritesAtPoint:pt];
    
    [super touchBegan:touch withEvent:event];
}

#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint pt = [theEvent locationInNode:self];
    [self scaleSpritesAtPoint:pt];
    
    [super mouseDown:theEvent];
}

#endif

-(void)scaleSpritesAtPoint:(CGPoint)pt
{
    CGSize size = [[CCDirector sharedDirector] designSize];
    
    float scale = 0.2;
    
    if(pt.x < size.width*0.5)
        scale = -0.2;
    
    
    {
        LHSprite* spr = (LHSprite*)[self childNodeWithName:@"hat"];
        NSLog(@"SHAPE NODE %@ %f %f", spr, [spr scaleX], [spr scaleY]);
        
        [spr setScaleX:[spr scaleX]+scale];
        [spr setScaleY:[spr scaleY]+scale];
    }
    
    {
        LHSprite* candy = (LHSprite*)[self childNodeWithName:@"candy"];
        NSLog(@"CIRCLE NODE %@ %f X %f", candy, [candy scale], [candy scaleX]);
        [candy setScale:[candy scale]+scale];
    }
    
    
    {
        LHSprite* rectSpr = (LHSprite*)[self childNodeWithName:@"thumb_tack_2"];
        
        NSLog(@"RECT NODE %@ %f X %f", rectSpr, [rectSpr scaleX], [rectSpr scaleY]);
        [rectSpr setScaleX:[rectSpr scaleX]+scale];
        [rectSpr setScaleY:[rectSpr scaleY]+scale];
    }
    
}

@end
