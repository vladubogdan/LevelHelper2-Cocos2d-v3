//
//  LHNodeProtocol.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
/**
 Most of the LevelHelper-2 nodes conforms to this protocol.
 */
@class LHScene;

@protocol LHNodeAnimationProtocol;
@protocol LHUserPropertyProtocol;

@protocol LHNodeProtocol <NSObject>

@required
////////////////////////////////////////////////////////////////////////////////
/**
 Returns the unique name of the node.
 */
-(NSString*)name;


/**
 Returns the unique identifier of the node.
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
 Returns the scene to which this node belongs to.
 */
-(LHScene*)scene;

@optional
////////////////////////////////////////////////////////////////////////////////

/**
 Returns a node with the specified unique name or nil if that node is not found in the children hierarchy.
 @param name The unique name of the node.
 @return A node or or nil.
 */
-(CCNode <LHNodeProtocol>*)childNodeWithName:(NSString*)name;

/**
 Returns a node with the specified unique identifier or nil if that node is not found in the children hierarchy.
 @param uuid The unique idenfier of the node.
 @return A node or or nil.
 */
-(CCNode <LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid;

/**
 Returns all children nodes that have the specified tag values. 
 @param tagValues An array containing tag names. Array of NSString's.
 @param any Specify if all or just one tag value of the node needs to be in common with the passed ones.
 @return An array of nodes.
 */
-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any;

/**
 Returns all children nodes that are of specified class type.
 @param type A "Class" type.
 @return An array with all the found nodes of the specified class.
 */
-(NSMutableArray*)childrenOfType:(Class)type;

-(BOOL)lateLoading;

-(BOOL)isB2WorldDirty;
-(void)markAsB2WorldDirty;

@end



#pragma mark - LHNodeProtocol Implementation

@interface LHNodeProtocolImpl : NSObject

+ (instancetype)nodeProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;
- (instancetype)initNodeProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd;
- (instancetype)initNodeProtocolImpWithNode:(CCNode*)nd;

+(void)loadChildrenForNode:(CCNode*)prntNode fromDictionary:(NSDictionary*)dict;

-(NSString*)uuid;
-(NSArray*)tags;
-(id<LHUserPropertyProtocol>)userProperty;

-(CCNode <LHNodeProtocol>*)childNodeWithName:(NSString*)name;
-(CCNode <LHNodeProtocol>*)childNodeWithUUID:(NSString*)uuid;
-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any;
-(NSMutableArray*)childrenOfType:(Class)type;

-(BOOL)isB2WorldDirty;
-(void)markAsB2WorldDirty;
@end


#define LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION  \
-(BOOL)isB2WorldDirty{\
    return [_nodeProtocolImp isB2WorldDirty];\
}\
-(void)markAsB2WorldDirty{\
    [_nodeProtocolImp markAsB2WorldDirty];\
}\
-(NSString*)uuid{\
return [_nodeProtocolImp uuid];\
}\
\
-(NSArray*)tags{ \
    return [_nodeProtocolImp tags]; \
} \
\
-(id<LHUserPropertyProtocol>)userProperty{\
    return [_nodeProtocolImp userProperty];\
}\
\
-(CCNode*)childNodeWithName:(NSString*)name{\
    return [_nodeProtocolImp childNodeWithName:name];\
}\
\
-(CCNode*)childNodeWithUUID:(NSString*)uuid{\
    return [_nodeProtocolImp childNodeWithUUID:uuid];\
}\
\
-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any{\
    return [_nodeProtocolImp childrenWithTags:tagValues containsAny:any];\
}\
\
-(NSMutableArray*)childrenOfType:(Class)type{\
    return [_nodeProtocolImp childrenOfType:type];\
}\
