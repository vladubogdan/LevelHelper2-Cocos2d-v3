//
//  LHWater.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHWater.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHGameWorldNode.h"
#import "LHNodePhysicsProtocol.h"
#import "LHDrawNode.h"

#if LH_USE_BOX2D
#include "LHb2BuoyancyController.h"
#endif


@interface LHWave : NSObject
{
    float wavelength, amplitude, startAmplitude, offset, increment, velocity;
    float left, right, halfWidth, middle;
    int currentStep, totalSteps;
    
    float(^decayBlock)(float, float, float, float);
    float(^clampBlock)(float, float, float, float);
    float(^waveBlock)(float);
}

@property float wavelength, amplitude, startAmplitude, offset, increment, velocity;
@property float left, right, halfWidth, middle;
@property int currentStep, totalSteps;

-(void)setDecayBlock:(float(^)(float t, float b, float c, float d))decayBlock;
-(void)setClampBlock:(float(^)(float t, float b, float c, float d))clampBlock;
-(void)setWaveBlock:(float(^)(float val))waveBlock;

- (float(^)(float, float, float, float))decayBlock;
- (float(^)(float, float, float, float))clampBlock;
- (float(^)(float))waveBlock;

+(float) linearEase:(float)t b:(float)b c:(float)c d:(float)d;
+(float) sinEaseIn:(float)t b:(float)b c:(float)c d:(float)d;
+(float)sinEaseOut:(float)t b:(float)b c:(float)c d:(float)d;
+(float)sinEaseInOut:(float)t b:(float)b c:(float)c d:(float)d;
-(float)valueAt:(float)positionX;
-(void)step;
@end
@implementation LHWave
@synthesize wavelength, amplitude, startAmplitude, currentStep, totalSteps,
offset, increment, velocity, left, right, halfWidth, middle;
-(id)init{
    if(self = [super init]){
        waveBlock = nil;
        wavelength= 0;
        amplitude = 0;
        startAmplitude = 0;
        currentStep = 0;
        totalSteps = 0;
        offset = 0;
        increment = 0;
        decayBlock = nil;
        clampBlock = nil;
        velocity = 0;
        left = 0;
        right = 1000;
        halfWidth = 0;
        middle = 0;
    }
    return self;
}
-(void)setDecayBlock:(float(^)(float t, float b, float c, float d))_decayBlock{
    decayBlock = _decayBlock;
}
-(void)setClampBlock:(float(^)(float t, float b, float c, float d))_clampBlock{
    clampBlock = _clampBlock;
}
-(void)setWaveBlock:(float(^)(float val))_waveBlock{
    waveBlock = _waveBlock;
}
- (float(^)(float, float, float, float))decayBlock{
    return decayBlock;
}
- (float(^)(float, float, float, float))clampBlock{
    return clampBlock;
}
- (float(^)(float))waveBlock{
    return waveBlock;
}
+(float) linearEase:(float)t b:(float)b c:(float)c d:(float)d{
    return b + c * t  / d;
}
+(float) sinEaseIn:(float)t b:(float)b c:(float)c d:(float)d{
    return -c * cos(t/d * (M_PI / 2)) + c + b;
}
+(float)sinEaseOut:(float)t b:(float)b c:(float)c d:(float)d{
    return c * sin(t / d * (M_PI / 2)) + b;
}
+(float)sinEaseInOut:(float)t b:(float)b c:(float)c d:(float)d{
    return -c / 2 * (cos(M_PI * t / d) - 1) + b;
}
-(float)valueAt:(float)position {
    if(position < left || position > right) {
        return 0.0f;
    }
    float v = (waveBlock != nil ? waveBlock((position - left + offset) / wavelength) : 1.0f) * amplitude;
    if(clampBlock != nil) {
        v = clampBlock(abs(position - middle), v, -v, halfWidth);
    }
    return v;
}
-(void) step{
    if(decayBlock != nil) {
        amplitude = decayBlock(currentStep, startAmplitude, -startAmplitude, totalSteps);
        currentStep++;
    }
    offset += increment;
    left += velocity;
    right += velocity;
    halfWidth = (right - left) / 2;
    middle = left + halfWidth;
}
@end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//! a Point with a vertex point and a color 4F
typedef struct _LH_V3F_C4F
{
	//! vertices (3F)
	ccVertex3F		vertices;
	//! colors (4F)
	ccColor4F		colors;
} _LH_V3F_C4F;

