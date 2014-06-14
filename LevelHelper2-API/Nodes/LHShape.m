//
//  LHShape.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHShape.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHAnimation.h"
#import "CCTexture_Private.h"

@implementation LHShape
{
    NSTimeInterval lastTime;
    
    LHNodeProtocolImpl* _nodeProtocolImp;
    
    NSMutableArray* _animations;
    __weak LHAnimation* activeAnimation;
    
    NSMutableArray* outlinePoints;
    NSMutableArray* trianglePoints;
}


-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
    LH_SAFE_RELEASE(outlinePoints);
    LH_SAFE_RELEASE(trianglePoints);
    
    LH_SAFE_RELEASE(_animations);
    activeAnimation = nil;

    LH_SUPER_DEALLOC();
}


+ (instancetype)shapeNodeWithDictionary:(NSDictionary*)dict
                                  parent:(CCNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initShapeNodeWithDictionary:dict
                                                              parent:prnt]);
}

- (instancetype)initShapeNodeWithDictionary:(NSDictionary*)dict
                                     parent:(CCNode*)prnt{
    
    
    if(self = [super init]){
        
        [prnt addChild:self];
        
        LHScene* scene = (LHScene*)[prnt scene];
        
        NSString* imgRelPath = [dict objectForKey:@"relativeImagePath"];
        if(imgRelPath)
        {
            NSString* filename = [imgRelPath lastPathComponent];
            NSString* foldername = [[imgRelPath stringByDeletingLastPathComponent] lastPathComponent];
            
            NSString* imagePath = [LHUtils imagePathWithFilename:filename
                                                          folder:foldername
                                                          suffix:[scene currentDeviceSuffix:NO]];

            CCTexture* texture = [scene textureWithImagePath:imagePath];
            
            self.texture = texture;
            ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
            [self.texture setTexParameters: &texParams];
            
            _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
        }
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
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
                
        self.contentSize = [dict sizeForKey:@"size"];
        
        NSArray* triangles = [dict objectForKey:@"triangles"];
        [self ensureCapacity:[triangles count]];
        
        CCColor* colorOverlay = [dict colorForKey:@"colorOverlay"];
        ccColor4B c4 = ccc4(colorOverlay.red*255.0f,
                            colorOverlay.green*255.0f,
                            colorOverlay.blue*255.0f, alpha);
        
        outlinePoints = [[NSMutableArray alloc] init];
        
        NSArray* points = [dict objectForKey:@"points"];
        for(NSDictionary* dict in points){
            CGPoint pt = [dict pointForKey:@"point"];
            pt.y = -pt.y;
            [outlinePoints addObject:LHValueWithCGPoint(pt)];
        }
        
        
        trianglePoints = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < [triangles count]; i+=3)
        {
            NSDictionary* dictA = [triangles objectAtIndex:i];
            NSDictionary* dictB = [triangles objectAtIndex:i+1];
            NSDictionary* dictC = [triangles objectAtIndex:i+2];

            ccColor4B c4A;
            ccColor4B c4B;
            ccColor4B c4C;
            
            if(!_texture){
                c4A = c4;
                c4B = c4;
                c4C = c4;
            }
            else{
                float alpha= [dictA floatForKey:@"alpha"];
                CCColor* color = [dictA colorForKey:@"color"];
                c4A = ccc4(color.red*255.0f, color.green*255.0f, color.blue*255.0f, alpha);
                
                alpha= [dictB floatForKey:@"alpha"];
                color = [dictB colorForKey:@"color"];
                c4B = ccc4(color.red*255.0f, color.green*255.0f, color.blue*255.0f, alpha);

                alpha= [dictC floatForKey:@"alpha"];
                color = [dictC colorForKey:@"color"];
                c4C = ccc4(color.red*255.0f,color.green*255.0f,color.blue*255.0f, alpha);
            }

            CGPoint posA = [dictA pointForKey:@"point"];
            posA.y = -posA.y;
            CGPoint uvA = [dictA pointForKey:@"uv"];

            CGPoint posB = [dictB pointForKey:@"point"];
            posB.y = -posB.y;
            CGPoint uvB = [dictB pointForKey:@"uv"];

            CGPoint posC = [dictC pointForKey:@"point"];
            posC.y = -posC.y;
            CGPoint uvC = [dictC pointForKey:@"uv"];

            [trianglePoints addObject:LHValueWithCGPoint(posA)];
            [trianglePoints addObject:LHValueWithCGPoint(posB)];
            [trianglePoints addObject:LHValueWithCGPoint(posC)];
            
            ccV2F_C4B_T2F a = {{posA.x, posA.y}, c4A, {uvA.x, uvA.y} };
            ccV2F_C4B_T2F b = {{posB.x, posB.y}, c4B, {uvB.x, uvB.y} };
            ccV2F_C4B_T2F c = {{posC.x, posC.y}, c4C, {uvC.x, uvC.y} };
            
            ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
            triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
            
            _bufferCount += 3;
        }

        _dirty = YES;
    
        [LHUtils loadPhysicsFromDict:[dict objectForKey:@"nodePhysics"]
                             forNode:self];        
        
        //scale must be set after loading the physic info or else spritekit will not resize the body
        CGPoint scl = [dict pointForKey:@"scale"];
        [self setScaleX:scl.x];
        [self setScaleY:scl.y];
        
        
        NSArray* childrenInfo = [dict objectForKey:@"children"];
        if(childrenInfo)
        {
            for(NSDictionary* childInfo in childrenInfo)
            {
                CCNode* node = [LHScene createLHNodeWithDictionary:childInfo
                                                            parent:self];
#pragma unused (node)
            }
        }
        
        [LHUtils createAnimationsForNode:self
                         animationsArray:&_animations
                         activeAnimation:&activeAnimation
                          fromDictionary:dict];
    }
    
    return self;
}


