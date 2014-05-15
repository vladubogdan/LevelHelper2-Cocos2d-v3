//
//  LHNodeAnimationProtocol.h
//  LevelHelper2-Cocos2d-V3
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@class LHAnimation;

@protocol LHNodeAnimationProtocol <NSObject>

@required
////////////////////////////////////////////////////////////////////////////////

-(void)setActiveAnimation:(LHAnimation*)anim;

-(void)setPosition:(CGPoint)point;
-(void)setRotation:(float)val;//degrees
//
-(void)setScaleX:(float)val;
-(void)setScaleY:(float)val;

-(void)setOpacity:(float)val;

@end
