//
//  LHScene.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHScene.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHSprite.h"
#import "LHBezier.h"
#import "LHShape.h"
#import "LHWater.h"
#import "LHNode.h"
#import "LHAsset.h"
#import "LHGravityArea.h"
#import "LHParallax.h"
#import "LHParallaxLayer.h"
#import "LHCamera.h"
#import "LHRopeJointNode.h"
//#import "LHWeldJointNode.h"
//#import "LHRevoluteJointNode.h"
#import "LHDistanceJointNode.h"
//#import "LHPrismaticJointNode.h"

#import "LHPhysicsNode.h"

@implementation LHScene
{
    LHPhysicsNode *__unsafe_unretained _physicsNode;
    
    
    NSMutableArray* lateLoadingNodes;//gets nullified after everything is loaded
    
    LHNodeProtocolImpl* _nodeProtocolImp;
    
    NSMutableDictionary* loadedTextures;
    NSMutableDictionary* loadedTextureAtlases;
    NSDictionary* tracedFixtures;
    
    NSArray* supportedDevices;

    CGSize  designResolutionSize;
    CGPoint designOffset;
    
    NSString* relativePath;
    
    CCNode* touchedNode;
    BOOL touchedNodeWasDynamic;
    
    NSMutableArray* debugJoints;//its only used when in debug mode;
    CGPoint ropeJointsCutStartPt;
    
    NSMutableArray* gravityNodes;
    
    NSMutableDictionary* _loadedAssetsInformations;
    
    NSTimeInterval _lastTime;
    
    CGRect gameWorldRect;
}


-(void)dealloc{
    _physicsNode = nil;
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(relativePath);
    LH_SAFE_RELEASE(gravityNodes);
    LH_SAFE_RELEASE(loadedTextures);
    LH_SAFE_RELEASE(loadedTextureAtlases);
    LH_SAFE_RELEASE(tracedFixtures);
    LH_SAFE_RELEASE(supportedDevices);
    LH_SAFE_RELEASE(_loadedAssetsInformations);
    
    LH_SUPER_DEALLOC();
}

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile]);
}

