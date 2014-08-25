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
 */


@interface LHParallaxLayer : CCNode <LHNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


/**
 Returns the x ratio that is used to calculate the children position.
 */
-(float)xRatio;

/**
 Returns the y ratio that is used to calculate the children position.
 */
-(float)yRatio;

@end
