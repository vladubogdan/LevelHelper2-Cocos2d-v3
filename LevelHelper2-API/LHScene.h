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

#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2D.h"
#endif
#endif //LH_USE_BOX2D


#if __has_feature(objc_arc) && __clang_major__ >= 3
#define LH_ARC_ENABLED 1
#endif

@class LHGameWorldNode;
@class LHUINode;

/**
 LHScene class is used to load a level file into Cocos2d v3 engine.
 End users will have to subclass this class in order to add they're own game logic.
 */

@interface LHScene : CCScene <LHNodeProtocol>

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile;
-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile;

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
 Returns the informations that can be used to create an asset dynamically by specifying the file name. 
 The asset file must be in the same folder as the scene file.
 If the asset file is not found it will return nil.
 
 @param assetFileName The name of the asset that. Do not provide an extension. E.g If file is named "myAsset.lhasset.plist" then yous should pass @"myAsset.lhasset"
 @return A dictionary containing the asset information or nil.
 */
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;

/**
 Returns the game world node. All children of this node will move with the camera. For UI elements use the uiNode.
 */
-(LHGameWorldNode*)gameWorldNode;

/**
 Returns the UI node. All children of this node will NOT move with the camera.
 */
-(LHUINode*)uiNode;


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
