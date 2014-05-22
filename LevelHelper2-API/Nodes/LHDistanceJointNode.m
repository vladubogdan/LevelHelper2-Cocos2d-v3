//
//  LHDistanceJointNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHDistanceJointNode.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "CCPhysics+ObjectiveChipmunk.h"


@implementation LHDistanceJointNode
{
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    CCPhysicsJoint* __unsafe_unretained joint;
    
    
    CGPoint relativePosA;
    CGPoint relativePosB;
    
    NSString* nodeAUUID;
    NSString* nodeBUUID;
    
    __unsafe_unretained CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeA;
    __unsafe_unretained CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* nodeB;
    
    float _dampingRatio;
    float _frequency;
}

-(void)dealloc{
    nodeA = nil;
    nodeB = nil;
    
    joint = nil;
    
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);

    LH_SAFE_RELEASE(nodeAUUID);
    LH_SAFE_RELEASE(nodeBUUID);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)distanceJointNodeWithDictionary:(NSDictionary*)dict
                                    parent:(CCNode*)prnt{
    
    return LH_AUTORELEASED([[self alloc] initDistanceJointNodeWithDictionary:dict
                                                                      parent:prnt]);
}

-(instancetype)initDistanceJointNodeWithDictionary:(NSDictionary*)dict
                                            parent:(CCNode*)prnt
{
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];
        
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        
        relativePosA = [dict pointForKey:@"relativePosA"];
        relativePosB = [dict pointForKey:@"relativePosB"];

        nodeAUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteAUUID"]];
        nodeBUUID = [[NSString alloc] initWithString:[dict objectForKey:@"spriteBUUID"]];
        
        _dampingRatio =[dict floatForKey:@"dampingRatio"];
        _frequency = [dict floatForKey:@"frequency"];
    }
    return self;
}

-(void)removeFromParent{
    if(joint){
        [joint tryRemoveFromPhysicsNode:[[self scene] physicsNode]];
        joint = nil;
    }
    
    [super removeFromParent];
}

-(CGPoint)anchorA{
    CGPoint pt = [nodeA convertToWorldSpaceAR:CGPointMake(relativePosA.x,
                                                          -relativePosA.y)];
    
    return [nodeA.parent convertToNodeSpaceAR:pt];
}

-(CGPoint)anchorB{
    CGPoint pt = [nodeB convertToWorldSpaceAR:CGPointMake(relativePosB.x,
                                                          -relativePosB.y)];
    
    return [nodeB.parent convertToNodeSpaceAR:pt];
}

-(CCPhysicsJoint*)joint{
    return joint;
}

-(CGFloat)damping{
    return _dampingRatio;
}

-(CGFloat)frequency{
    return _frequency;
}

#pragma mark LHNodeProtocol Required
-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

#pragma mark LHNodeProtocol Optional

-(BOOL)lateLoading
{
    if(!nodeAUUID || !nodeBUUID)
        return true;
    
    LHScene* scene = (LHScene*)[self scene];
    
    if([[self parent] conformsToProtocol:@protocol(LHNodeProtocol)])
    {
        nodeA = (CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(id<LHNodeProtocol>)[self parent] childNodeWithUUID:nodeAUUID];
        nodeB = (CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[(id<LHNodeProtocol>)[self parent] childNodeWithUUID:nodeBUUID];
    }
    else{
        nodeA = (CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[scene childNodeWithUUID:nodeAUUID];
        nodeB = (CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)[scene childNodeWithUUID:nodeBUUID];
    }

    
    
    if(nodeA && nodeB && nodeA.physicsBody && nodeB.physicsBody)
    {
        
        float _length = LHDistanceBetweenPoints(nodeA.position, nodeB.position);
        
        joint = [CCPhysicsJoint connectedDistanceJointWithBodyA:nodeA.physicsBody
                                                          bodyB:nodeB.physicsBody
                                                        anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
                                                                            -relativePosA.y + nodeA.contentSize.height*0.5)
                                                        anchorB:CGPointMake(relativePosB.x + nodeB.contentSize.width*0.5,
                                                                            -relativePosB.y + nodeB.contentSize.height*0.5)
                                                    minDistance:_length
                                                    maxDistance:_length];

//        joint = [CCPhysicsJoint connectedSpringJointWithBodyA:nodeA.physicsBody
//                                                        bodyB:nodeB.physicsBody
//                                                      anchorA:CGPointMake(relativePosA.x + nodeA.contentSize.width*0.5,
//                                                                          -relativePosA.y + nodeA.contentSize.height*0.5)
//                                                      anchorB:CGPointMake(relativePosB.x + nodeB.contentSize.width*0.5,
//                                                                          -relativePosB.y + nodeB.contentSize.height*0.5)
//                                                   restLength:_length
//                                                    stiffness:_frequency
//                                                      damping:_dampingRatio];
//        
        
        LH_SAFE_RELEASE(nodeAUUID);
        LH_SAFE_RELEASE(nodeBUUID);
        return true;
    }
    return false;
}

@end
