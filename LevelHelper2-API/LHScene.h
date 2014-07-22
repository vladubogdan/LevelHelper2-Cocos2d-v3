//
//  LHScene.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"

#import "LHConfig.h"

@class LHAnimation;
@class LHBackUINode;
@class LHGameWorldNode;
@class LHUINode;

#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2D.h"
#endif
#endif //LH_USE_BOX2D


@protocol LHCollisionHandlingProtocol <NSObject>

@required
#if LH_USE_BOX2D

-(BOOL)shouldDisableContactBetweenNodeA:(CCNode*)a
                               andNodeB:(CCNode*)b;

-(void)didBeginContactBetweenNodeA:(CCNode*)a
                          andNodeB:(CCNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

-(void)didEndContactBetweenNodeA:(CCNode*)a
                        andNodeB:(CCNode*)b;

#endif

@end


@protocol LHAnimationNotificationsProtocol <NSObject>

@required
-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;

@end




#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif



/**
 LHScene class is used to load a level file into Cocos2d v3 engine.
 End users will have to subclass this class in order to add they're own game logic.
 */

@interface LHScene : CCScene <LHNodeProtocol>

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;

/**
 Returns the relative plist path that was used to load this scene information.
 */
-(NSString*)relativePath;

/**
 Returns a CCTexture object that was previously loaded or a new one.
 @param imagePath The path of the image that needs to get returned as a texture.
 @return An initialized CCTexture Object.
 */
-(CCTexture*)textureWithImagePath:(NSString*)imagePath;

/**
 Returns the game world rectangle or CGRectZero if the game world rectangle is not set in the level file.
 */
-(CGRect)gameWorldRect;

/**
 Returns the back UI node. All children of this node will NOT move with the camera.
 */
-(LHBackUINode*)backUiNode;

/**
 Returns the game world node. All children of this node will move with the camera. For UI elements use the uiNode.
 */
-(LHGameWorldNode*)gameWorldNode;

/**
 Returns the UI node. All children of this node will NOT move with the camera.
 */
-(LHUINode*)uiNode;


#pragma mark- ANIMATION HANDLING

/**
 Set a animation notifications delegate for the cases where you don't need to subclass LHScene.
 When subclassing LHScene, if you overwrite the animation notifications methods make sure you call super if you also need the delegate support.
 If you delete the delegate object make sure you null-ify the animation notifications delegate.
 @param del The object that implements the LHAnimationNotificationsProtocol methods.
 */
-(void)setAnimationNotificationsDelegate:(id<LHAnimationNotificationsProtocol>)del;

-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;


#pragma mark- COLLISION HANDLING

#if LH_USE_BOX2D

/**
 Set a collision handling delegate for the cases where you dont need to subclass LHScene.
 When subclassing LHScene, if you overwrite the collision handling methods make sure you call super if you also need the delegate support.
 If you delete the delegate object make sure you null-ify the collision handling delegate.
 @param del The object that implements the LHCollisionHandlingProtocol methods.
 */
-(void)setCollisionHandlingDelegate:(id<LHCollisionHandlingProtocol>)del;

-(BOOL)shouldDisableContactBetweenNodeA:(CCNode*)a
                               andNodeB:(CCNode*)b;

-(void)didBeginContactBetweenNodeA:(CCNode*)a
                          andNodeB:(CCNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

-(void)didEndContactBetweenNodeA:(CCNode*)a
                        andNodeB:(CCNode*)b;

#else //Chipmunk (Cocos2d)
//users of chipmunk should use the implementation provided by Cocos2d.
#endif




#if LH_USE_BOX2D
#ifdef __cplusplus
-(b2World*)box2dWorld;

-(float)ptm;

-(b2Vec2)metersFromPoint:(CGPoint)point;
-(CGPoint)pointFromMeters:(b2Vec2)vec;

-(float)metersFromValue:(float)val;
-(float)valueFromMeters:(float)meter;

#endif
#endif //LH_USE_BOX2D


/*Get the global gravity force.
 */
-(CGPoint)globalGravity;
/*Sets the global gravity force
@param gravity A point representing the gravity force in x and y direction.
 */
-(void)setGlobalGravity:(CGPoint)gravity;

@end
