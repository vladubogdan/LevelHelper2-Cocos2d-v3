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
#import "LHRevoluteJointNode.h"
#import "LHDistanceJointNode.h"
#import "LHPulleyJointNode.h"
#import "LHWeldJointNode.h"
#import "LHPrismaticJointNode.h"
#import "LHWheelJointNode.h"
#import "LHGearJointNode.h"

#import "LHBackUINode.h"
#import "LHGameWorldNode.h"
#import "LHUINode.h"
#import "LHBox2dCollisionHandling.h"

@implementation LHScene
{
    __weak LHBackUINode*       _backUiNode;
    __weak LHGameWorldNode*    _gameWorldNode;
    __weak LHUINode*           _uiNode;
    
    __weak id<LHAnimationNotificationsProtocol> _animationsDelegate;

#if LH_USE_BOX2D
    __weak id<LHCollisionHandlingProtocol> _collisionsDelegate;
    LHBox2dCollisionHandling* _box2dCollision;
#endif
    
    NSMutableArray* lateLoadingNodes;//gets nullified after everything is loaded
    
    LHNodeProtocolImpl* _nodeProtocolImp;
    
    NSMutableDictionary* loadedTextures;
    NSDictionary* tracedFixtures;
    
    NSArray* supportedDevices;

    CGSize  designResolutionSize;
    CGSize  currentDeviceSize;
    CGPoint designOffset;
    
    NSString* relativePath;
    
    NSMutableDictionary* _loadedAssetsInformations;
    
    NSTimeInterval _lastTime;
    
    CGRect gameWorldRect;

    CGPoint touchBeganLocation;
}


-(void)dealloc{
    
    _animationsDelegate = nil;
#if LH_USE_BOX2D
    _collisionsDelegate = nil;
    LH_SAFE_RELEASE(_box2dCollision);
#endif
    
    [self removeAllChildren];

    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(relativePath);
    LH_SAFE_RELEASE(loadedTextures);
    LH_SAFE_RELEASE(tracedFixtures);
    LH_SAFE_RELEASE(supportedDevices);
    LH_SAFE_RELEASE(_loadedAssetsInformations);
    
    _backUiNode = nil;
    _gameWorldNode = nil;
    _uiNode = nil;

    LH_SUPER_DEALLOC();    
}

+(instancetype)sceneWithContentOfFile:(NSString*)levelPlistFile{
    return LH_AUTORELEASED([[self alloc] initWithContentOfFile:levelPlistFile]);
}

-(instancetype)initWithContentOfFile:(NSString*)levelPlistFile
{
    NSString* path = [[NSBundle mainBundle] pathForResource:[levelPlistFile stringByDeletingPathExtension]
                                                     ofType:[levelPlistFile pathExtension]];
    
    if(!path){
        NSLog(@"ERROR: Could not find level file %@. Make sure the name is correct and the file is located inside a folder added in Xcode as Reference (blue icon).", levelPlistFile);
    }
    NSAssert(path, @" ");
    if(!path)return nil;
    
    
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];

    
    if(!dict){
        NSLog(@"ERROR: Could not load level file %@. The file located at %@ does not appear to be valid.", levelPlistFile, path);
    }
    NSAssert(dict, @" ");
    if(!dict)return nil;


    
    int aspect = [dict intForKey:@"aspect"];
    CGSize designResolution = [dict sizeForKey:@"designResolution"];

    NSArray* devsInfo = [dict objectForKey:@"devices"];
    NSMutableArray* devices = [NSMutableArray array];
    for(NSDictionary* devInf in devsInfo){
        LHDevice* dev = [LHDevice deviceWithDictionary:devInf];
        [devices addObject:dev];
    }

    LHDevice* curDev = [LHUtils currentDeviceFromArray:devices];

    
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
        currentDeviceSize    = curDev.size;
        
        [[CCDirector sharedDirector] setContentScaleFactor:ratio];
#ifdef __CC_PLATFORM_IOS
        [[CCFileUtils sharedFileUtils] setiPhoneContentScaleFactor:curDev.ratio];
#endif
        
        [self setName:relativePath];

        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        

        self.contentSize= CGSizeMake(curDev.size.width/curDev.ratio, curDev.size.height/curDev.ratio);
        
        self.position   = CGPointZero;
        
        
        NSDictionary* tracedFixInfo = [dict objectForKey:@"tracedFixtures"];
        if(tracedFixInfo){
            tracedFixtures = [[NSDictionary alloc] initWithDictionary:tracedFixInfo];
        }

        supportedDevices = [[NSArray alloc] initWithArray:devices];
        
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        [self loadGlobalGravityFromDictionary:dict];
        [self loadBackgroundColorFromDictionary:dict];
        [self loadPhysicsBoundariesFromDictionary:dict];
        [self loadGameWorldInfoFromDictionary:dict];
        
        
        [self performLateLoading];
        
        [self setUserInteractionEnabled:YES];
        

