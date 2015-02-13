//
//  LHBone.mm
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHBone.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHAnimation.h"
#import "LHBoneNodes.h"
#import "CCNode+Transform.h"

@interface LHBoneConnection : NSObject
{
    float angleDelta;
    CGPoint positionDelta;
    __weak CCNode* connectedNode;
    NSString* connectedNodeName;
    __weak LHBone* bone;
}

-(id)initWithDictionary:(NSDictionary*)dict bone:(LHBone*)prnt;

-(float)angleDelta;
-(CGPoint)positionDelta;
-(CCNode*)connectedNode;
-(NSString*)connectedNodeName;
-(LHBone*)bone;
-(void)updateDeltas;

@end


@implementation LHBoneConnection

-(id)initWithDictionary:(NSDictionary*)dict bone:(LHBone*)prnt
{
    self = [super init];
    if(self){
        bone = prnt;
        
        angleDelta = [dict floatForKey:@"angleDelta"];
        positionDelta = [dict pointForKey:@"positionDelta"];
        
        NSString* nm = [dict objectForKey:@"nodeName"];
        if(nm){
            connectedNodeName = [[NSString alloc] initWithString:nm];
        }
    }
    return self;
}

-(void)dealloc{
    
    bone = nil;
    LH_SAFE_RELEASE(connectedNodeName);
    connectedNode = nil;
    LH_SUPER_DEALLOC();
}

-(float)angleDelta{
    return angleDelta;
}
-(CGPoint)positionDelta{
    return positionDelta;
}
-(CCNode*)connectedNode{
    if(!connectedNode && connectedNodeName && bone){
        LHBoneNodes* str = [bone rootBoneNodes];
        CCNode* node = [str childNodeWithName:connectedNodeName];
        if(node){
            connectedNode = node;
            [self updateDeltas];
        }
    }
    return connectedNode;
}

-(NSString*)connectedNodeName{
    return connectedNodeName;
}

-(LHBone*)bone{
    return bone;
}
-(void)updateDeltas{
    
    CCNode* node = [self connectedNode];
    
    if(!node)return;
    
    float boneWorldAngle = [[bone parent] convertToWorldAngle:[bone rotation]];
    float spriteWorldAngle = [[node parent] convertToWorldAngle:[node rotation]];
    angleDelta = spriteWorldAngle - boneWorldAngle;

    CGPoint nodeWorldPos = [node convertToWorldSpaceAR:ccp(0, 0)];
    positionDelta = [bone convertToNodeSpace:nodeWorldPos];
}

@end






@implementation LHBone
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    
    float maxAngle;
    float minAngle;
    BOOL rigid;
    NSMutableArray* connections;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    LH_SAFE_RELEASE(connections);

    LH_SUPER_DEALLOC();
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                         parent:prnt]);
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        
        [prnt addChild:self];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

        
        maxAngle = [dict floatForKey:@"maxAngle"];
        minAngle = [dict floatForKey:@"minAngle"];
        rigid = [dict boolForKey:@"rigid"];
        
        connections = [[NSMutableArray alloc] init];
        
        NSArray* conInfo = [dict objectForKey:@"connections"];
        for(NSDictionary* conDict in conInfo)
        {
            LHBoneConnection* con = LH_AUTORELEASED([[LHBoneConnection alloc] initWithDictionary:conDict bone:self]);
            [connections addObject:con];
        }

        
        
#if LH_DEBUG
        CCDrawNode* debug = [CCDrawNode node];
        [self addChild:debug];
        [debug setAnchorPoint:CGPointMake(0.5, 0.5)];

        CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(1, 0, 0, 1)];

        [debug drawSegmentFrom:ccp(self.contentSize.width*0.5, 0)
                            to:ccp(self.contentSize.width*0.5, self.contentSize.height)
                        radius:1
                         color:borderColor];
        
#endif//LH_DEBUG
        
    }
    
    
    
    return self;
}

-(float)maxAngle{
    return maxAngle;
}
-(float)minAngle{
    return minAngle;
}
-(BOOL)rigid{
    return rigid;
}

-(BOOL)isRoot{
    return ![[self parent] isKindOfClass:[LHBone class]];
}


-(LHBone*)rootBone{
    if([self isRoot]){
        return self;
    }
    return [(LHBone*)[self parent] rootBone];
}
-(LHBoneNodes *)rootBoneNodes{
    
    if([self rootBone])
    {
        NSArray* sprStruct = [[self rootBone] childrenOfType:[LHBoneNodes class]];
        if(sprStruct && [sprStruct count] > 0){
            return [sprStruct objectAtIndex:0];
        }
    }
    return nil;
}

-(void)transformConnectedSprites
{
    float curWorldAngle = [[self parent] convertToWorldAngle:[self rotation]];
    CGPoint curWorldPos = [[self parent] convertToWorldSpace:[self position]];
    
    for(LHBoneConnection* con in connections)
    {
        CCNode* sprite = [con connectedNode];
        if(sprite)
        {
            CGPoint unit = [sprite unitForGlobalPosition:curWorldPos];
            
            float newSpriteAngle = [[sprite parent] convertToNodeAngle:curWorldAngle] + [con angleDelta];
            
            CGPoint prevAnchor = [sprite anchorPoint];
            [sprite setAnchorPoint:unit];
            [sprite setRotation:newSpriteAngle];
            [sprite setAnchorPoint:prevAnchor];
            
            CGPoint posDif = [con positionDelta];
            CGPoint deltaWorldPos = [self convertToWorldSpace:posDif];
            CGPoint newSpritePos = [[sprite parent] convertToNodeSpace:deltaWorldPos];
            [sprite setPosition:newSpritePos];
        }
    }
    
    for(LHBone* b in [self children]){
        if([b isKindOfClass:[LHBone class]]){
            [b transformConnectedSprites];
        }
    }
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    [self transformConnectedSprites];
}

-(void)setRotation:(float)rotation{
    [super setRotation:rotation];
    [self transformConnectedSprites];
}

#if COCOS2D_VERSION >= 0x00030300
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    [_animationProtocolImp visit];
    
    if(renderer)
        [super visit:renderer parentTransform:parentTransform];
}
#else
- (void)visit
{
    [_animationProtocolImp visit];
    
    [super visit];
}
#endif//cocos2d_version


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
