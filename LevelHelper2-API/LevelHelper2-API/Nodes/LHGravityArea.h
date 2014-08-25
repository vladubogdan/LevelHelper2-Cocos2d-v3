//
//  LHGravityArea.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"

/**
 LHGravityArea class is used to load a gravity area object from a level file.
 */


@interface LHGravityArea : CCNode <LHNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;

/**
 Returns whether or not this gravity area is a radial.
 */
-(BOOL)isRadial;

/**
 Returns the direction in which the force is applied.
 */
-(CGPoint)direction;

/**
 Returns the force of this gravity area.
 */
-(float)force;
@end
