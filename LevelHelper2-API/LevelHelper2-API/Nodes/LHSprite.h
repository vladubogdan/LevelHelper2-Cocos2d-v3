//
//  LHSprite.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodePhysicsProtocol.h"

/**
 LHSprite class is used to load textured rectangles that are found in a level file.
 */

@interface LHSprite : CCSprite <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


/**
 * Creates a sprite with an sprite frame name using a sprite sheet name.
 *
 * @param   spriteFrameName A string which indicates the sprite frame name.
 * @param   imageFile A string which indicates the image file containing the sprite texture. This file will be used to look for the plist file.
 * @param   folder A string which indicates the folder that contains the image & plist file. The folder must be added as reference in Xcode - blue icon.
 * @param   prnt A parent node. Must be in the LHScene hierarchy.
 * @return  An autoreleased sprite object
 
 Eg:
 @code
 DEMO_PUBLISH_FOLDER/ (added as reference in Xcode - has Blue icon)
 objects-ipad.plist
 objects-ipad.png
 objects-ipadhd.plist
 objects-ipadhd.png
 objects-iphone5.plist
 objects-iphone5.png
 objects-iphone6.plist
 objects-iphone6.png
 objects-iphone6plus.plist
 objects-iphone6plus.png
 objects.plist
 objects.png

 LHSprite* sprite = [LHSprite createWithSpriteName:@"carBody"
                                            imageFile:@"carParts.png"
                                            folder:@"PUBLISH_FOLDER/"
                                            parent:[self gameWorldNode]];
 if(sprite){
    [sprite setPosition:location];
 }
 
 @endcode
 */
+ (instancetype)createWithSpriteName:(NSString*)spriteFrameName
                           imageFile:(NSString*)imageFile
                              folder:(NSString*)folder
                              parent:(CCNode*)prnt;

-(instancetype)initWithSpriteName:(NSString*)spriteFrameName
                        imageFile:(NSString*)imageFile
                           folder:(NSString*)folder
                           parent:(CCNode*)prnt;

/**
 Change the sprite texture rectangle with the a new texture rectangle defined by the sprite frame with a specific name.
 @param spriteFrame The name of the sprite texture rectangle as defined in the Sprite Packing Editor.
 */
-(void)setSpriteFrameWithName:(NSString*)spriteFrame;

/**
 Returns the sprite image file path.
 */
-(NSString*)imageFilePath;

/**
 Returns the sprite frame name.
 */
-(NSString*)spriteFrameName;

@end