#if LH_USE_BOX2D
        _box2dCollision = [[LHBox2dCollisionHandling alloc] initWithScene:self];
#else//cocos2d
        
#endif
        
        //call this to update the views when using camera/parallax
        [self visit];
        
    }
    return self;
}

-(void)onEnter{
    [[self gameWorldNode] setPaused:NO];
    [super onEnter];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - LOADING
////////////////////////////////////////////////////////////////////////////////

-(void)loadPhysicsBoundariesFromDictionary:(NSDictionary*)dict
{
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
                                        designSize.height - bRect.origin.y*designSize.height + offset.y,
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
}
-(void)createPhysicsBoundarySectionFrom:(CGPoint)from
                                     to:(CGPoint)to
                               withName:(NSString*)sectionName
{
    CCDrawNode* drawNode = [CCDrawNode node];
    [[self gameWorldNode] addChild:drawNode];
    [drawNode setZOrder:100];
    [drawNode setName:sectionName];
    
#if LH_DEBUG
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
    physicsBoundariesBody->SetUserData(LH_VOID_BRIDGE_CAST(drawNode));
    
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

-(void)loadBackgroundColorFromDictionary:(NSDictionary*)dict
{
    //load background color
    CCColor* backgroundClr = [dict colorForKey:@"backgroundColor"];
    glClearColor(backgroundClr.red, backgroundClr.green, backgroundClr.blue, 1.0f);
}

-(void)loadGameWorldInfoFromDictionary:(NSDictionary*)dict
{
    NSDictionary* gameWorldInfo = [dict objectForKey:@"gameWorld"];
    if(gameWorldInfo)
    {
        CGSize scr = LH_SCREEN_RESOLUTION;
        
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
            
            
            CCDrawNode* drawNode = [CCDrawNode node];
            [[self gameWorldNode] addChild:drawNode];
            [drawNode setZOrder:100];

#if LH_DEBUG
            
            [drawNode drawSegmentFrom:CGPointMake(gameWorldRect.origin.x, gameWorldRect.origin.y)
                                   to:CGPointMake(gameWorldRect.origin.x + gameWorldRect.size.width, gameWorldRect.origin.y)
                               radius:1
                                color:[CCColor magentaColor]];

            [drawNode drawSegmentFrom:CGPointMake(gameWorldRect.origin.x, gameWorldRect.origin.y)
                                   to:CGPointMake(gameWorldRect.origin.x, gameWorldRect.origin.y + gameWorldRect.size.height)
                               radius:1
                                color:[CCColor magentaColor]];

            [drawNode drawSegmentFrom:CGPointMake(gameWorldRect.origin.x, gameWorldRect.origin.y + gameWorldRect.size.height)
                                   to:CGPointMake(gameWorldRect.origin.x + gameWorldRect.size.width, gameWorldRect.origin.y + gameWorldRect.size.height)
                               radius:1
                                color:[CCColor magentaColor]];

            
            [drawNode drawSegmentFrom:CGPointMake(gameWorldRect.origin.x + gameWorldRect.size.width, gameWorldRect.origin.y)
                                   to:CGPointMake(gameWorldRect.origin.x + gameWorldRect.size.width, gameWorldRect.origin.y + gameWorldRect.size.height)
                               radius:1
                                color:[CCColor magentaColor]];
#endif

            
        }
    }
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

////////////////////////////////////////////////////////////////////////////////
#pragma mark - PROPERTIES
////////////////////////////////////////////////////////////////////////////////

-(LHGameWorldNode*)physicsNode{
    return [self gameWorldNode];
}
-(LHBackUINode*)backUiNode{
    if(!_backUiNode){
        for(CCNode* n in [self children]){
            if([n isKindOfClass:[LHBackUINode class]]){
                _backUiNode = (LHBackUINode*)n;
                break;
            }
        }
    }
    return _backUiNode;
}
-(LHGameWorldNode*)gameWorldNode{
    if(!_gameWorldNode){
        for(CCNode* n in [self children]){
            if([n isKindOfClass:[LHGameWorldNode class]]){
                _gameWorldNode = (LHGameWorldNode*)n;
                break;
            }
        }
    }
    return _gameWorldNode;
}

-(LHUINode*)uiNode{
    if(!_uiNode){
        for(CCNode* n in [self children]){
            if([n isKindOfClass:[LHUINode class]]){
                _uiNode = (LHUINode*)n;
                break;
            }
        }
    }
    return _uiNode;
}

#pragma mark- NODES SUBCLASSING
-(Class)createNodeObjectForSubclassWithName:(NSString*)subclassTypeName superTypeName:(NSString*)lhTypeName{
    //nothing to do - users should overwrite this method
    return nil;
}

#pragma mark- ANIMATION HANDLING
-(void)setAnimationNotificationsDelegate:(id<LHAnimationNotificationsProtocol>)del{
    _animationsDelegate = del;
}
-(void)didFinishedPlayingAnimation:(LHAnimation*)anim{
    //nothing to do - users should overwrite this method
    if(_animationsDelegate){
        [_animationsDelegate didFinishedPlayingAnimation:anim];
    }
}
-(void)didFinishedRepetitionOnAnimation:(LHAnimation*)anim{
    //nothing to do - users should overwrite this method
    if(_animationsDelegate){
        [_animationsDelegate didFinishedRepetitionOnAnimation:anim];
    }
}

-(void)didCutRopeJoint:(LHRopeJointNode*)joint{
    //nothing to do - users should overwrite this method
}

#pragma mark- COLLISION HANDLING
#if LH_USE_BOX2D

-(void)setCollisionHandlingDelegate:(id<LHCollisionHandlingProtocol>)del{
    _collisionsDelegate = del;
}

-(BOOL)shouldDisableContactBetweenNodeA:(CCNode*)a
                               andNodeB:(CCNode*)b{
    return NO;
}

-(void)didBeginContactBetweenNodeA:(CCNode*)a
                          andNodeB:(CCNode*)b
                        atLocation:(CGPoint)scenePt
                       withImpulse:(float)impulse
{
    //nothing to do - users should overwrite this method
}

-(void)didEndContactBetweenNodeA:(CCNode*)a
                        andNodeB:(CCNode*)b
{
    //nothing to do - users should overwrite this method
}

#else
#endif



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

-(NSString*)relativePath{
    return relativePath;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
#pragma mark - BOX2D INTEGRATION
////////////////////////////////////////////////////////////////////////////////

#if LH_USE_BOX2D
-(b2World*)box2dWorld{
    return [[self gameWorldNode] box2dWorld];
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

-(void)setBox2dFixedTimeStep:(float)val{
    [[self gameWorldNode] setBox2dFixedTimeStep:val];
}
-(void)setBox2dMinimumTimeStep:(float)val{
    [[self gameWorldNode] setBox2dMinimumTimeStep:val];
}
-(void)setBox2dVelocityIterations:(int)val{
    [[self gameWorldNode] setBox2dVelocityIterations:val];
}
-(void)setBox2dPositionIterations:(int)val{
    [[self gameWorldNode] setBox2dPositionIterations:val];
}
-(void)setBox2dMaxSteps:(int)val{
    [[self gameWorldNode] setBox2dMaxSteps:val];
}


#endif //LH_USE_BOX2D

-(void)loadGlobalGravityFromDictionary:(NSDictionary*)dict
{
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
}

-(CGPoint)globalGravity{
    return [[self gameWorldNode] gravity];
}
-(void)setGlobalGravity:(CGPoint)gravity{
    [[self gameWorldNode] setGravity:gravity];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - TOUCH SUPPORT
////////////////////////////////////////////////////////////////////////////////

#ifdef __CC_PLATFORM_IOS
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    touchBeganLocation = [touch locationInNode:self];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    for(LHRopeJointNode* rope in [self childrenOfType:[LHRopeJointNode class]]){
        if([rope canBeCut]){
            [rope cutWithLineFromPointA:touchBeganLocation
                               toPointB:touchLocation];
        }
    }
}
#else
-(void)mouseDown:(NSEvent *)theEvent{
    touchBeganLocation = [theEvent locationInNode:self];
}
-(void)mouseUp:(NSEvent *)theEvent{
    CGPoint touchLocation = [theEvent locationInNode:self];
    for(LHRopeJointNode* rope in [self childrenOfType:[LHRopeJointNode class]]){
        if([rope canBeCut]){
            [rope cutWithLineFromPointA:touchBeganLocation
                               toPointB:touchLocation];
        }
    }
}
#endif


////////////////////////////////////////////////////////////////////////////////
#pragma mark - PRIVATES
////////////////////////////////////////////////////////////////////////////////

-(NSArray*)tracedFixturesWithUUID:(NSString*)uuid{
    return [tracedFixtures objectForKey:uuid];
}

-(void)addLateLoadingNode:(CCNode*)node{
    if(!lateLoadingNodes) {
        lateLoadingNodes = [[NSMutableArray alloc] init];
    }
    [lateLoadingNodes addObject:node];
}

-(float)currentDeviceRatio{
    
    CGSize scrSize = LH_SCREEN_RESOLUTION;
    
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
-(CGSize)currentDeviceSize{
    return currentDeviceSize;
}
-(CGPoint)designOffset{
    return designOffset;
}

-(NSString*)currentDeviceSuffix:(BOOL)keep2x{
    
    CGSize scrSize = LH_SCREEN_RESOLUTION;
    
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

-(NSDictionary*)assetInfoForFile:(NSString*)assetFileName{
    if(!_loadedAssetsInformations){
        _loadedAssetsInformations = [[NSMutableDictionary alloc] init];
    }
    NSDictionary* info = [_loadedAssetsInformations objectForKey:assetFileName];
    if(!info){
        NSString* path = [[NSBundle mainBundle] pathForResource:[assetFileName lastPathComponent]
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

@end