-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile
{
    NSString* path = [[NSBundle mainBundle] pathForResource:[levelPlistFile stringByDeletingPathExtension]
                                                     ofType:[levelPlistFile pathExtension]];
    
    if(!path)return nil;
    
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
    if(!dict)return nil;

    int aspect = [dict intForKey:@"aspect"];
    CGSize designResolution = [dict sizeForKey:@"designResolution"];

    NSArray* devsInfo = [dict objectForKey:@"devices"];
    NSMutableArray* devices = [NSMutableArray array];
    for(NSDictionary* devInf in devsInfo){
        LHDevice* dev = [LHDevice deviceWithDictionary:devInf];
        [devices addObject:dev];
    }

    #if TARGET_OS_IPHONE
    LHDevice* curDev = [LHUtils currentDeviceFromArray:devices];
    #else
    LHDevice* curDev = [LHUtils deviceFromArray:devices withSize:size];
    #endif

    CGPoint childrenOffset = CGPointZero;
    
    CGSize sceneSize = curDev.size;
    float ratio = curDev.ratio;
    sceneSize.width = sceneSize.width/ratio;
    sceneSize.height = sceneSize.height/ratio;
    
    aspect = 2;//HARD CODED UNTIL I FIGURE OUT HOW TO DO IT IN v3
    
    if(aspect == 0)//exact fit
    {
        sceneSize = designResolution;
    }
    else if(aspect == 1)//no borders
    {
        float scalex = sceneSize.width/designResolution.width;
        float scaley = sceneSize.height/designResolution.height;
        scalex = scaley = MAX(scalex, scaley);
        
        childrenOffset.x = (sceneSize.width/scalex - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height/scaley - designResolution.height)*0.5;
        sceneSize = CGSizeMake(sceneSize.width/scalex, sceneSize.height/scaley);
        
    }
    else if(aspect == 2)//show all
    {
        [[CCDirector sharedDirector] setDesignSize:designResolution];
        childrenOffset.x = (sceneSize.width - designResolution.width)*0.5;
        childrenOffset.y = (sceneSize.height - designResolution.height)*0.5;
    }

    if (self = [super init])
    {
        relativePath = [[NSString alloc] initWithString:[levelPlistFile stringByDeletingLastPathComponent]];
        
        designResolutionSize = designResolution;
        designOffset         = childrenOffset;
        [[CCDirector sharedDirector] setContentScaleFactor:ratio];
        
//        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        NSDictionary* tracedFixInfo = [dict objectForKey:@"tracedFixtures"];
        if(tracedFixInfo){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFixInfo];
        }

        supportedDevices = [[NSArray alloc] initWithArray:devices];
        
        LHPhysicsNode* pNode = [LHPhysicsNode node];
        pNode.contentSize = self.contentSize;
        [pNode setDebugDraw:YES];
        [super addChild:pNode];
        _physicsNode = pNode;


        if([dict boolForKey:@"useGlobalGravity"])
        {
            CGPoint gravityVector = [dict pointForKey:@"globalGravityDirection"];
            float gravityForce    = [dict floatForKey:@"globalGravityForce"];
            CGPoint gravity = CGPointMake(gravityVector.x*gravityForce,
                                          gravityVector.y*gravityForce);
#if LH_USE_BOX2D
            [self setGlobalGravity:gravity];
#else//chipmunk
            [self setGlobalGravity:CGPointMake(gravity.x, gravity.y*100)];
#endif //LH_USE_BOX2D
        }
        
        
        //load background color
        CCColor* backgroundClr = [dict colorForKey:@"backgroundColor"];
        glClearColor(backgroundClr.red, backgroundClr.green, backgroundClr.blue, 1.0f);

        
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        for(NSDictionary* childInfo in childrenInfo)
        {
            CCNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                        parent:_physicsNode];
            
            if(node){

            }
        }
        
        
        
        NSDictionary* phyBoundInfo = [dict objectForKey:@"physicsBoundaries"];
        if(phyBoundInfo)
        {
            CGSize scr = LH_SCREEN_RESOLUTION;

            NSString* rectInf = [phyBoundInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
            if(!rectInf){
                rectInf = [phyBoundInfo objectForKey:@"general"];
            }
            
            if(rectInf){
                CGRect bRect = LHRectFromString(rectInf);
                CGSize designSize = [self designResolutionSize];
                CGPoint offset = [self designOffset];
                CGRect skBRect = CGRectMake(bRect.origin.x*designSize.width + offset.x,
                                            self.contentSize.height - bRect.origin.y*designSize.height + offset.y,
                                            bRect.size.width*designSize.width ,
                                            -bRect.size.height*designSize.height);
                
                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMinY(skBRect))
                                                        to:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMinY(skBRect))
                                                  withName:@"LHPhysicsBottomBoundary"];
                }
                
                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMinY(skBRect))
                                                        to:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMaxY(skBRect))
                                                  withName:@"LHPhysicsRightBoundary"];

                }
                
                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMaxX(skBRect), CGRectGetMaxY(skBRect))
                                                        to:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMaxY(skBRect))
                                                  withName:@"LHPhysicsTopBoundary"];
                }

                {
                    [self createPhysicsBoundarySectionFrom:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMaxY(skBRect))
                                                        to:CGPointMake(CGRectGetMinX(skBRect), CGRectGetMinY(skBRect))
                                                  withName:@"LHPhysicsLeftBoundary"];
                }
            }
        }

        NSDictionary* gameWorldInfo = [dict objectForKey:@"gameWorld"];
        if(gameWorldInfo)
        {
#if TARGET_OS_IPHONE
            CGSize scr = LH_SCREEN_RESOLUTION;
#else
            CGSize scr = self.size;
#endif

            NSString* rectInf = [gameWorldInfo objectForKey:[NSString stringWithFormat:@"%dx%d", (int)scr.width, (int)scr.height]];
            if(!rectInf){
                rectInf = [gameWorldInfo objectForKey:@"general"];
            }
            
            if(rectInf){
                CGRect bRect = LHRectFromString(rectInf);
                CGSize designSize = [self designResolutionSize];
                CGPoint offset = [self designOffset];

                gameWorldRect = CGRectMake(bRect.origin.x*designSize.width+ offset.x,
                                           (1.0f - bRect.origin.y)*designSize.height + offset.y,
                                           bRect.size.width*designSize.width ,
                                           -(bRect.size.height)*designSize.height);
                gameWorldRect.origin.y -= sceneSize.height;
            }
        }
        
        [self performLateLoading];
        
        [self setUserInteractionEnabled:YES];

    }
    return self;
}

