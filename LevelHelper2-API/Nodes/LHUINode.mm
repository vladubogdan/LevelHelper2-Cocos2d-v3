//
//  LHUINode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHUINode.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHRopeJointNode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGSize)currentDeviceSize;
-(CGSize)designResolutionSize;
-(CGPoint)designOffset;
@end

@implementation LHUINode
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    CGPoint touchBeganLocation;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);

    LH_SUPER_DEALLOC();
}


+ (instancetype)uiNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initUINodeWithDictionary:dict
                                                           parent:prnt]);
}

- (instancetype)initUINodeWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        self.zOrder = 1;
        [self setPosition:CGPointZero];

        LHScene* scene = (LHScene*)[prnt scene];
        self.contentSize = [scene currentDeviceSize];
        
        self.userInteractionEnabled = YES;
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - TOUCH SUPPORT
////////////////////////////////////////////////////////////////////////////////

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    touchBeganLocation = [touch locationInNode:self];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];

    for(LHRopeJointNode* rope in [[self scene] childrenOfType:[LHRopeJointNode class]]){
        if([rope canBeCut]){
            [rope cutWithLineFromPointA:touchBeganLocation
                               toPointB:touchLocation];
        }
    }
}


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
