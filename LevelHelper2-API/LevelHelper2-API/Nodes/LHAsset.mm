//
//  LHAsset.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHAsset.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"

#import "LHNode.h"


@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName;
@end

@implementation LHAsset
{
    NSDictionary* tracedFixtures;
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(tracedFixtures);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);

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
        
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        LHScene* scene = (LHScene*)[self scene];
        
        NSDictionary* assetInfo = nil;
        NSString* assetFile = [dict objectForKey:@"assetFile"];
        if(assetFile)
        {
            assetInfo = [scene assetInfoForFile:[dict objectForKey:@"assetFile"]];
        }
        
        if(assetInfo){
            NSDictionary* tracedFix = [assetInfo objectForKey:@"tracedFixtures"];
            if(tracedFix){
                tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFix];
            }
            [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];
        }
        else{
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@. This usually means that the asset was created but not saved. Check your level and in the Scene Navigator, click on the lock icon next to the asset name.", [self name]);
            [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        }
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
#if LH_DEBUG
        [self createDebugNode];
#endif//LH_DEBUG        
    }
    
    return self;
}

-(void)createDebugNode
{
    CCDrawNode* debug = [CCDrawNode node];
    [self addChild:debug];
    [debug setAnchorPoint:CGPointMake(0.5, 0.5)];
    CGPoint* vertices = new CGPoint[4];
    vertices[0] = CGPointMake(0, 0);
    CGSize size = self.contentSize;
    vertices[1] = CGPointMake(size.width, 0);
    vertices[2] = CGPointMake(size.width, size.height);
    vertices[3] = CGPointMake(0, size.height);
    CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(0, 1, 0, 1)];
    CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(0, 1, 0, 0.3)];
    
    [debug drawPolyWithVerts:vertices
                       count:4
                   fillColor:fillColor
                 borderWidth:1 borderColor:borderColor];
    
    delete[] vertices;
}

+(instancetype)createWithName:(NSString*)assetName
                assetFileName:(NSString*)fileName
                       parent:(CCNode*)prnt
{
    return LH_AUTORELEASED([[self alloc] initWithName:assetName
                                        assetFileName:fileName
                                               parent:prnt]);
}

- (instancetype)initWithName:(NSString*)newName
               assetFileName:(NSString*)fileName
                      parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:newName];
        
        LHScene* scene = (LHScene*)[prnt scene];
        
        NSDictionary* assetInfo = [scene assetInfoForFile:fileName];
        
        if(!assetInfo)
        {
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@", [self name]);
            return self;
        }
        
        
        NSDictionary* tracedFix = [assetInfo objectForKey:@"tracedFixtures"];
        if(tracedFix){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFix];
        }        
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:assetInfo
                                                                                    node:self];
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:assetInfo
                                                                                                node:self];

        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:assetInfo];

        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:assetInfo
                                                                                                      node:self];
    
    }
    
#if LH_DEBUG
    [self createDebugNode];
#endif//LH_DEBUG
    
    [self visit];//very important - if asset contains joint - all objects must be updated before that joint is created
    
    return self;
}

-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

- (void)visit
{
    [_physicsProtocolImp visit];
    [_animationProtocolImp visit];
    
    [super visit];
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION


@end
