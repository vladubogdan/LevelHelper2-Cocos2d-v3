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


@implementation LHUtils

//+(id)userPropertyForNode:(id)node fromDictionary:(NSDictionary*)dict
//{
//    id _userProperty = nil;
//    
//    NSDictionary* userPropInfo = [dict objectForKey:@"userPropertyInfo"];
//    NSString* userPropClassName = [dict objectForKey:@"userPropertyName"];
//    if(userPropInfo && userPropClassName)
//    {
//        Class userPropClass = NSClassFromString(userPropClassName);
//        if(userPropClass){
//    #pragma clang diagnostic push
//    #pragma clang diagnostic ignored "-Wundeclared-selector"
//            _userProperty = [userPropClass performSelector:@selector(customClassInstanceWithNode:)
//                                                withObject:node];
//    #pragma clang diagnostic pop
//            if(_userProperty){
//                [_userProperty setPropertiesFromDictionary:userPropInfo];
//            }
//        }
//    }
//    
//    return _userProperty;
//}
//
//+(void)tagsFromDictionary:(NSDictionary*)dict
//             savedToArray:(NSArray* __strong*)_tags
//{
//    NSArray* loadedTags = [dict objectForKey:@"tags"];
//    if(loadedTags){
//        *_tags = [[NSArray alloc] initWithArray:loadedTags];
//    }
//}

+(void)createAnimationsForNode:(id)node
               animationsArray:(NSMutableArray* __strong*)_animations
               activeAnimation:(LHAnimation* __weak*)activeAnimation
                fromDictionary:(NSDictionary*)dict
{
    NSArray* animsInfo = [dict objectForKey:@"animations"];
    for(NSDictionary* anim in animsInfo){
        if(!*_animations){
            *_animations = [[NSMutableArray alloc] init];
        }
        LHAnimation* animation = [LHAnimation animationWithDictionary:anim
                                                                 node:node];
        if([animation isActive]){
            *activeAnimation = animation;
        }
        [*_animations addObject:animation];
    }
}

