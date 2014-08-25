//
//  LHWater.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"

/*
 LHWater class is used to load and display a water area from a level file.
 */


@interface LHWater : CCDrawNode <LHNodeProtocol>

+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;


-(CGFloat)turbulenceAmplitude;
-(void)setTurbulenceAmplitude:(CGFloat)val;

-(CGFloat)waveLength;
-(void)setWaveLength:(CGFloat)val;

@end
