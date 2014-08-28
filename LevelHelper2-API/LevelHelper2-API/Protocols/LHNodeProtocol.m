//
//  LHNodeProtocol.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHNodeProtocol.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHUserPropertyProtocol.h"

#import "LHUINode.h"
#import "LHBackUINode.h"
#import "LHGameWorldNode.h"
#import "LHScene.h"
#import "LHAsset.h"
#import "LHBezier.h"
#import "LHCamera.h"
#import "LHNode.h"
#import "LHParallax.h"
#import "LHParallaxLayer.h"
#import "LHShape.h"
#import "LHSprite.h"
#import "LHWater.h"
#import "LHAnimation.h"
#import "LHGravityArea.h"

#import "LHRopeJointNode.h"
#import "LHDistanceJointNode.h"
#import "LHRevoluteJointNode.h"
#import "LHPulleyJointNode.h"
#import "LHWeldJointNode.h"
#import "LHPrismaticJointNode.h"
#import "LHWheelJointNode.h"
#import "LHGearJointNode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(void)addLateLoadingNode:(CCNode*)node;
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end

@implementation LHNodeProtocolImpl
{
    BOOL b2WorldDirty;
    __weak CCNode* _node;
    
    NSString*           _uuid;
    NSMutableArray*     _tags;
    id<LHUserPropertyProtocol> _userProperty;
}

-(void)dealloc{
    
    _node = nil;
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    LH_SUPER_DEALLOC();
}

+ (instancetype)nodeProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    return LH_AUTORELEASED([[self alloc] initNodeProtocolImpWithDictionary:dict node:nd]);
}

- (instancetype)initNodeProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    
    if(self = [super init])
    {
        b2WorldDirty = false;
        _node = nd;
        
        [_node setName:[dict objectForKey:@"name"]];
        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        
        //tags loading
        {
            NSArray* loadedTags = [dict objectForKey:@"tags"];
            if(loadedTags){
                _tags = [[NSMutableArray alloc] initWithArray:loadedTags];
            }
        }

        //user properties loading
        {
            NSDictionary* userPropInfo  = [dict objectForKey:@"userPropertyInfo"];
            NSString* userPropClassName = [dict objectForKey:@"userPropertyName"];
            if(userPropInfo && userPropClassName)
            {
                Class userPropClass = NSClassFromString(userPropClassName);
                if(userPropClass){
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
                    _userProperty = [userPropClass performSelector:@selector(customClassInstanceWithNode:)
                                                        withObject:_node];
    #pragma clang diagnostic pop
                    if(_userProperty){
                        [_userProperty setPropertiesFromDictionary:userPropInfo];
                    }
                }
            }
        }
        
        if([dict objectForKey:@"alpha"])
            [_node setOpacity:[dict floatForKey:@"alpha"]/255.0f];
        
        if([dict objectForKey:@"rotation"])
            [_node setRotation:[dict floatForKey:@"rotation"]];
        
        if([dict objectForKey:@"zOrder"])
            [_node setZOrder:[dict floatForKey:@"zOrder"]];
        
        
        if([dict objectForKey:@"scale"])
        {
            CGPoint scl = [dict pointForKey:@"scale"];
            [_node setScaleX:scl.x];
            [_node setScaleY:scl.y];
        }

        //for sprites the content size is set from the CCSpriteFrame
        if([dict objectForKey:@"size"] && ![_node isKindOfClass:[LHSprite class]] ){
            [_node setContentSize:[dict sizeForKey:@"size"]];
        }
        
        if([dict objectForKey:@"generalPosition"]&&
           ![_node isKindOfClass:[LHUINode class]] &&
           ![_node isKindOfClass:[LHBackUINode class]] &&
           ![_node isKindOfClass:[LHGameWorldNode class]])
        {
            
            CGPoint unitPos = [dict pointForKey:@"generalPosition"];
            CGPoint pos = [LHUtils positionForNode:_node
                                          fromUnit:unitPos];
            
            NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
            if(devPositions)
            {
                
                NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                       forSize:LH_SCREEN_RESOLUTION];
                
                if(unitPosStr){
                    CGPoint unitPos = LHPointFromString(unitPosStr);
                    pos = [LHUtils positionForNode:_node
                                          fromUnit:unitPos];
                }
            }
                    
            [_node setPosition:pos];
        }
        
        if([dict objectForKey:@"anchor"] &&
           ![_node isKindOfClass:[LHUINode class]] &&
           ![_node isKindOfClass:[LHBackUINode class]] &&
           ![_node isKindOfClass:[LHGameWorldNode class]])
        {
            CGPoint anchor = [dict pointForKey:@"anchor"];
            anchor.y = 1.0f - anchor.y;
            [_node setAnchorPoint:anchor];
        }

        
    }
    return self;
}

- (instancetype)initNodeProtocolImpWithNode:(CCNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;
    }
    return self;
}