//! A Triangle of _LH_V3F_C4F
typedef struct _LH_V2F_C4B_Triangle
{
	//! Point A
	_LH_V3F_C4F a;
	//! Point B
	_LH_V3F_C4F b;
	//! Point B
	_LH_V3F_C4F c;
} _LH_V2F_C4B_Triangle;



@implementation LHWater
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    __weak LHDrawNode* _drawNode;
    
    float width, height;
    float numLines;
    NSMutableArray* waves;
    float lineWidth;

    float waterDensity;
    BOOL turbulence;
    float turbulenceL;
    float turbulenceH;
    float turbulenceV;
    float turbulenceVelocity;
    
    BOOL splashCollision;
    float splashHeight;
    float splashWidth;
    float splashTime;
    NSMutableDictionary* bodySplashes;
    
    CGRect boundingRect;
    
    #if LH_USE_BOX2D
    LH_b2BuoyancyController* buoyancyController;
    #endif
}

-(void)dealloc{
    
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(bodySplashes);
    LH_SAFE_RELEASE(waves);
    
#if LH_USE_BOX2D
    LH_SAFE_DELETE(buoyancyController);
#endif
    
    _drawNode = nil;
    
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
        
#if LH_USE_BOX2D
        buoyancyController = NULL;
#endif
        
        LHDrawNode* shape = [LHDrawNode node];
        [self addChild:shape];
        _drawNode = shape;
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        //reset size set by node protocol
        self.contentSize = CGSizeZero;

        width = [dict floatForKey:@"width"];
        height = [dict floatForKey:@"height"];
        numLines = [dict floatForKey:@"numLines"];
        waves = [[NSMutableArray alloc] init];
        waterDensity = [dict floatForKey:@"waterDensity"];
        lineWidth = width / numLines;
        
        turbulence = [dict boolForKey:@"turbulence"];
        turbulenceL= [dict floatForKey:@"turbulenceL"];
        turbulenceH= [dict floatForKey:@"turbulenceH"];
        turbulenceV= [dict floatForKey:@"turbulenceV"];
        turbulenceVelocity = [dict floatForKey:@"turbulenceVelocity"];
        
        splashCollision = [dict boolForKey:@"splash"];
        splashHeight    = [dict floatForKey:@"splashH"];
        splashWidth     = [dict floatForKey:@"splashW"];
        splashTime      = [dict floatForKey:@"splashT"];
        
        bodySplashes = [[NSMutableDictionary alloc] init];
        
        [self setColor:[dict colorForKey:@"colorOverlay"]];
        
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        [self createTurbulence];
    }
    
    return self;
}

#pragma mark - PROPERTIES

-(CGFloat)turbulenceAmplitude
{
    return turbulenceH;
}
-(void)setTurbulenceAmplitude:(CGFloat)val
{
    turbulenceH = val;
    [self createTurbulence];
}

-(CGFloat)waveLength
{
    return turbulenceL;
}
-(void)setWaveLength:(CGFloat)val
{
    turbulenceL = val;
    [self createTurbulence];
}



-(void)createTurbulence{
//    [self clearWaves];
    if(turbulence)
        [self createTurbulance:turbulenceH v:turbulenceV l:turbulenceL];
}
-(void)clearWaves{
    [waves removeAllObjects];
}
-(LHWave*)createTurbulance:(float)h v:(float)v l:(float)l
{
    LHWave* wv = LH_AUTORELEASED([[LHWave alloc] init]);
    [wv setWaveBlock:^float (float val){
        return sinf(val);
    }];
    
    wv.left = 0;
    wv.right = width;
    wv.wavelength = l;
    wv.increment = v;
    wv.amplitude = h;
    [self addWave:wv];
    return wv;
}
-(void)addWave:(LHWave*)w
{
    w.startAmplitude = w.amplitude;
    [waves addObject:w];
}

