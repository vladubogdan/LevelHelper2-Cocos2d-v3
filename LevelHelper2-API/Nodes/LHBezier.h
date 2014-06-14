//
//  LHBezier.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"

/**
 LHBezier class is used to load and display a bezier from a level file.
 Users can retrieve a bezier objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHBezier : CCDrawNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)bezierNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt;


/**
 Returns the points used to draw this bezier node. Array of NSValue with CGPoints;
 */
-(NSMutableArray*)linePoints;

@end
