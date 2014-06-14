//
//  LHNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
/**
 LHNode class is used to load a node object from a level file.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHNode : CCNode <LHNodeProtocol, LHNodeAnimationProtocol>

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;


@end
