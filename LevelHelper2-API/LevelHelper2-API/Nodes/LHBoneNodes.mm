//
//  LHBoneNodes.mm
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHBoneNodes.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHAnimation.h"

@implementation LHBoneNodes
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
 
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
        
    }
    
    return self;
}

#if COCOS2D_VERSION >= 0x00030300
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    if(renderer)
        [super visit:renderer parentTransform:parentTransform];
}
#else
- (void)visit
{
    [super visit];
}
#endif//cocos2d_version


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
