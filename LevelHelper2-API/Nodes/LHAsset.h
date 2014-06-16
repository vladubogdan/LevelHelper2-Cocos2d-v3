//
//  LHAsset.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
#import "LHNodePhysicsProtocol.h"

/**
 LHAsset class is used to load an asset object from a level file or from the resources folder.
 Users can retrieve node objects by calling the scene (LHScene) childNodeWithName: method.
 */


@interface LHAsset : CCNode <LHNodeProtocol, LHNodeAnimationProtocol, LHNodePhysicsProtocol>

+(instancetype)assetWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

@end
