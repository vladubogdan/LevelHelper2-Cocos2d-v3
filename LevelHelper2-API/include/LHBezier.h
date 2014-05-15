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
 Returns the unique identifier of this bezier node.
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
 Returns the points used to draw this bezier node. Array of NSValue with CGPoints;
 */
-(NSMutableArray*)linePoints;

@end
