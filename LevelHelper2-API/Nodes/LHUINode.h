//
//  LHUINode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
/**
 LHUINode class is used to load the UI elements.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHUINode : CCNode <LHNodeProtocol>

+(instancetype)uiNodeWithDictionary:(NSDictionary*)dict
                             parent:(CCNode*)prnt;


@end
