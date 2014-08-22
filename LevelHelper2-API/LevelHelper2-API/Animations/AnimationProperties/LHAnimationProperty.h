//
//  LHAnimationProperty.h
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LHAnimation;
@class LHFrame;
@class CCNode;

@protocol LHNodeAnimationProtocol;
@protocol LHNodeProtocol;

@interface LHAnimationProperty : NSObject

+(instancetype)animationPropertyWithDictionary:(NSDictionary*)dict
                                     animation:(LHAnimation*)a;

-(instancetype)initAnimationPropertyWithDictionary:(NSDictionary*)dict
                                         animation:(LHAnimation*)a;

-(void)loadDictionary:(NSDictionary*)dict;

-(void)addKeyFrame:(LHFrame*)frm;

-(NSArray*)keyFrames;

-(LHAnimation*)animation;

-(BOOL)isSubproperty;
-(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)subpropertyNode;
-(void)setSubpropertyNode:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)val;
-(LHAnimationProperty*)subpropertyForUUID:(NSString*)nodeUuid;
-(NSArray*)allSubproperties;
@end
