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

@implementation LHAsset
{
    CGSize _size;
    
    NSString* _uuid;
    NSArray* _tags;
    id<LHUserPropertyProtocol> _userProperty;
    
    NSMutableArray* _animations;
    __weak LHAnimation* activeAnimation;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_uuid);
    LH_SAFE_RELEASE(_tags);
    LH_SAFE_RELEASE(_userProperty);
    
    LH_SAFE_RELEASE(_animations);
    activeAnimation = nil;
    
    LH_SUPER_DEALLOC();
}


+ (instancetype)assetWithDictionary:(NSDictionary*)dict
                             parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initAssetWithDictionary:dict
                                                          parent:prnt]);
}

- (instancetype)initAssetWithDictionary:(NSDictionary*)dict
                                 parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        [self setName:[dict objectForKey:@"name"]];

        _uuid = [[NSString alloc] initWithString:[dict objectForKey:@"uuid"]];
        [LHUtils tagsFromDictionary:dict
                       savedToArray:&_tags];
        _userProperty = [LHUtils userPropertyForNode:self fromDictionary:dict];
        
        _size = [dict sizeForKey:@"size"];
        
        CGPoint unitPos = [dict pointForKey:@"generalPosition"];
        CGPoint pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
        
        NSDictionary* devPositions = [dict objectForKey:@"devicePositions"];
        if(devPositions)
        {
            
#if TARGET_OS_IPHONE
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:LH_SCREEN_RESOLUTION];
#else
            LHScene* scene = (LHScene*)[self scene];
            NSString* unitPosStr = [LHUtils devicePosition:devPositions
                                                   forSize:scene.size];
#endif
            
            if(unitPosStr){
                CGPoint unitPos = LHPointFromString(unitPosStr);
                pos = [LHUtils positionForNode:self
                                      fromUnit:unitPos];
            }
        }
        
        [self setPosition:pos];

        float alpha = [dict floatForKey:@"alpha"];
        [self setOpacity:alpha/255.0f];
        
        float rot = [dict floatForKey:@"rotation"];
        [self setRotation:rot];
        
        float z = [dict floatForKey:@"zOrder"];
        [self setZOrder:z];
        
        [LHUtils loadPhysicsFromDict:[dict objectForKey:@"nodePhysics"]
                             forNode:self];
        
        //scale must be set after loading the physic info or else spritekit will not resize the body
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setScaleX:scl.x];
        [self setScaleY:scl.y];

        LHScene* scene = (LHScene*)[self scene];
        
        NSDictionary* assetInfo = [scene assetInfoForFile:[dict objectForKey:@"assetFile"]];
        
        if(assetInfo)
        {
            NSArray* childrenInfo = [assetInfo objectForKey:@"children"];
            if(childrenInfo)
            {
                for(NSDictionary* childInfo in childrenInfo)
                {
                    CCNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                                parent:self];
                    #pragma unused (node)
                }
            }
        }
        else{
            NSLog(@"WARNING: COULD NOT FIND INFORMATION FOR ASSET %@", [self name]);
        }
        
        [LHUtils createAnimationsForNode:self
                         animationsArray:&_animations
                         activeAnimation:&activeAnimation
                          fromDictionary:dict];

    }
    
    return self;
}

