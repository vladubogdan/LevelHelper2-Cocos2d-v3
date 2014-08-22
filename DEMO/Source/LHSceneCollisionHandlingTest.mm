//
//  LHSceneCollisionHandlingTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneCollisionHandlingTest.h"
#import "LevelHelper2-API/LHConfig.h"

@implementation LHSceneCollisionHandlingTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/collisionHandling.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    
#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"COLLISION DEMO\nWatch the console for collision information.\nCheck the LHSceneCollisionHandlingTest.mm for more info.\n\nWhen the car tyre will enter the gravity area it will be thrown upwards.\nIf the position of the car tyre is under the wood object collision will be disabled.\nWhen its on top of it, collision will occur."
                                         fontName:@"Arial"
                                         fontSize:22];
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"COLLISION DEMO\nWhen using Chipmunk collision is handled by Cocos2d."
                                         fontName:@"Arial"
                                         fontSize:22];
#endif

    
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

#if LH_USE_BOX2D
    
#else//using chipmunk
    //When using chipmunk we just use the Cocos2d implementation
    [[self physicsNode] setCollisionDelegate:self];
    
#endif
    
    // done
	return self;
}

#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(CCNode*)a
                               andNodeB:(CCNode*)b{
    NSLog(@"SHOULD DISABLE CONTACT BETWEEN %@ and %@", [a name], [b name]);
    
    if(
       ([[a name] isEqualToString:@"carTyre"] && [[b name] isEqualToString:@"shouldNotCollide"]) ||
       ([[b name] isEqualToString:@"carTyre"] && [[a name] isEqualToString:@"shouldNotCollide"])
       )
    {
        if([[a name] isEqualToString:@"carTyre"])
        {
            if([a position].y < [b position].y){
                return YES;
            }
        }
        
        if([[b name] isEqualToString:@"carTyre"])
        {
            if([b position].y < [a position].y){
                return YES;
            }
        }
    }
    return NO;
}

-(void)didBeginContactBetweenNodeA:(CCNode*)a
                          andNodeB:(CCNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse
{
    NSLog(@"DID BEGIN CONTACT %@ %@ scenePt %@ impulse %f", [a name], [b name], LHStringFromPoint(scenePt), impulse);
}

-(void)didEndContactBetweenNodeA:(CCNode*)a
                        andNodeB:(CCNode*)b
{
    NSLog(@"DID END CONTACT BETWEEN A:%@ AND B:%@", [a name], [b name]);
}


#else//using chipmunk

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB{
    
    NSLog(@"DID BEGIN COLLISION BETWEEN A %@ B %@", [nodeA name], [nodeB name]);
    
    if(
       ([[nodeA name] isEqualToString:@"carTyre"] && [[nodeB name] isEqualToString:@"shouldNotCollide"]) ||
       ([[nodeB name] isEqualToString:@"carTyre"] && [[nodeA name] isEqualToString:@"shouldNotCollide"])
       )
    {
        if([[nodeA name] isEqualToString:@"carTyre"])
        {
            if([nodeA position].y < [nodeB position].y){
                return NO;
            }
        }
        
        if([[nodeB name] isEqualToString:@"carTyre"])
        {
            if([nodeB position].y < [nodeA position].y){
                return NO;
            }
        }
    }
    
    return YES;
}

-(BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB{
    
    NSLog(@"DID PRE SOLVE COLLISION BETWEEN A %@ B %@", [nodeA name], [nodeB name]);
    return YES;
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB{
    
    NSLog(@"DID POST SOLVE COLLISION BETWEEN A %@ B %@", [nodeA name], [nodeB name]);
}

-(void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair typeA:(CCNode *)nodeA typeB:(CCNode *)nodeB{
    
    NSLog(@"DID END COLLISION BETWEEN A %@ B %@", [nodeA name], [nodeB name]);
}
#endif


@end