-(void)ensureCapacity:(NSUInteger)count
{
	if(_bufferCount + count > _bufferCapacity){
		_bufferCapacity += MAX(_bufferCapacity, count);
		_buffer = realloc(_buffer, _bufferCapacity*sizeof(ccV2F_C4B_T2F));
		
        //		NSLog(@"Resized vertex buffer to %d", _bufferCapacity);
	}
}



-(void) updateBlendFunc{
	if( !_texture || ! [_texture hasPremultipliedAlpha] ) {
		_blendFunc.src = GL_SRC_ALPHA;
		_blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		[self setOpacityModifyRGB:NO];
	} else {
		_blendFunc.src = CC_BLEND_SRC;
		_blendFunc.dst = CC_BLEND_DST;
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture*)texture{
    NSAssert( !texture || [texture isKindOfClass:[CCTexture class]], @"setTexture expects a CCTexture2D. Invalid argument");
	if(_texture != texture ) {
		_texture = texture;
		[self updateBlendFunc];
	}
}
-(CCTexture*) texture{
	return _texture;
}




-(void)render
{
	if( _dirty ) {
		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
		glBufferData(GL_ARRAY_BUFFER, sizeof(ccV2F_C4B_T2F)*_bufferCapacity, _buffer, GL_STREAM_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		_dirty = NO;
	}
	
	ccGLBindVAO(_vao);
	glDrawArrays(GL_TRIANGLES, 0, _bufferCount);
	
	CC_INCREMENT_GL_DRAWS(1);
	
	CHECK_GL_ERROR();
}

-(void)draw
{
	ccGLBlendFunc(_blendFunc.src, _blendFunc.dst);

    ccGLBindTexture2D( [_texture name] );

	[_shaderProgram use];
	[_shaderProgram setUniformsForBuiltins];
	
	[self render];
}

-(NSMutableArray*)trianglePoints{
    return trianglePoints;
}
-(NSMutableArray*)outlinePoints{
    return outlinePoints;
}

-(void)visit
{
    NSTimeInterval thisTime = [NSDate timeIntervalSinceReferenceDate];
    float dt = thisTime - lastTime;
    
    if(activeAnimation){
        [activeAnimation updateTimeWithDelta:dt];
    }
    
    [super visit];
    
    lastTime = thisTime;
}

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark - LHNodeAnimationProtocol
-(void)setActiveAnimation:(LHAnimation*)anim{
    activeAnimation = anim;
}


@end
