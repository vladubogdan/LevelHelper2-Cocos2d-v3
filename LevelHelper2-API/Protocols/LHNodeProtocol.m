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

@implementation LHNodeProtocolImpl
{
    __weak id _node;
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
    }
    return self;
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
//-(LHScene*)scene{
//    return (LHScene*)[(CCNode*)_node scene];
//}

-(CCNode <LHNodeProtocol>*)childNodeWithName:(NSString*)name
{
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
-(CCNode <LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid;
{
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

@end
