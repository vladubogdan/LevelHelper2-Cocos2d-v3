//
//  LHSprite.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSprite.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHAnimation.h"
#import "LHConfig.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix:(BOOL)keep2x;

-(void)setEditorBodyInfoForSpriteName:(NSString*)sprName
                                atlas:(NSString*)atlasPlist
                             bodyInfo:(NSDictionary*)bodyInfo;
-(NSDictionary*)getEditorBodyInfoForSpriteName:(NSString*)sprName
                                         atlas:(NSString*)atlasPlist;
-(BOOL)hasEditorBodyInfoForImageFilePath:(NSString*)atlasImgFile;
@end

@interface CCSpriteFrameCache (LH_SPRITE_FRAME_CACHE_DICTIONARY_SAVING)
-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary
                     textureReference:(id)textureReference;
@end

@implementation LHSprite
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
    
    NSString* _imageFilePath;
    NSString* _spriteFrameName;
}


-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);

    LH_SAFE_RELEASE(_imageFilePath);
    LH_SAFE_RELEASE(_spriteFrameName);
    
    LH_SUPER_DEALLOC();
}

-(NSString*)imageFilePath{
    return _imageFilePath;
}
-(NSString*)spriteFrameName{
    return _spriteFrameName;
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                         parent:prnt]);
}

-(void)cacheSpriteFramesInfo:(NSString*)imageDevPath scene:(LHScene*)scene texture:(CCTexture*)texture
{
    NSString* atlasPlist = [[imageDevPath lastPathComponent] stringByDeletingPathExtension];
    atlasPlist = [[scene relativePath] stringByAppendingPathComponent:atlasPlist];
    atlasPlist = [atlasPlist stringByAppendingPathExtension:@"plist"];

    
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:atlasPlist];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
//    NSLog(@"CACHE SPRITES FRAME INFO %@ %@", path, dict);
    
    if(dict){
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithDictionary:dict
                                                                  textureReference:texture];

        NSDictionary* framesDict = [dict objectForKey:@"frames"];
        
        NSArray* allKeys = [framesDict allKeys];

        //here we add all bodies info found in this plist file
        //I do it this way in order to avoid loading the file again
        //this way - we only read this plist file once

        for(NSString* sprName in allKeys)
        {
            NSDictionary* frmInfo = [framesDict objectForKey:sprName];
            if(frmInfo)
            {
                NSDictionary* bodyInfo = [frmInfo objectForKey:@"body"];
                if(bodyInfo)
                {
                    [scene setEditorBodyInfoForSpriteName:sprName atlas:imageDevPath bodyInfo:bodyInfo];
                }
            }
        }
    }
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt{

    LHScene* scene = (LHScene*)[prnt scene];
    
    NSString* imagePath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                  folder:[dict objectForKey:@"relativeImagePath"]
                                                  suffix:[scene currentDeviceSuffix:NO]];

    NSString* imageDevPath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                  folder:[dict objectForKey:@"relativeImagePath"]
                                                  suffix:[scene currentDeviceSuffix:YES]];
    
    CCTexture* texture = [scene textureWithImagePath:imagePath];
    
    CCSpriteFrame* spriteFrame = nil;

    _imageFilePath = [[NSString alloc] initWithString:imageDevPath];

    NSString* spriteFrameName = [dict objectForKey:@"spriteName"];
    if(spriteFrameName){
        
        
        if(NULL == [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName]
           ||  false == [scene hasEditorBodyInfoForImageFilePath:imageDevPath])
        {
            //dont reload if already loaded
            [self cacheSpriteFramesInfo:imageDevPath scene:scene texture:texture];
            //we are no longer using this method because we need to load the physics info if available
            //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:atlasPlist texture:texture];
        }
        
        spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
        
        _spriteFrameName = [[NSString alloc] initWithString:spriteFrameName];
    }
    else{
        spriteFrame = [texture createSpriteFrame];
    }

    
    
    
    if(self = [super initWithSpriteFrame:spriteFrame]){
        
        [prnt addChild:self];
        
        [self setColor:[dict colorForKey:@"colorOverlay"]];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];        
    }
    return self;
}

-(void)setSpriteFrameWithName:(NSString*)spriteFrameName{
    CCSpriteFrame* spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
    if(spriteFrame){
        [self setSpriteFrame:spriteFrame];
    }
}

#if COCOS2D_VERSION >= 0x00030300
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    [_physicsProtocolImp visit];
    [_animationProtocolImp visit];

    if(renderer)
        [super visit:renderer parentTransform:parentTransform];
}
#else
- (void)visit
{
    [_physicsProtocolImp visit];
    [_animationProtocolImp visit];

    [super visit];
}
#endif//cocos2d_version
    

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
