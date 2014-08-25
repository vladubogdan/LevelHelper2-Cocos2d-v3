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
 */


@interface LHParallax : CCNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


/**
 Returns the followed node or nil if no node is being fallowed;
 */
-(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)followedNode;

/**
 Set a node that should be followed by this parallax.
 @param node The node that should be followed by the parallax. Usually a camera node.
 */
-(void)followNode:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)node;

@end
