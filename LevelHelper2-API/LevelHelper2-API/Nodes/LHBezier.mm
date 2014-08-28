//
//  LHBezier.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHBezier.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHAnimation.h"
#import "LHConfig.h"
#import "LHDrawNode.h"

static float MAX_BEZIER_STEPS = 24.0f;

@implementation LHBezier
{
    NSMutableArray* linePoints;

    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
}

-(void)dealloc{

    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    
    
    LH_SAFE_RELEASE(linePoints);

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
        
        CCColor* colorOverlay = [dict colorForKey:@"colorOverlay"];
                
        NSArray* points = [dict objectForKey:@"points"];
        BOOL closed = [dict boolForKey:@"closed"];
        
        linePoints = [[NSMutableArray alloc] init];
        
        NSValue* prevValue = nil;

        //strange behaviour when using chipmunk - looks like some transformation bug inside cocos2d
#if LH_USE_BOX2D == 0
        CGPoint loadedPosition = self.position;
        self.position = CGPointZero;
        self.contentSize = CGSizeZero;//we reset the content size as it does problem in cocos2d
#endif
        
        NSDictionary* previousPointDict = nil;
        for(NSDictionary* pointDict in points)
        {
            if(previousPointDict != nil)
            {
                CGPoint control1 = [previousPointDict pointForKey:@"ctrl2"];
                if(![previousPointDict boolForKey:@"hasCtrl2"]){
                    control1 = [previousPointDict pointForKey:@"mainPt"];
                }
                
                CGPoint control2 = [pointDict pointForKey:@"ctrl1"];
                if(![pointDict boolForKey:@"hasCtrl1"]){
                    control2 = [pointDict pointForKey:@"mainPt"];
                }
                
                CGPoint vPoint = {0.0f, 0.0f};
                for(float t = 0.0; t <= (1 + (1.0f / MAX_BEZIER_STEPS)); t += 1.0f / MAX_BEZIER_STEPS)
                {
                    vPoint = LHPointOnCurve([previousPointDict pointForKey:@"mainPt"],
                                            control1,
                                            control2,
                                            [pointDict pointForKey:@"mainPt"],
                                            t);
                    
                    CGPoint pt = CGPointMake(vPoint.x, -vPoint.y);
                    

                    if(prevValue){
                        CGPoint prevPt = CGPointFromValue(prevValue);
                        CGPoint curPt = pt;
                        
#if LH_USE_BOX2D
                        prevPt.x += self.contentSize.width*0.5;
                        prevPt.y += self.contentSize.height*0.5;
                        curPt.x += self.contentSize.width*0.5;
                        curPt.y += self.contentSize.height*0.5;
#endif

                        [self drawSegmentFrom:prevPt to:curPt radius:1 color:colorOverlay];
                    }
                    prevValue = LHValueWithCGPoint(pt);
                    
                    [linePoints addObject:prevValue];
                }
            }
            previousPointDict = pointDict;
        }
        if(closed){
            if([points count] > 1)
            {
                NSDictionary* ptDict = [points objectAtIndex:0];
                
                CGPoint control1 = [previousPointDict pointForKey:@"ctrl2"];
                if(![previousPointDict boolForKey:@"hasCtrl2"]){
                    control1 =  [previousPointDict pointForKey:@"mainPt"];
                }
                
                CGPoint control2 = [ptDict pointForKey:@"ctrl1"];
                if(![ptDict boolForKey:@"hasCtrl1"]){
                    control2 = [ptDict pointForKey:@"mainPt"];
                }
                
                CGPoint vPoint = {0.0f, 0.0f};
                for(float t = 0; t <= (1 + (1.0f / MAX_BEZIER_STEPS)); t += 1.0f / MAX_BEZIER_STEPS)
                {
                    vPoint = LHPointOnCurve([previousPointDict pointForKey:@"mainPt"],
                                            control1,
                                            control2,
                                            [ptDict pointForKey:@"mainPt"],
                                            t);
                 
                    CGPoint pt = CGPointMake(vPoint.x, -vPoint.y);
                    if(prevValue){
                        CGPoint prevPt = CGPointFromValue(prevValue);
                        CGPoint curPt = pt;
#if LH_USE_BOX2D
                        prevPt.x += self.contentSize.width*0.5;
                        prevPt.y += self.contentSize.height*0.5;
                        curPt.x += self.contentSize.width*0.5;
                        curPt.y += self.contentSize.height*0.5;
#endif
                        
                        
                        [self drawSegmentFrom:prevPt to:curPt radius:1 color:colorOverlay];
                    }
                    prevValue = LHValueWithCGPoint(pt);
                    
                    [linePoints addObject:prevValue];
                }
            }
        }

        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
#if LH_USE_BOX2D == 0
        self.position = loadedPosition;
#endif
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];

        
    }
    
    return self;
}

-(NSMutableArray*)linePoints{
    return linePoints;
}


-(void)visit
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


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
