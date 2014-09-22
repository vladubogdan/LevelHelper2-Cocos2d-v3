//
//  LHUtils.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 25/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHUserPropertyProtocol.h"
#import "LHAnimation.h"
#import "LHBezier.h"
#import "LHShape.h"

#import "LHGameWorldNode.h"
#import "LHUINode.h"
#import "LHBackUINode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGSize)designResolutionSize;
-(CGPoint)designOffset;
@end


@implementation LHUtils


+(NSString*)imagePathWithFilename:(NSString*)filename
                           folder:(NSString*)folder
                           suffix:(NSString*)suffix
{

    NSString* ext = [filename pathExtension];
    NSString* fileNoExt = [filename stringByDeletingPathExtension];
#if TARGET_OS_IPHONE    
    return [[[folder stringByAppendingPathComponent:fileNoExt] stringByAppendingString:suffix] stringByAppendingPathExtension:ext];
    
    //no longer using this as cocos2d and iphone 6,6+ not friendly
//    return [[folder stringByAppendingPathComponent:fileNoExt] stringByAppendingPathExtension:ext];
#else
    NSString* fileName = [fileNoExt stringByAppendingString:suffix];
    NSString* val = [[NSBundle mainBundle] pathForResource:fileName ofType:ext inDirectory:folder];
    
    if(!val){
        return fileName;
    }
    return val;
#endif
}

+(NSString*)devicePosition:(NSDictionary*)availablePositions forSize:(CGSize)curScr{
    return [availablePositions objectForKey:[NSString stringWithFormat:@"%dx%d", (int)curScr.width, (int)curScr.height]];
}

+(CGPoint)positionForNode:(CCNode*)node
                 fromUnit:(CGPoint)unitPos
{
    LHScene* scene = (LHScene*)[node scene];
    
    CGSize designSize   = [scene designResolutionSize];
    CGPoint offset      = [scene designOffset];
    
    CGPoint designPos   = CGPointZero;

    designPos = CGPointMake(designSize.width*unitPos.x,
                            designSize.height*(-unitPos.y));
    
    
    if([node parent] == nil ||
       [node parent] == scene ||
       [node parent] == [scene gameWorldNode] ||
       [node parent] == [scene uiNode]  ||
       [node parent] == [scene backUiNode])
    {
        
        designPos.y = designSize.height + designPos.y;
        designPos.x += offset.x;
        designPos.y += offset.y;
    }
    else{
        
        designPos = CGPointMake(designSize.width*unitPos.x,
                                ([node parent].contentSize.height - designSize.height*unitPos.y));
        
        CCNode* p = [node parent];
        designPos.x += p.contentSize.width*0.5;
        designPos.y -= p.contentSize.height*0.5;
    }
    
    return designPos;
}


+(LHDevice*)currentDeviceFromArray:(NSArray*)arrayOfDevs{
    return [LHUtils deviceFromArray:arrayOfDevs
                           withSize:LH_SCREEN_RESOLUTION];
}

+(LHDevice*)deviceFromArray:(NSArray*)arrayOfDevs
                   withSize:(CGSize)size
{
    for(LHDevice* dev in arrayOfDevs){
        if(CGSizeEqualToSize([dev size], size)){
            return dev;
        }
        if(CGSizeEqualToSize([dev size], CGSizeMake(size.height, size.width))){
            return dev;
        }
    }
    return nil;
}

@end


@implementation LHDevice

-(void)dealloc{
    LH_SAFE_RELEASE(suffix);
    LH_SUPER_DEALLOC();
}

+(id)deviceWithDictionary:(NSDictionary*)dict{
    return LH_AUTORELEASED([[LHDevice alloc] initWithDictionary:dict]);
}
-(id)initWithDictionary:(NSDictionary*)dict{
    if(self = [super init]){
        
        size = [dict sizeForKey:@"size"];
        suffix = [[NSString alloc] initWithString:[dict objectForKey:@"suffix"]];
        ratio = [dict floatForKey:@"ratio"];
        
    }
    return self;
}

-(CGSize)size{
    return size;
}
-(NSString*)suffix{
    return suffix;
}
-(float)ratio{
    return ratio;
}

@end


