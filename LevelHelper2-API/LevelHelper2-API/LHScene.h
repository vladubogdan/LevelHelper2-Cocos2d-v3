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
@class LHRopeJointNode;

#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2d/Box2D.h"
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

#pragma mark- NODES SUBCLASSING
/**
 Overwrite this method to return your own class type for specific nodes.
 Setup the class type in "Subclass" property of LevelHelper 2.
 Check LHSceneNodesSubclassingTest for how to use this method.
 
 Your need to implement this function
 + (instancetype)nodeWithDictionary:(NSDictionary*)dict parent:(CCNode*)prnt;
 
 and overwrite this method
 - (instancetype)initWithDictionary:(NSDictionary*)dict parent:(CCNode*)prnt;

 @param subclassTypeName The name of the your custom class.
 @param superTypeName The name of the original LevelHelper node class type. Your class must be a subclass of this type.
 */
-(Class)createNodeObjectForSubclassWithName:(NSString*)subclassTypeName superTypeName:(NSString*)superTypeName;


#pragma mark- ANIMATION HANDLING

/**
 Set a animation notifications delegate for the cases where you don't need to subclass LHScene.
 When subclassing LHScene, if you overwrite the animation notifications methods make sure you call super if you also need the delegate support.
 If you delete the delegate object make sure you null-ify the animation notifications delegate.
 @param del The object that implements the LHAnimationNotificationsProtocol methods.
 */
-(void)setAnimationNotificationsDelegate:(id<LHAnimationNotificationsProtocol>)del;

/**
 Overwrite this method to receive notifications when an animation has finished playing. This method is called once, after all repetitions have finished playing.
 @param anim The animation object that just finished playing.
 */
-(void)didFinishedPlayingAnimation:(LHAnimation*)anim;

/**
 Overwrite this method to receive notifications when an animation has finished playing a repetition.
 @param anim The animation object that just finished a repetition.
 */
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim;

#pragma mark- ROPE CUTTING

/**
 Overwrite this method to receive notifications when a rope joint is cut.
 */
-(void)didCutRopeJoint:(LHRopeJointNode*)joint;


#pragma mark- COLLISION HANDLING

#if LH_USE_BOX2D

/**
 Set a collision handling delegate for the cases where you dont need to subclass LHScene.
 When subclassing LHScene, if you overwrite the collision handling methods make sure you call super if you also need the delegate support.
 If you delete the delegate object make sure you null-ify the collision handling delegate.
 @param del The object that implements the LHCollisionHandlingProtocol methods.
 */
-(void)setCollisionHandlingDelegate:(id<LHCollisionHandlingProtocol>)del;

/**
 Overwrite this methods to receive collision informations when using Box2d.
 This method is called prior the collision happening and lets the user decide whether or not the collision should happen.
 @param a First node that participates in the collision.
 @param b Second node that participates in the collision.
 @return A boolean value telling whether or not the 2 nodes should collide.
 @discussion Available only when using Box2d.
 @discussion Useful when you have a character that jumps from platform to platform. When the character is under the platform you want to disable collision, but once the character is on top of the platform you want the collision to be triggers in order for the character to stay on top of the platform.
 */
-(BOOL)shouldDisableContactBetweenNodeA:(CCNode*)a
                               andNodeB:(CCNode*)b;

/**
 Overwrite this methods to receive collision informations when using Box2d.
 Called when the collision begins. Called with every new contact point between two nodes. May be called multiple times for same two nodes, because the point at which the nodes are touching has changed.
 @param a First node that participates in the collision.
 @param b Second node that participates in the collision.
 @param scenePt The location where the two nodes collided in scene coordinates.
 @param impulse The impulse of the collision.
 @discussion Available only when using Box2d.
 */
-(void)didBeginContactBetweenNodeA:(CCNode*)a
                          andNodeB:(CCNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse;

/**
 Overwrite this methods to receive collision informations when using Box2d.
 Called when the collision ends. Called when two nodes no longer collide at a specific point. May be called multiple times for same two nodes, because the point at which the nodes are touching has changed.
 @param a First node that participates in the collision.
 @param b Second node that participates in the collision.
 @discussion Available only when using Box2d.
 */
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

-(void)setBox2dFixedTimeStep:(float)val; //default 1.0f / 120.0f;
-(void)setBox2dMinimumTimeStep:(float)val; //default 1.0f/600f;
-(void)setBox2dVelocityIterations:(int)val;//default 8
-(void)setBox2dPositionIterations:(int)val;//default 8
-(void)setBox2dMaxSteps:(int)val; //default 1

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
