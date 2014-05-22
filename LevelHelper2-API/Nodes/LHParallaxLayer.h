//
//  LHParallaxLayer.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"

/**
 LHParallaxLayer class is used to load a parallax layer object from a level file.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHParallaxLayer : CCNode <LHNodeProtocol>

+(instancetype)parallaxLayerWithDictionary:(NSDictionary*)dict
                                    parent:(CCNode*)prnt;

/**
 Returns the unique identifier of this parallax.
 */
-(NSString*)uuid;

/**
 Returns all tag values of the node.
 */
-(NSArray*)tags;

/**
 Returns the user property object assigned to this object or nil.
 */
-(id<LHUserPropertyProtocol>)userProperty;


/**
 Returns the x ratio that is used to calculate the children position.
 */
-(float)xRatio;

/**
 Returns the y ratio that is used to calculate the children position.
 */
-(float)yRatio;

@end
