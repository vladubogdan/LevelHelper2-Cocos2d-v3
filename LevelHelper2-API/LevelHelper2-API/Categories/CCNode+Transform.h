//
//  CCNode+Transform.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "CCNode.h"

@interface CCNode (Transform)

-(CGPoint)convertToWorldScale:(CGPoint)nodeScale;
-(CGPoint)convertToNodeScale:(CGPoint)worldScale;

-(float)globalAngleFromLocalAngle:(float)la;
-(float)localAngleFromGlobalAngle:(float)ga;

@end
