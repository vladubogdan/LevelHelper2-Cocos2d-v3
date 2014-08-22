//
//  LHBox2dCollisionHandling.h
//  LevelHelper2-Cocos2dv3
//
//  Created by Bogdan Vladu on 06/07/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LHConfig.h"
#if LH_USE_BOX2D

@class LHScene;

@interface LHBox2dCollisionHandling : NSObject

- (instancetype)initWithScene:(LHScene*)scene;

@property BOOL sceneIsDeallocing;

@end

#endif
