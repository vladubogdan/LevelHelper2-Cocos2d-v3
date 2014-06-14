//
//  LHNodePhysicsProtocol.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 14/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHNodePhysicsProtocol.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"

#import "LHBezier.h"
#import "LHShape.h"

@implementation LHNodePhysicsProtocolImp
{
    __weak CCNode* _node;
}

-(void)dealloc{
    _node = nil;
    LH_SUPER_DEALLOC();
}

+ (instancetype)physicsProtocolImpWithDictionary:(NSDictionary*)dict node:(CCNode*)nd{
    return LH_AUTORELEASED([[self alloc] initPhysicsProtocolImpWithDictionary:dict node:nd]);
}

- (instancetype)initPhysicsProtocolImpWithDictionary:(NSDictionary*)dictionary node:(CCNode*)nd{
    
    if(self = [super init])
    {
        _node = nd;

        NSDictionary* dict = [dictionary objectForKey:@"nodePhysics"];
        
        if(!dict){
            return self;
        }
        
        int shape = [dict intForKey:@"shape"];
        int type = [dict intForKey:@"type"];
        
        NSMutableArray* fixShapes = [NSMutableArray array];
        
        NSArray* fixturesInfo = nil;
        
        if(shape == 0)//RECTANGLE
        {
            CGPoint offset = CGPointMake(0, 0);
            CGRect bodyRect = CGRectMake(offset.x,
                                         offset.y,
                                         _node.contentSize.width,
                                         _node.contentSize.height);
            
            _node.physicsBody = [CCPhysicsBody bodyWithRect:bodyRect cornerRadius:0];
        }
        else if(shape == 1)//CIRCLE
        {
            CGPoint offset = CGPointMake(_node.contentSize.width*0.5,
                                         _node.contentSize.height*0.5);
            _node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:_node.contentSize.width*0.5
                                                           andCenter:offset];
        }
        else if(shape == 3)//CHAIN
        {
            if([_node isKindOfClass:[LHBezier class]])
            {
                NSMutableArray* points = [(LHBezier*)_node linePoints];
                
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
                
                _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
            }
            else if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* points = [(LHShape*)_node outlinePoints];
                
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
                
                _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
            }
            else{
                type = 0;
                
                CGPoint offset = CGPointMake(0, 0);
                CGRect bodyRect = CGRectMake(offset.x,
                                             offset.y,
                                             _node.contentSize.width,
                                             _node.contentSize.height);
                
                _node.physicsBody = [CCPhysicsBody bodyWithPolylineFromRect:bodyRect
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
            LHScene* scene = (LHScene*)[_node scene];
            fixturesInfo = [scene tracedFixturesWithUUID:fixUUID];
        }
        else if(shape == 2)//POLYGON
        {
            
            if([_node isKindOfClass:[LHShape class]])
            {
                NSArray* trianglePoints = [(LHShape*)_node trianglePoints];
                
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
                    
                    point.x += _node.contentSize.width*0.5;
                    point.y -= _node.contentSize.height*0.5;
                    point.y = -point.y;
                    
                    
                    points[j] = point;
                    i = i-1;
                }
                
                CCPhysicsShape* shape = [CCPhysicsShape polygonShapeWithPoints:points count:count cornerRadius:0];
                [fixShapes addObject:shape];
            }
        }
        if([fixShapes count] > 0){
            _node.physicsBody =  [CCPhysicsBody bodyWithShapes:fixShapes];
        }
        
        if(type == 0)//static
        {
            [_node.physicsBody setType:CCPhysicsBodyTypeStatic];
        }
        else if(type == 1)//kinematic
        {
        }
        else if(type == 2)//dynamic
        {
            [_node.physicsBody setType:CCPhysicsBodyTypeDynamic];
        }
        
        NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
        if(fixInfo && _node.physicsBody)
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
                    [_node.physicsBody setCollisionCategories:ignoreCats];//member of
                if(collisionCats)
                    [_node.physicsBody setCollisionMask:collisionCats];//wants to collide with
                
                if(shape != 3){
                    _node.physicsBody.density = [fixInfo floatForKey:@"density"];
                    _node.physicsBody.friction = [fixInfo floatForKey:@"friction"];
                    _node.physicsBody.elasticity = [fixInfo floatForKey:@"restitution"];
                    _node.physicsBody.sensor = [fixInfo boolForKey:@"sensor"];
                }
            }
            
            if(_node.physicsBody.type == CCPhysicsBodyTypeDynamic)
                _node.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
            
            if([dict intForKey:@"gravityScale"] == 0){
                _node.physicsBody.affectedByGravity = NO;
            }
        }
        
        
    }
    return self;
}

@end
