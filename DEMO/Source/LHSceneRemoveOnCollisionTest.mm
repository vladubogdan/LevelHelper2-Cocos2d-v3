//
//  LHSceneRemoveOnCollisionTest.mm
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneRemoveOnCollisionTest.h"
#import "LevelHelper2-API/LHConfig.h"

@implementation LHSceneRemoveOnCollisionTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/removalOnCollisionDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    
#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"REMOVE OBJECTS ON COLLISION\nIf you are familiar with Box2d then you will know that\nremoving a body in the collision callback function\nwill make Box2d library assert as the world is locked.\nThe LevelHelper API solves this by sending the callbacks when its safe.\nCut the rope to remove the bodies when collision occurs."
                                         fontName:@"Arial"
                                         fontSize:22];
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"This demo is currently not available when using Chipmunk.\nIn Xcode, please switch to the Box2d targets."
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

-(void)handleCandy:(CCNode*)candy collisionWithNode:(CCNode*)node
{
    if([node conformsToProtocol:@protocol(LHNodeProtocol)])
    {
        LHNode* n = (LHNode*)node;
        
        if([[n tags] containsObject:@"BANANA"])
        {
            [n removeFromParent];
        }
    }
    
}

#if LH_USE_BOX2D

-(BOOL)disableCandyCollisionWithNode:(CCNode*)node
{
    if([node conformsToProtocol:@protocol(LHNodeProtocol)])
    {
        LHNode* n = (LHNode*)node;
        
        if([[n tags] containsObject:@"BANANA"])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)shouldDisableContactBetweenNodeA:(CCNode *)a andNodeB:(CCNode *)b
{
    if([[a name] isEqualToString:@"candy"])
    {
        return [self disableCandyCollisionWithNode:b];
    }
    else
    {
        return [self disableCandyCollisionWithNode:a];
    }
    
    return NO;
}

-(void)didBeginContactBetweenNodeA:(CCNode*)a
                          andNodeB:(CCNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse
{
    NSLog(@"DID BEGIN CONTACT %@ %@ scenePt %@ impulse %f", [a name], [b name], LHStringFromPoint(scenePt), impulse);

    if([[a name] isEqualToString:@"candy"])
    {
        [self handleCandy:a collisionWithNode:b];
    }
    else
    {
        [self handleCandy:b collisionWithNode:a];
    }
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