-(LHPhysicsNode*)physicsNode{
    return _physicsNode;
}

-(void)createPhysicsBoundarySectionFrom:(CGPoint)from
                                     to:(CGPoint)to
                               withName:(NSString*)sectionName
{
    CCDrawNode* drawNode = [CCDrawNode node];
    [self addChild:drawNode];
    [drawNode setZOrder:100];
    [drawNode setName:sectionName];
    
#ifndef NDEBUG
    [drawNode drawSegmentFrom:from
                           to:to
                       radius:1
                        color:[CCColor redColor]];
#endif
    
#if LH_USE_BOX2D

    float PTM_RATIO = [self ptm];
    
    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    b2Body* physicsBoundariesBody = [self box2dWorld]->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2EdgeShape groundBox;
    
    // top
    groundBox.Set(b2Vec2(from.x/PTM_RATIO,
                         from.y/PTM_RATIO),
                  b2Vec2(to.x/PTM_RATIO,
                         to.y/PTM_RATIO));
    physicsBoundariesBody->CreateFixture(&groundBox,0);

    
#else //chipmunk
    CCPhysicsBody* boundariesBody = [CCPhysicsBody bodyWithPillFrom:from to:to cornerRadius:0];
    [boundariesBody setType:CCPhysicsBodyTypeStatic];
    [drawNode setPhysicsBody:boundariesBody];
#endif
    
}

-(void)performLateLoading{
    if(!lateLoadingNodes)return;
    
    NSMutableArray* lateLoadingToRemove = [NSMutableArray array];
    for(CCNode* node in lateLoadingNodes){
        if([node respondsToSelector:@selector(lateLoading)]){
            if([(id<LHNodeProtocol>)node lateLoading]){
                [lateLoadingToRemove addObject:node];
            }
        }
    }
    [lateLoadingNodes removeObjectsInArray:lateLoadingToRemove];
    if([lateLoadingNodes count] == 0){
        LH_SAFE_RELEASE(lateLoadingNodes);
    }
}

//-(SKTextureAtlas*)textureAtlasWithImagePath:(NSString*)atlasPath
//{
//    if(!loadedTextureAtlases){
//        loadedTextureAtlases = [[NSMutableDictionary alloc] init];
//    }
// 
//    SKTextureAtlas* textureAtlas = nil;
//    if(atlasPath){
//        textureAtlas = [loadedTextureAtlases objectForKey:atlasPath];
//        if(!textureAtlas){
//            textureAtlas = [SKTextureAtlas atlasNamed:atlasPath];
//            if(textureAtlas){
//                [loadedTextureAtlases setObject:textureAtlas forKey:atlasPath];
//            }
//        }
//    }
//    
//    return textureAtlas;
//}

-(CCTexture*)textureWithImagePath:(NSString*)imagePath
{
    if(!loadedTextures){
        loadedTextures = [[NSMutableDictionary alloc] init];
    }
    
    CCTexture* texture = nil;
    if(imagePath){
        texture = [loadedTextures objectForKey:imagePath];
        if(!texture){
            texture = [CCTexture textureWithFile:imagePath];
            if(texture){
                [loadedTextures setObject:texture forKey:imagePath];
            }
        }
    }
    
    return texture;
}

-(CGRect)gameWorldRect{
    return gameWorldRect;
}

