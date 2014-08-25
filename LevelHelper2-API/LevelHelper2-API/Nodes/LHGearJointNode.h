//
//  LHGearJointNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
#import "LHJointNodeProtocol.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2GearJoint;
#endif
#else//chipmunk

#endif

/**
 LHGearJointNode class is used to load a LevelHelper gear joint.

 WARNING - Weld joint is not supported in Chipmunk.
 
 When using Box2d it uses a b2GearJoint.
 */

@interface LHGearJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

-(instancetype)initWithDictionary:(NSDictionary*)dict
                               parent:(CCNode*)prnt;

@end
