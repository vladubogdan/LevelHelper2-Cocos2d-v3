//
//  LHParallax.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
/**
 LHParallax class is used to load a parallax object from a level file.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHParallax : CCNode <LHNodeProtocol, LHNodeAnimationProtocol>

+(instancetype)parallaxWithDictionary:(NSDictionary*)dict
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
 Returns the followed node or nil if no node is being fallowed;
 */
-(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode;
/**
 Set a node that should be followed by this parallax.
 */
-(void)followNode:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node;

@end