-(float)valueAt:(float)pos
{
    float y = 0;
    for(int i = 0; i < [waves count]; ++i) {
        y += [[waves objectAtIndex:i] valueAt:pos];
    }
    return y;
}

-(float)globalXToWaveX:(float)pointX{
    
    CGPoint pos  = [self position];
    
    float fullWidth = width*[self scaleX];
    float halfWidth = fullWidth*0.5;
    
    float val = (pointX - pos.x) + halfWidth;
    float percent = val/fullWidth;
    
    return width*percent;
}

-(float)waveYToGlobalY:(float)waveY{
    

    CGPoint pos  = [self position];
    
    float waveHeight = height-waveY;
    float percent = waveHeight/height;

    float fullHeight = height*[self scaleY];
    float halfHeight = fullHeight*0.5;
    
    float result = pos.y - fullHeight*percent + halfHeight;
    
    return result;
}


-(NSMutableArray*)createSplash:(float)pos h:(float)h w:(float)w t:(float)t
{
    LHWave* w1 = LH_AUTORELEASED([[LHWave alloc] init]);
    LHWave* w2 = LH_AUTORELEASED([[LHWave alloc] init]);
    
    [w1 setWaveBlock:^float (float val){
        return cosf(val);
    }];
    [w2 setWaveBlock:^float (float val){
        return cosf(val);
    }];
    
    [w1 setDecayBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseOut:t b:b c:c d:d];
    }];
    [w2 setDecayBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseOut:t b:b c:c d:d];
    }];
    
    [w1 setClampBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseInOut:t b:b c:c d:d];
    }];
    [w2 setClampBlock:^float (float t, float b, float c, float d){
        return [LHWave sinEaseInOut:t b:b c:c d:d];
    }];
    
    w1.amplitude = w2.amplitude = h / 2;
    float hw = w / 2;
    w1.left = w2.left = pos - hw;
    w1.right = w2.right = w1.left + w;
    w1.totalSteps = w2.totalSteps = t;
    w1.wavelength = w2.wavelength = hw / (3 * M_PI);
    float v = hw / t;
    w1.velocity = v;
    w2.velocity = -v;
    [self addWave:w1];
    [self addWave:w2];
    return [NSMutableArray arrayWithObjects:w1, w2, nil];
}


-(CGRect)waveRect{
    
    CGPoint pos = [self convertToWorldSpace:CGPointZero];
    
    return CGRectMake(-width *self.scaleX *0.5 + pos.x,
                      -height*self.scaleY*0.5  + pos.y,
                      width  * self.scaleX,
                      height * self.scaleY);
}

#if LH_USE_BOX2D
-(CGRect)boundingRectForBody:(b2Body*)bd
{
    b2AABB aabb;
    b2Transform t;
    t.SetIdentity();
    aabb.lowerBound = b2Vec2(FLT_MAX,FLT_MAX);
    aabb.upperBound = b2Vec2(-FLT_MAX,-FLT_MAX);
    b2Fixture* fixture = bd->GetFixtureList();
    while (fixture != NULL) {
        const b2Shape *shape = fixture->GetShape();
        const int childCount = shape->GetChildCount();
        for (int child = 0; child < childCount; ++child) {
            const b2Vec2 r(shape->m_radius, shape->m_radius);
            b2AABB shapeAABB;
            shape->ComputeAABB(&shapeAABB, t, child);
            shapeAABB.lowerBound = shapeAABB.lowerBound + r;
            shapeAABB.upperBound = shapeAABB.upperBound - r;
            aabb.Combine(shapeAABB);
        }
        fixture = fixture->GetNext();
    }
    
    LHScene* scene = [self scene];
    
    float wm = aabb.upperBound.x - aabb.lowerBound.x;
    float hm = aabb.upperBound.y - aabb.lowerBound.y;
    float x = [scene valueFromMeters:aabb.upperBound.x + bd->GetPosition().x - wm];
    float y = [scene valueFromMeters:aabb.upperBound.y + bd->GetPosition().y - hm];
    float w = [scene valueFromMeters:wm];
    float h = [scene valueFromMeters:hm];
    
    return CGRectMake(x, y, w, h);
}
#endif