-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName{
    if(!_loadedAssetsInformations){
        _loadedAssetsInformations = [[NSMutableDictionary alloc] init];
    }
    NSDictionary* info = [_loadedAssetsInformations objectForKey:assetFileName];
    if(!info){
        NSString* path = [[NSBundle mainBundle] pathForResource:assetFileName
                                                         ofType:@"plist"
                                                    inDirectory:[self relativePath]];
        if(path){
            info = [NSDictionary dictionaryWithContentsOfFile:path];
            if(info){
                [_loadedAssetsInformations setObject:info forKey:assetFileName];
            }
        }
    }
    return info;
}

//#if TARGET_OS_IPHONE
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//    CGVector grv = self.physicsWorld.gravity;
//    
//    [self.physicsWorld setGravity:CGVectorMake(grv.dx,
//                                              -grv.dy)];
//    
//    return;
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        ropeJointsCutStartPt = location;
//        
//        NSArray* foundNodes = [self nodesAtPoint:location];
//        for(SKNode* foundNode in foundNodes)
//        {
//            if(foundNode.physicsBody){
//                touchedNode = foundNode;
//                touchedNodeWasDynamic = touchedNode.physicsBody.affectedByGravity;
//                [touchedNode.physicsBody setAffectedByGravity:NO];                
//                return;
//            }
//        }
//    }
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//
//        if(touchedNode && touchedNode.physicsBody){
//            [touchedNode setPosition:location];
//        }
//    }
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        for(LHRopeJointNode* rope in ropeJoints){
//            if([rope canBeCut]){
//                [rope cutWithLineFromPointA:ropeJointsCutStartPt
//                                   toPointB:location];
//            }
//        }
//    }
//    
//    
//
//    if(touchedNode){
//    [touchedNode.physicsBody setAffectedByGravity:touchedNodeWasDynamic];
//    touchedNode = nil;
//    }
//}
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    if(touchedNode){
//    touchedNode.physicsBody.affectedByGravity = touchedNodeWasDynamic;
//    touchedNode = nil;
//    }
//}
//#else
//-(void)mouseDown:(NSEvent *)theEvent{
//    
//    CGPoint location = [theEvent locationInNode:self];
//    
//    ropeJointsCutStartPt = location;
//    NSArray* foundNodes = [self nodesAtPoint:location];
//    for(SKNode* foundNode in foundNodes)
//    {
//        if(foundNode.physicsBody){
//            touchedNode = foundNode;
//            touchedNodeWasDynamic = touchedNode.physicsBody.affectedByGravity;
//            [touchedNode.physicsBody setAffectedByGravity:NO];
//            break;
//        }
//    }
//    
//    BOOL                dragActive = YES;
//    NSEvent*            event = NULL;
//    NSWindow            *targetWindow = [[NSApplication sharedApplication] mainWindow];
//    
//    while (dragActive) {
//        event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
//                                          untilDate:[NSDate distantFuture]
//                                             inMode:NSEventTrackingRunLoopMode
//                                            dequeue:YES];
//        if(!event){
//            continue;
//        }
//        switch ([event type])
//        {
//            case NSLeftMouseDragged:
//            {
//                CGPoint curLocation = [event locationInNode:self];
//                
//                if(touchedNode && touchedNode.physicsBody){
//                    [touchedNode setPosition:curLocation];
//                }
//            }
//                break;
//                
//                
//            case NSLeftMouseUp:
//                dragActive = NO;
//                
//                CGPoint curLocation = [event locationInNode:self];
//                for(LHRopeJointNode* rope in ropeJoints){
//                    if([rope canBeCut]){
//                        [rope cutWithLineFromPointA:ropeJointsCutStartPt
//                                           toPointB:curLocation];
//                    }
//                }
//                
//                if(touchedNode){
//                    [touchedNode.physicsBody setAffectedByGravity:touchedNodeWasDynamic];
//                    touchedNode = nil;
//                }
//                
//                break;
//                
//            default:
//                break;
//        }
//    }
//}
//#endif

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - TOUCH SUPPORT
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{

    //without this touch began is not called
    CCDirector* dir = [CCDirector sharedDirector];
    
    CGPoint touchLocation = [touch previousLocationInView: [touch view]];
	touchLocation = [dir convertToGL: touchLocation];
    
    ropeJointsCutStartPt = touchLocation;
    
    
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
//    NSLog(@"TOUCH MOVED");
//    
////    NSLog(@"SELF CHILDREN %@", [self children]);
//    
//    CGPoint touchLoc = [touch locationInNode:self];
//    
//    CCDirector* dir = [CCDirector sharedDirector];
//    
//    CGPoint touchLocation = [touch previousLocationInView: [touch view]];
//	touchLocation = [dir convertToGL: touchLocation];
//    CGPoint previousLoc = [self convertToNodeSpace:touchLocation];
//    
//
//    CGPoint delta = CGPointMake(touchLoc.x - previousLoc.x,
//                                touchLoc.y - previousLoc.y);
//    
//    CGPoint curPos = [self position];
//    
//    [self setPosition:CGPointMake(curPos.x + delta.x, curPos.y + delta.y)];
//    
//    NSLog(@"NEW POS %f %f", self.position.x, self.position.y);
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCDirector* dir = [CCDirector sharedDirector];
    
    CGPoint touchLocation = [touch previousLocationInView: [touch view]];
	touchLocation = [dir convertToGL: touchLocation];

    for(LHRopeJointNode* rope in [self childrenOfType:[LHRopeJointNode class]]){
        if([rope canBeCut]){
            [rope cutWithLineFromPointA:ropeJointsCutStartPt
                               toPointB:touchLocation];
        }
    }
}


#pragma mark - BOX2D INTEGRATION

#if LH_USE_BOX2D
-(b2World*)box2dWorld{
    return [_physicsNode box2dWorld];
}
-(float)ptm{
    return 32.0f;
}
-(b2Vec2)metersFromPoint:(CGPoint)point{
    return b2Vec2(point.x/[self ptm], point.y/[self ptm]);
}
-(CGPoint)pointFromMeters:(b2Vec2)vec{
    return CGPointMake(vec.x*[self ptm], vec.y*[self ptm]);
}
-(float)metersFromValue:(float)val{
    return val/[self ptm];
}
-(float)valueFromMeters:(float)meter{
    return meter*[self ptm];
}
#endif //LH_USE_BOX2D

-(void)setGlobalGravity:(CGPoint)gravity{
    [_physicsNode setGravity:gravity];
}

@end



#pragma mark - PRIVATES

@implementation LHScene (LH_SCENE_NODES_PRIVATE_UTILS)

+(id)createLHNodeWithDictionary:(NSDictionary*)childInfo
                         parent:(CCNode*)prnt
{
    
    NSString* nodeType = [childInfo objectForKey:@"nodeType"];
    
    LHScene* scene = nil;
    if([prnt isKindOfClass:[LHScene class]]){
        scene = (LHScene*)prnt;
    }
    else if([[prnt scene] isKindOfClass:[LHScene class]]){
        scene = (LHScene*)[prnt scene];
    }

    
    if([nodeType isEqualToString:@"LHSprite"])
    {
        LHSprite* spr = [LHSprite spriteNodeWithDictionary:childInfo
                                                    parent:prnt];
        return spr;
    }
    else if([nodeType isEqualToString:@"LHNode"])
    {
        LHNode* nd = [LHNode nodeWithDictionary:childInfo
                                         parent:prnt];
        return nd;
    }
    else if([nodeType isEqualToString:@"LHBezier"])
    {
        LHBezier* bez = [LHBezier bezierNodeWithDictionary:childInfo
                                                    parent:prnt];
        return bez;
    }
    else if([nodeType isEqualToString:@"LHTexturedShape"])
    {
        LHShape* sp = [LHShape shapeNodeWithDictionary:childInfo
                                                parent:prnt];
        return sp;
    }
    else if([nodeType isEqualToString:@"LHWaves"])
    {
        LHWater* wt = [LHWater waterNodeWithDictionary:childInfo
                                                parent:prnt];
        return wt;
    }
    else if([nodeType isEqualToString:@"LHAreaGravity"])
    {
        LHGravityArea* gv = [LHGravityArea gravityAreaWithDictionary:childInfo
                                                              parent:prnt];
        return gv;
    }
    else if([nodeType isEqualToString:@"LHParallax"])
    {
        LHParallax* pr = [LHParallax parallaxWithDictionary:childInfo
                                                     parent:prnt];
        return pr;
    }
    else if([nodeType isEqualToString:@"LHParallaxLayer"])
    {
        LHParallaxLayer* lh = [LHParallaxLayer parallaxLayerWithDictionary:childInfo
                                                                    parent:prnt];
        return lh;
    }
    else if([nodeType isEqualToString:@"LHAsset"])
    {
        LHAsset* as = [LHAsset assetWithDictionary:childInfo
                                            parent:prnt];
        return as;
    }
    else if([nodeType isEqualToString:@"LHCamera"])
    {
        if(scene)
        {
            LHCamera* cm = [LHCamera cameraWithDictionary:childInfo
                                                    parent:prnt];
            return cm;
        }
    }
    else if([nodeType isEqualToString:@"LHRopeJoint"])
    {
        if(scene)
        {
            LHRopeJointNode* jt = [LHRopeJointNode ropeJointNodeWithDictionary:childInfo
                                                                        parent:prnt];
            [scene addLateLoadingNode:jt];
        }
    }
//    else if([nodeType isEqualToString:@"LHWeldJoint"])
//    {
//        LHWeldJointNode* jt = [LHWeldJointNode weldJointNodeWithDictionary:childInfo
//                                                                    parent:prnt];
//        [scene addDebugJointNode:jt];
//        [scene addLateLoadingNode:jt];
//    }
//    else if([nodeType isEqualToString:@"LHRevoluteJoint"]){
//        
//        LHRevoluteJointNode* jt = [LHRevoluteJointNode revoluteJointNodeWithDictionary:childInfo
//                                                                                parent:prnt];
//
//        [scene addDebugJointNode:jt];
//        [scene addLateLoadingNode:jt];
//    }
    else if([nodeType isEqualToString:@"LHDistanceJoint"]){
        
        LHDistanceJointNode* jt = [LHDistanceJointNode distanceJointNodeWithDictionary:childInfo
                                                                                parent:prnt];
        [scene addLateLoadingNode:jt];

    }
//    else if([nodeType isEqualToString:@"LHPrismaticJoint"]){
//        
//        LHPrismaticJointNode* jt = [LHPrismaticJointNode prismaticJointNodeWithDictionary:childInfo
//                                                                                   parent:prnt];
//        [scene addDebugJointNode:jt];
//        [scene addLateLoadingNode:jt];
//    }


    else{
        NSLog(@"UNKNOWN NODE TYPE %@", nodeType);
    }
    
    return nil;
}

-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

-(void)addLateLoadingNode:(CCNode*)node{
    if(!lateLoadingNodes) {
        lateLoadingNodes = [[NSMutableArray alloc] init];
    }
    [lateLoadingNodes addObject:node];
}

-(NSString*)relativePath{
    return relativePath;
}

-(float)currentDeviceRatio{
    
#if TARGET_OS_IPHONE
    CGSize scrSize = LH_SCREEN_RESOLUTION;
#else
    CGSize scrSize = self.size;
#endif
    
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            return [dev ratio];
        }
    }
    return 1.0f;
}

-(CGSize)designResolutionSize{
    return designResolutionSize;
}
-(CGPoint)designOffset{
    return designOffset;
}

-(NSString*)currentDeviceSuffix:(BOOL)keep2x{
    
#if TARGET_OS_IPHONE
    CGSize scrSize = LH_SCREEN_RESOLUTION;
#else
    CGSize scrSize = self.size;
#endif
    
    for(LHDevice* dev in supportedDevices){
        CGSize devSize = [dev size];
        if(CGSizeEqualToSize(scrSize, devSize)){
            NSString* suffix = [dev suffix];
            if(!keep2x){
                suffix = [suffix stringByReplacingOccurrencesOfString:@"@2x"
                                                           withString:@""];
            }
            return suffix;
        }
    }
    return @"";
}
@end

