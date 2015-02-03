//
//  LHSceneOnTheFlySpritesWithPhysicsTest.mm
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneOnTheFlySpritesWithPhysicsTest.h"

@implementation LHSceneOnTheFlySpritesWithPhysicsTest
+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/emptyLevel.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"ON THE FLY SPRITES DEMO\nClick to create a sprite with a physics body as defined in the\nLevelHelper 2 Sprite Packer & Physics Editor tool."
                                         fontName:@"ArialMT"
                                         fontSize:20];

    
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5+60)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    // done
	return self;
}

#if __CC_PLATFORM_IOS

#if COCOS2D_VERSION >= 0x00030300
-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
#else
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
#endif//cocos2d_version
{

    CGPoint location = [touch locationInNode:self];
    
    [self createSpriteAtLocation:location];
        
    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}
#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    [self createSpriteAtLocation:location];
    
    [super mouseDown:theEvent];
}

#endif

-(void)createSpriteAtLocation:(CGPoint)location
{
    location = [[self gameWorldNode] convertToNodeSpace:location];

    LHSprite* sprite = [LHSprite createWithSpriteName:@"carBody"
                                            imageFile:@"carParts.png"
                                               folder:@"PUBLISH_FOLDER/"
                                               parent:[self gameWorldNode]];
                     

    NSLog(@"Did create %@ %p\n", [sprite name], sprite);
    if(sprite){
        [sprite setPosition:location];
    }
}

@end