+(void)loadChildrenForNode:(CCNode*)prntNode fromDictionary:(NSDictionary*)dict
{
    NSArray* childrenInfo = [dict objectForKey:@"children"];
    if(childrenInfo)
    {
        for(NSDictionary* childInfo in childrenInfo)
        {
            CCNode* node = [LHNodeProtocolImpl createLHNodeWithDictionary:childInfo
                                                                   parent:prntNode];
#pragma unused (node)
        }
    }
}

+(id)createLHNodeWithDictionary:(NSDictionary*)childInfo
                         parent:(CCNode*)prnt
{
    
    NSString* nodeType = [childInfo objectForKey:@"nodeType"];
    
    LHScene* scene = nil;
    if([prnt isKindOfClass:[LHScene class]]){
        scene = (LHScene*)prnt;
    }
    else if([[prnt scene] isKindOfClass:[LHScene class]]){
        scene = (LHScene*)[prnt scene];
    }
    
    
    
    NSString* subclassNodeType = [childInfo objectForKey:@"subclassNodeType"];
    if(subclassNodeType && subclassNodeType.length > 0)
    {
        //this will not work as we do not have the class included in the api
//        Class classObj = NSClassFromString(subclassNodeType);
        
        Class classObj = [scene createNodeObjectForSubclassWithName:subclassNodeType superTypeName:nodeType];
        if(classObj){
            
            CCNode* node = [classObj nodeWithDictionary:childInfo parent:prnt];
            if(node){
                if([node conformsToProtocol:@protocol(LHJointNodeProtocol)])
                {
                    [scene addLateLoadingNode:node];
                }
            }
            return node;
        }
        else{
            NSLog(@"\n\nWARNING: Expected a class of type %@ subclassed from %@, but nothing was returned. Check your \"createNodeObjectForSubclassWithName:superTypeName:\" method and make sure you return a valid Class.\n\n", subclassNodeType, nodeType);
        }
    }
    
    
    
    
    if([nodeType isEqualToString:@"LHGameWorldNode"])
    {
        LHGameWorldNode* pNode = [LHGameWorldNode nodeWithDictionary:childInfo
                                                              parent:prnt];
        pNode.contentSize = scene.designResolutionSize;
#if LH_DEBUG
        [pNode setDebugDraw:YES];
#endif
        
        return pNode;
    }
    else if([nodeType isEqualToString:@"LHBackUINode"])
    {
        LHBackUINode* pNode = [LHBackUINode nodeWithDictionary:childInfo
                                                        parent:prnt];
        return pNode;
    }
    else if([nodeType isEqualToString:@"LHUINode"])
    {
        LHUINode* pNode = [LHUINode nodeWithDictionary:childInfo
                                                parent:prnt];
        return pNode;
    }
    else if([nodeType isEqualToString:@"LHSprite"])
    {
        LHSprite* spr = [LHSprite nodeWithDictionary:childInfo
                                              parent:prnt];
        return spr;
    }
    else if([nodeType isEqualToString:@"LHNode"])
    {
        LHNode* nd = [LHNode nodeWithDictionary:childInfo
                                         parent:prnt];
        return nd;
    }
    else if([nodeType isEqualToString:@"LHBezier"])
    {
        LHBezier* bez = [LHBezier nodeWithDictionary:childInfo
                                              parent:prnt];
        return bez;
    }
    else if([nodeType isEqualToString:@"LHTexturedShape"])
    {
        LHShape* sp = [LHShape nodeWithDictionary:childInfo
                                           parent:prnt];
        return sp;
    }
    else if([nodeType isEqualToString:@"LHWaves"])
    {
        LHWater* wt = [LHWater nodeWithDictionary:childInfo
                                           parent:prnt];
        return wt;
    }
    else if([nodeType isEqualToString:@"LHAreaGravity"])
    {
        LHGravityArea* gv = [LHGravityArea nodeWithDictionary:childInfo
                                                       parent:prnt];
        return gv;
    }
    else if([nodeType isEqualToString:@"LHParallax"])
    {
        LHParallax* pr = [LHParallax nodeWithDictionary:childInfo
                                                 parent:prnt];
        return pr;
    }
    else if([nodeType isEqualToString:@"LHParallaxLayer"])
    {
        LHParallaxLayer* lh = [LHParallaxLayer nodeWithDictionary:childInfo
                                                           parent:prnt];
        return lh;
    }
    else if([nodeType isEqualToString:@"LHAsset"])
    {
        LHAsset* as = [LHAsset nodeWithDictionary:childInfo
                                           parent:prnt];
        return as;
    }
    else if([nodeType isEqualToString:@"LHCamera"])
    {
        LHCamera* cm = [LHCamera nodeWithDictionary:childInfo
                                             parent:prnt];
        return cm;
    }
    else if([nodeType isEqualToString:@"LHRopeJoint"])
    {
        LHRopeJointNode* jt = [LHRopeJointNode nodeWithDictionary:childInfo
                                                           parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHWeldJoint"])
    {
        LHWeldJointNode* jt = [LHWeldJointNode nodeWithDictionary:childInfo
                                                           parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHRevoluteJoint"]){
        
        LHRevoluteJointNode* jt = [LHRevoluteJointNode nodeWithDictionary:childInfo
                                                                   parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHDistanceJoint"]){
        
        LHDistanceJointNode* jt = [LHDistanceJointNode nodeWithDictionary:childInfo
                                                                   parent:prnt];
        [scene addLateLoadingNode:jt];
        
    }
    else if([nodeType isEqualToString:@"LHPulleyJoint"]){
        
        LHPulleyJointNode* jt = [LHPulleyJointNode nodeWithDictionary:childInfo
                                                               parent:prnt];
        [scene addLateLoadingNode:jt];
        
    }
    else if([nodeType isEqualToString:@"LHPrismaticJoint"]){
        
        LHPrismaticJointNode* jt = [LHPrismaticJointNode nodeWithDictionary:childInfo
                                                                     parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHWheelJoint"]){
        
        LHWheelJointNode* jt = [LHWheelJointNode nodeWithDictionary:childInfo
                                                             parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    else if([nodeType isEqualToString:@"LHGearJoint"]){
        
        LHGearJointNode* jt = [LHGearJointNode nodeWithDictionary:childInfo
                                                           parent:prnt];
        [scene addLateLoadingNode:jt];
    }
    
    
    else{
        NSLog(@"UNKNOWN NODE TYPE %@", nodeType);
    }
    
    return nil;
}


#pragma mark - PROPERTIES
-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(CCNode*)childNodeWithName:(NSString*)name
{
    if([[_node name] isEqualToString:name]){
        return _node;
    }
    
    for(CCNode<LHNodeProtocol>* node in [_node children])
    {
        if([node respondsToSelector:@selector(childNodeWithName:)])
        {
            if([[node name] isEqualToString:name]){
                return node;
            }
            CCNode <LHNodeProtocol>* retNode = [node childNodeWithName:name];
            if(retNode){
                return retNode;
            }
        }
    }
    return nil;

}
-(CCNode*)childNodeWithUUID:(NSString*)uuid;
{
    if([_node respondsToSelector:@selector(uuid)]){
        if([[(CCNode<LHNodeProtocol>*)_node uuid] isEqualToString:uuid]){
            return _node;
        }
    }
    
    for(CCNode<LHNodeProtocol>* node in [_node children])
    {
        if([node respondsToSelector:@selector(uuid)])
        {
            if([[node uuid] isEqualToString:uuid]){
                return node;
            }
            
            if([node respondsToSelector:@selector(childNodeWithUUID:)])
            {
                CCNode<LHNodeProtocol>* retNode = [node childNodeWithUUID:uuid];
                if(retNode){
                    return retNode;
                }
            }
        }
    }
    return nil;
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any
{
    NSMutableArray* temp = [NSMutableArray array];
    for(id<LHNodeProtocol> child in [_node children]){
        if([child conformsToProtocol:@protocol(LHNodeProtocol)])
        {
            NSArray* childTags =[child tags];
            
            int foundCount = 0;
            BOOL foundAtLeastOne = NO;
            for(NSString* tg in childTags)
            {
                for(NSString* st in tagValues){
                    if([st isEqualToString:tg])
                    {
                        ++foundCount;
                        foundAtLeastOne = YES;
                        if(any){
                            break;
                        }
                    }
                }
                
                if(any && foundAtLeastOne){
                    [temp addObject:child];
                    break;
                }
            }
            if(!any && foundAtLeastOne && foundCount == [tagValues count]){
                [temp addObject:child];
            }
            
            if([child respondsToSelector:@selector(childrenWithTags:containsAny:)])
            {
                NSMutableArray* childArray = [child childrenWithTags:tagValues containsAny:any];
                if(childArray){
                    [temp addObjectsFromArray:childArray];
                }
            }
        }
    }
    return temp;
}

-(NSMutableArray*)childrenOfType:(Class)type{
    
    NSMutableArray* temp = [NSMutableArray array];
    for(CCNode* child in [_node children]){

        if([child isKindOfClass:type]){
            [temp addObject:child];
        }
        
        if([child respondsToSelector:@selector(childrenOfType:)])
        {
            NSMutableArray* childArray = [child performSelector:@selector(childrenOfType:)
                                                     withObject:type];
            if(childArray){
                [temp addObjectsFromArray:childArray];
            }
        }
    }
    return temp;
}

-(BOOL)isB2WorldDirty{
    return b2WorldDirty;
}
-(void)markAsB2WorldDirty
{
    b2WorldDirty = true;
    
    for(LHNode* child in [_node children])
    {
        if([child conformsToProtocol:@protocol(LHNodeProtocol)])
        {
            [child markAsB2WorldDirty];
        }
    }
}

@end
