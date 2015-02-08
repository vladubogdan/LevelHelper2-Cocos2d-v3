//
//  LHBone.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHNodeAnimationProtocol.h"
/**
 LHBone class is used to load a bone object from a level file.
 */

@class LHBoneNodes;

@interface LHBone : CCNode <LHNodeProtocol, LHNodeAnimationProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


-(float)maxAngle;
-(float)minAngle;
-(BOOL)rigid;

-(BOOL)isRoot;
-(LHBone*)rootBone;
-(LHBoneNodes*)rootBoneNodes;

@end
