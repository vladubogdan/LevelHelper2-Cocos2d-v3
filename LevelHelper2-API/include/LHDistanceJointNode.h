//
//  LHDistanceJointNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "cocos2d.h"
#import "LHNodeProtocol.h"
/**
 LHDistanceJointNode class is used to load a LevelHelper distance joint.
 The equivalent in Cocos2d-v3/Chipmunk is a Spring joint object.
 */

@interface LHDistanceJointNode : CCNode <LHNodeProtocol>

+(instancetype)distanceJointNodeWithDictionary:(NSDictionary*)dict
                                        parent:(CCNode*)prnt;

/**
 Returns the point where the joint is connected with the first body. In scene coordinates.
 */
-(CGPoint)anchorA;

/**
 Returns the point where the joint is connected with the second body. In scene coordinates.
 */
-(CGPoint)anchorB;

/**
 Returns the unique identifier of this joint node.
 */
-(NSString*)uuid;

/**
 Returns all tag values of the node.
 */
-(NSArray*)tags;

/**
 Returns the user property object assigned to this object or nil.
 */
-(id<LHUserPropertyProtocol>)userProperty;

/**
 Returns the actual Cocos2d/Chipmunk joint that connects the two bodies together.
 */
-(CCPhysicsJoint*)joint;

/**
 Returns the damping ratio of the SpriteKit joint.
 */
-(CGFloat)damping;

/**
 Returns the frequency of the SpriteKit joint.
 */
-(CGFloat)frequency;
@end