//-(void)loadPhysicsFromDict:(NSDictionary*)dict{
//    
//    if(!dict)return;
//    
//    int shape = [dict intForKey:@"shape"];
//    
//    NSArray* fixturesInfo = nil;
//    
//#ifdef LH_DEBUG
//    NSMutableArray* debugShapeNodes = [NSMutableArray array];
//#endif
//    
//    
//    if(shape == 0)//RECTANGLE
//    {
//        CGPoint offset = CGPointMake(0, 0);
//        CGRect rect = CGRectMake(-self.size.width*0.5 + offset.x,
//                                 -self.size.height*0.5 + offset.y,
//                                 self.size.width,
//                                 self.size.height);
//        
//        CGSize rectSize = CGSizeMake(rect.size.width,
//                                     rect.size.height);
//
//        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rectSize];
//        
//#ifdef LH_DEBUG
//        SKShapeNode* debugShapeNode = [SKShapeNode node];
//        debugShapeNode.path = CGPathCreateWithRect(rect,
//                                                   nil);
//        
//        [debugShapeNodes addObject:debugShapeNode];
//#endif
//        
//    }
//    else if(shape == 1)//CIRCLE
//    {
//        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width*0.5];
//#ifdef LH_DEBUG
//        CGPoint offset = CGPointMake(0, 0);
//        SKShapeNode* debugShapeNode = [SKShapeNode node];
//        debugShapeNode.path = CGPathCreateWithEllipseInRect(CGRectMake(-self.size.width*0.5 + offset.x,
//                                                                       -self.size.width*0.5 + offset.y,
//                                                                       self.size.width,
//                                                                       self.size.width),
//                                                            nil);
//        [debugShapeNodes addObject:debugShapeNode];
//#endif
//    }
//    else if(shape == 3)//CHAIN
//    {
//        CGPoint offset = CGPointMake(0, 0);
//        CGRect rect = CGRectMake(-self.size.width*0.5 + offset.x,
//                                 -self.size.width*0.5 + offset.y,
//                                 self.size.width,
//                                 self.size.width);
//        
//        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:rect];
//        
//        
//#ifdef LH_DEBUG
//        SKShapeNode* debugShapeNode = [SKShapeNode node];
//        debugShapeNode.path = CGPathCreateWithRect(rect,
//                                                   nil);
//        [debugShapeNodes addObject:debugShapeNode];
//#endif
//    }
//    else if(shape == 4)//OVAL
//    {
//        fixturesInfo = [dict objectForKey:@"ovalShape"];
//    }
//    
//    
//    if(fixturesInfo)
//    {
//        NSMutableArray* fixBodies = [NSMutableArray array];
//        
//        for(NSArray* fixPoints in fixturesInfo)
//        {
//            int count = (int)[fixPoints count];
//            CGPoint points[count];
//            
//            int i = count - 1;
//            for(int j = 0; j< count; ++j)
//            {
//                NSString* pointStr = [fixPoints objectAtIndex:(NSUInteger)j];
//                CGPoint point = LHPointFromString(pointStr);
//                
//                //flip y for sprite kit coordinate system
//                point.y =  -point.y;
//                points[j] = point;
//                i = i-1;
//            }
//            
//            CGMutablePathRef fixPath = CGPathCreateMutable();
//            
//            bool first = true;
//            for(int k = 0; k < count; ++k)
//            {
//                CGPoint point = points[k];
//                if(first){
//                    CGPathMoveToPoint(fixPath, nil, point.x, point.y);
//                }
//                else{
//                    CGPathAddLineToPoint(fixPath, nil, point.x, point.y);
//                }
//                first = false;
//            }
//            
//            CGPathCloseSubpath(fixPath);
//            
//#ifdef LH_DEBUG
//            SKShapeNode* debugShapeNode = [SKShapeNode node];
//            debugShapeNode.path = fixPath;
//            [debugShapeNodes addObject:debugShapeNode];
//#endif
//            
//            [fixBodies addObject:[SKPhysicsBody bodyWithPolygonFromPath:fixPath]];
//            
//            CGPathRelease(fixPath);
//        }
//#if TARGET_OS_IPHONE
//        self.physicsBody = [SKPhysicsBody bodyWithBodies:fixBodies];
//#endif
//        
//    }
//    
//    
//    int type = [dict intForKey:@"type"];
//    if(type == 0)//static
//    {
//        [self.physicsBody setDynamic:NO];
//    }
//    else if(type == 1)//kinematic
//    {
//    }
//    else if(type == 2)//dynamic
//    {
//        [self.physicsBody setDynamic:YES];
//    }
//    
//    
//    NSDictionary* fixInfo = [dict objectForKey:@"genericFixture"];
//    if(fixInfo && self.physicsBody)
//    {
//        self.physicsBody.categoryBitMask = [fixInfo intForKey:@"category"];
//        self.physicsBody.collisionBitMask = [fixInfo intForKey:@"mask"];
//        
//        self.physicsBody.density = [fixInfo floatForKey:@"density"];
//        self.physicsBody.friction = [fixInfo floatForKey:@"friction"];
//        self.physicsBody.restitution = [fixInfo floatForKey:@"restitution"];
//        
//        self.physicsBody.allowsRotation = ![dict boolForKey:@"fixedRotation"];
//        self.physicsBody.usesPreciseCollisionDetection = [dict boolForKey:@"bullet"];
//        
//        if([dict intForKey:@"gravityScale"] == 0){
//            self.physicsBody.affectedByGravity = NO;
//        }
//    }
//    
//    
//#ifdef LH_DEBUG
//    for(SKShapeNode* debugShapeNode in debugShapeNodes)
//    {
//        
//        debugShapeNode.strokeColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.5];
//        if(shape != 3){//chain
//            debugShapeNode.fillColor = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.1];
//        }
//        debugShapeNode.lineWidth = 0.1;
//        if(self.physicsBody.isDynamic){
//            debugShapeNode.strokeColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.5];
//            debugShapeNode.fillColor = [SKColor colorWithRed:1 green:0 blue:0 alpha:0.1];
//        }
//        [self addChild:debugShapeNode];
//    }
//#endif
//    
//}

-(CGSize)size{
    return _size;
}

#pragma mark LHNodeProtocol Required

-(NSString*)uuid{
    return _uuid;
}

-(NSArray*)tags{
    return _tags;
}

-(id<LHUserPropertyProtocol>)userProperty{
    return _userProperty;
}

-(CCNode*)childNodeWithUUID:(NSString*)uuid{
    return [LHScene childNodeWithUUID:uuid
                              forNode:self];
}

-(NSMutableArray*)childrenWithTags:(NSArray*)tagValues containsAny:(BOOL)any{
    return [LHScene childrenWithTags:tagValues containsAny:any forNode:self];
}


-(NSMutableArray*)childrenOfType:(Class)type{
    return [LHScene childrenOfType:type
                           forNode:self];
}

-(void)update:(NSTimeInterval)currentTime delta:(float)dt{
    
}

#pragma mark - LHNodeAnimationProtocol
-(void)setActiveAnimation:(LHAnimation*)anim{
    activeAnimation = anim;
}

@end
