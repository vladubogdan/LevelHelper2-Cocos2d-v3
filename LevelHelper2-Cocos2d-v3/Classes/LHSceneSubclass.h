//
//  IntroScene.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using cocos2d-v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

#import "LevelHelper2API.h"

@interface LHSceneSubclass : LHScene

// -----------------------------------------------------------------------

+ (LHSceneSubclass *)scene;
- (id)initWithContentOfFile:(NSString *)levelPlistFile;

// -----------------------------------------------------------------------
@end