+(NSString*)imagePathWithFilename:(NSString*)filename
                           folder:(NSString*)folder
                           suffix:(NSString*)suffix
{
    NSString* ext = [filename pathExtension];
    NSString* fileNoExt = [filename stringByDeletingPathExtension];
#if TARGET_OS_IPHONE
    return [[folder stringByAppendingPathComponent:fileNoExt] stringByAppendingPathExtension:ext];
//    return [[[folder stringByAppendingPathComponent:fileNoExt] stringByAppendingString:suffix] stringByAppendingPathExtension:ext];
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
    
    
    CGSize designSize = [scene designResolutionSize];
    CGPoint offset = [scene designOffset];
    
    CGPoint designPos = CGPointZero;
    
    if([node parent] == [scene physicsNode]){
        designPos = CGPointMake(designSize.width*unitPos.x,
                                (designSize.height - designSize.height*unitPos.y));
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

+(void)loadPhysicsFromDict:(NSDictionary*)dict
                   forNode:(CCNode*)node
{
    if(!dict)return;
    
    int shape = [dict intForKey:@"shape"];
    int type = [dict intForKey:@"type"];
    
    NSMutableArray* fixShapes = [NSMutableArray array];

    NSArray* fixturesInfo = nil;
    
    if(shape == 0)//RECTANGLE
    {
        CGPoint offset = CGPointMake(0, 0);
        CGRect bodyRect = CGRectMake(offset.x,
                                     offset.y,
                                     node.contentSize.width,
                                     node.contentSize.height);
        
        node.physicsBody = [CCPhysicsBody bodyWithRect:bodyRect cornerRadius:0];
    }
    else if(shape == 1)//CIRCLE
    {
        CGPoint offset = CGPointMake(node.contentSize.width*0.5,
                                     node.contentSize.height*0.5);
        node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:node.contentSize.width*0.5
                                                       andCenter:offset];
    }
    else if(shape == 3)//CHAIN
    {
        if([node isKindOfClass:[LHBezier class]])
        {
            NSMutableArray* points = [(LHBezier*)node linePoints];
            
            NSValue* prevValue = nil;
            for(NSValue* val in points){
            
                if(prevValue)
                {
                    CGPoint ptA = CGPointFromValue(prevValue);
                    CGPoint ptB = CGPointFromValue(val);
                    CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
                                                                       to:ptB
                                                             cornerRadius:0];
                    [fixShapes addObject:shape];
                }
                
                prevValue = val;
            }
            
            node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
        }
        else if([node isKindOfClass:[LHShape class]])
        {
            NSArray* points = [(LHShape*)node outlinePoints];

            NSValue* firstValue = nil;
            NSValue* prevValue = nil;
            for(NSValue* val in points){
                
                if(prevValue)
                {
                    CGPoint ptA = CGPointFromValue(prevValue);
                    CGPoint ptB = CGPointFromValue(val);
                    CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
                                                                       to:ptB
                                                             cornerRadius:0];
                    [fixShapes addObject:shape];
                }
                
                if(nil == firstValue){
                    firstValue = val;
                }
                prevValue = val;
            }
            
            //close the shape
            if(prevValue && firstValue){
                CGPoint ptA = CGPointFromValue(prevValue);
                CGPoint ptB = CGPointFromValue(firstValue);
                CCPhysicsShape* shape = [CCPhysicsShape pillShapeFrom:ptA
                                                                   to:ptB
                                                         cornerRadius:0];
                [fixShapes addObject:shape];
            }
            
            node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
        }
        else{        
            type = 0;
            
            CGPoint offset = CGPointMake(0, 0);
            CGRect bodyRect = CGRectMake(offset.x,
                                         offset.y,
                                         node.contentSize.width,
                                         node.contentSize.height);
            
            node.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:bodyRect
                                                          cornerRadius:0];
        }
        
    }
    else if(shape == 4)//OVAL
    {
        fixturesInfo = [dict objectForKey:@"ovalShape"];
    }
    else if(shape == 5)//TRACED
    {
        NSString* fixUUID = [dict objectForKey:@"fixtureUUID"];
        LHScene* scene = (LHScene*)[node scene];
        fixturesInfo = [scene tracedFixturesWithUUID:fixUUID];
    }
    else if(shape == 2)//POLYGON
    {
        
        if([node isKindOfClass:[LHShape class]])
        {
            NSArray* trianglePoints = [(LHShape*)node trianglePoints];
            
            for(int i = 0; i < [trianglePoints count]; i+=3)
            {
                NSValue* valA = [trianglePoints objectAtIndex:i];
                NSValue* valB = [trianglePoints objectAtIndex:i+1];
                NSValue* valC = [trianglePoints objectAtIndex:i+2];
                
                CGPoint ptA = CGPointFromValue(valA);
                CGPoint ptB = CGPointFromValue(valB);
                CGPoint ptC = CGPointFromValue(valC);
                
                CGPoint points[3];
                
                points[0] = ptA;
                points[1] = ptB;
                points[2] = ptC;
                
                
                CCPhysicsShape* shape = [CCPhysicsShape polygonShapeWithPoints:points count:3 cornerRadius:0];
                [fixShapes addObject:shape];
            }
        }
    }
    
    if(fixturesInfo)
    {
        for(NSArray* fixPoints in fixturesInfo)
        {
            int count = (int)[fixPoints count];
            CGPoint points[count];
            
            int i = count - 1;
            for(int j = 0; j< count; ++j)
            {
                NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
                CGPoint point = LHPointFromString(pointStr);
                
                point.x += node.contentSize.width*0.5;
                point.y -= node.contentSize.height*0.5;
                point.y = -point.y;
                
                
                points[j] = point;
                i = i-1;
            }
            
            CCPhysicsShape* shape = [CCPhysicsShape polygonShapeWithPoints:points count:count cornerRadius:0];
            [fixShapes addObject:shape];
        }
    }
    if([fixShapes count] > 0){
        node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
    }
    
    if(type == 0)//static
    {
        [node.physicsBody setType:CCPhysicsBodyTypeStatic];
    }
    else if(type == 1)//kinematic
    {
    }
    else if(type == 2)//dynamic
    {
        [node.physicsBody setType:CCPhysicsBodyTypeDynamic];
    }
    
    NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
    if(fixInfo && node.physicsBody)
    {
        NSArray* collisionCats = [fixInfo objectForKey:@"collisionCategories"];
        NSArray* ignoreCats = [fixInfo objectForKey:@"ignoreCategories"];
        if(!ignoreCats || [ignoreCats count] == 0){
            collisionCats = nil;
            ignoreCats = nil;
        }
        
        if([fixShapes count] > 0)
        {
            for(CCPhysicsShape* shape in fixShapes)
            {
                shape.density = [fixInfo floatForKey:@"density"];
                shape.friction = [fixInfo floatForKey:@"friction"];
                shape.elasticity = [fixInfo floatForKey:@"restitution"];
                shape.sensor = [fixInfo boolForKey:@"sensor"];
                
                if(ignoreCats)
                    [shape setCollisionCategories:ignoreCats];//member of
                if(collisionCats)
                    [shape setCollisionMask:collisionCats];//wants to collide with
            }
        }
        else{
            
            if(ignoreCats)
                [node.physicsBody setCollisionCategories:ignoreCats];//member of
            if(collisionCats)
                [node.physicsBody setCollisionMask:collisionCats];//wants to collide with
            
            if(shape != 3){
                node.physicsBody.density = [fixInfo floatForKey:@"density"];
                node.physicsBody.friction = [fixInfo floatForKey:@"friction"];
                node.physicsBody.elasticity = [fixInfo floatForKey:@"restitution"];
                node.physicsBody.sensor = [fixInfo boolForKey:@"sensor"];
            }
        }
        
        if(node.physicsBody.type == CCPhysicsBodyTypeDynamic)
            node.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
        
        if([dict intForKey:@"gravityScale"] == 0){
            node.physicsBody.affectedByGravity = NO;
        }
    }
}


#if TARGET_OS_IPHONE
+(LHDevice*)currentDeviceFromArray:(NSArray*)arrayOfDevs{
    return [LHUtils deviceFromArray:arrayOfDevs
                           withSize:LH_SCREEN_RESOLUTION];
}
#endif

+(LHDevice*)deviceFromArray:(NSArray*)arrayOfDevs
                   withSize:(CGSize)size
{
    for(LHDevice* dev in arrayOfDevs){
        if(CGSizeEqualToSize([dev size], size)){
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