#if COCOS2D_VERSION >= 0x00030300
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform{
#else
- (void)visit{
#endif//cocos2d_version

    NSMutableArray* toRemove = [NSMutableArray array];
    for(LHWave* w in waves){
        [w step];
        
        BOOL done = [w decayBlock] != nil && (w.currentStep >= w.totalSteps);
        BOOL outBounds = (w.right <= 0 && w.velocity <= 0) || (w.left >= width && w.velocity >= 0);
        if(done || outBounds) {
            [toRemove addObject:w];
        }
    }
    [waves removeObjectsInArray:toRemove];
    

    NSMutableArray* points = [NSMutableArray array];
    for(int i = 0; i <= numLines; ++i) {
        [points addObject:[NSNumber numberWithFloat:[self valueAt:(i * lineWidth)]]];
    }
    
    float ox = -width*0.5;
    float oy = -height*0.5;
    
    if([points count] > 0)
    {
        NSMutableArray* trianglePts = [NSMutableArray array];

        float firstX = -width*0.5;
        float firstY = height*0.5;
        NSValue* first = LHValueWithCGPoint(CGPointMake(firstX, -firstY));
        [trianglePts addObject:first];
        
        NSValue* prevDown = first;
        
        float x = -width*0.5;
        float y = [[points objectAtIndex:0] floatValue] + oy;
        [trianglePts addObject:LHValueWithCGPoint(CGPointMake(x, -y))];
        
        NSValue* prev = nil;
        for(int i = 1; i < (int)[points count]; ++i)
        {
            x = lineWidth*i - width*0.5;
            y = [[points objectAtIndex:i] floatValue] - height*0.5;
            
            if(prev){
                [trianglePts addObject:first];
                [trianglePts addObject:prev];
            }
            NSValue* curValue = LHValueWithCGPoint(CGPointMake(x, -y));
            [trianglePts addObject:curValue];

            [trianglePts addObject:curValue];
            
            
            NSValue* down = LHValueWithCGPoint(CGPointMake(x, -firstY));
            [trianglePts addObject:down];
            [trianglePts addObject:prevDown];
            prevDown = down;
            first = down;
            
            prev = curValue;
        }
        
        x = width*0.5;
        y = height*0.5;
        [trianglePts addObject:LHValueWithCGPoint(CGPointMake(x, -y))];
        
        x = width + ox;
        y = -height*0.5;
        [trianglePts addObject:LHValueWithCGPoint(CGPointMake(x, -y))];
        [trianglePts addObject:first];
        
        [_drawNode setShapeTriangles:trianglePts
                               color:[self color]];
    }


#if COCOS2D_VERSION >= 0x00030300
    if(renderer)
        [super visit:renderer parentTransform:parentTransform];
#else
    [super visit];
#endif//cocos2d_version
    
    
#if LH_USE_BOX2D
    
    LHScene* scene = [self scene];
    LHGameWorldNode* pNode = [scene gameWorldNode];
    b2World* world = [pNode box2dWorld];
    
    if(NULL == buoyancyController && world){
        buoyancyController = new LH_b2BuoyancyController(world);
        buoyancyController->offset = -1127;
    }
    
    buoyancyController->density = -waterDensity;
    
    if(world){
        for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()){
            
            if(b->GetType() == b2_dynamicBody){
                
                CCNode* node = LH_ID_BRIDGE_CAST(b->GetUserData());
                if(node){

                    CGRect rect = [self waveRect];
                    
                    CGRect bodyRect = [self  boundingRectForBody:b];
                    
                    if(LHRectOverlapsRect(rect,  bodyRect))
                    {
                        CGPoint bodyPt = [scene pointFromMeters:b->GetPosition()];
                        
                        float scaleX = [node scaleX];
                        float scaleY = [node scaleY];
                        
                        float x = bodyPt.x;
                        float y = [self valueAt:[self globalXToWaveX:x]];
                        y = [self waveYToGlobalY:y];
  
                        float globalY = y;
                        
                        y = [scene metersFromValue:y];

                        float splashX = [self globalXToWaveX:x];
                        
                        BOOL addedSplash = false;
                        float previousX = -1000000;
                        b2Fixture* f = b->GetFixtureList();
                        while (f) {
                            
                            if(!f->IsSensor())
                            {
                                buoyancyController->offset = -y;
                                buoyancyController->useDensity = NO;
                                buoyancyController->velocity = b2Vec2(0,0);
                                if(turbulence){
                                    float vdirection = 1.0f;
                                    if(turbulenceV > 0)
                                        vdirection = -1.0f;
                                    buoyancyController->velocity = b2Vec2(vdirection*turbulenceVelocity, 0);
                                }
                                
                                NSString* hadSplash = [bodySplashes objectForKey:[NSString stringWithFormat:@"%p", b->GetUserData()]];
                                
                                bool after = buoyancyController->ApplyToFixture(f);
                                if(after && hadSplash == nil && splashCollision){
                                    
                                    
                                    if(previousX != splashX && !addedSplash){
                                        NSArray* splashes = [self createSplash:splashX
                                                                             h:splashHeight*scaleY
                                                                             w:splashWidth*scaleX
                                                                             t:splashTime];
                                        previousX = splashX;
                                        addedSplash = true;
                                        int i = 0;
                                        for(LHWave* wave in splashes){
                                            [wave step];
                                            ++i;
                                            // if(i > 2)break;
                                        }
                                        
                                        [bodySplashes setObject:[NSNumber numberWithBool:YES]
                                                         forKey:[NSString stringWithFormat:@"%p", b->GetUserData()]];
                                    }
                                }
                                
                                if(self.position.y + height*0.5 - globalY + bodyRect.size.height > bodyPt.y)
                                {
                                    buoyancyController->ApplyToFixture(f);
                                }
                            }
                            f = f->GetNext();
                        }
                    }
                    else{
                        [bodySplashes removeObjectForKey:[NSString stringWithFormat:@"%p", b->GetUserData()]];
                    }
                }
            }
        }
    }
    
    
#else //chipmunk
    
    LHGameWorldNode* world = [(LHScene*)[self scene] gameWorldNode];

    for(CCNode* node in [world children])
    {
        CCPhysicsBody* body = [node physicsBody];
        if(body && [body type] == CCPhysicsBodyTypeDynamic)
        {
            CGPoint pos = [node position];
            
            float x = pos.x;
            float y = [self valueAt:[self globalXToWaveX:x]];
            y = [self waveYToGlobalY:y];
            
            if(self.position.y + height*0.5 - y + node.contentSize.height > pos.y)
            {
                
                NSString* hadSplash = [bodySplashes objectForKey:[NSString stringWithFormat:@"%p", body]];
                if(hadSplash == nil && splashCollision){

                    float splashX = [self globalXToWaveX:x];
                    
                    NSArray* splashes = [self createSplash:splashX
                                                         h:splashHeight*node.scaleY
                                                         w:splashWidth*node.scaleX
                                                         t:splashTime];
                    int i = 0;
                    for(LHWave* wave in splashes){
                        [wave step];
                        ++i;
                        // if(i > 2)break;
                    }
                    [bodySplashes setObject:[NSNumber numberWithBool:YES]
                                     forKey:[NSString stringWithFormat:@"%p", body]];
                }
                [body applyImpulse:CGPointMake(0, waterDensity*100.0)];
            }
            else{
                [bodySplashes removeObjectForKey:[NSString stringWithFormat:@"%p", body]];
            }

        }
    }
#endif//LH_USE_BOX2D
    
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION

@end
