//
//  LHWeldJointNode.h
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
class b2WeldJoint;
#endif
#else//chipmunk

#endif

/**
 LHWeldJointNode class is used to load a LevelHelper weld joint.
 
 WARNING - Weld joint is not supported in Chipmunk.
 
 When using Box2d it uses a b2WeldJoint.
 */

@interface LHWeldJointNode : CCNode <LHNodeProtocol, LHJointNodeProtocol>

+(instancetype)nodeWithDictionary:(NSDictionary*)dict
                           parent:(CCNode*)prnt;

-(instancetype)initWithDictionary:(NSDictionary*)dict
                               parent:(CCNode*)prnt;


#pragma mark - Properties
/**
 Returns the frequency used by this joint.
 */
-(CGFloat)frequency;

/**
 Returns the damping ratio used by this joint.
 */
-(CGFloat)dampingRatio;


@end
