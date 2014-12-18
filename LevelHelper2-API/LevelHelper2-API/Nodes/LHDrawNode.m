//
//  LHDrawNode.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright (c) 2014 Bogdan Vladu. All rights reserved.
//

#import "LHDrawNode.h"
#import "CCTexture_Private.h"
#import "LHUtils.h"

#if COCOS2D_VERSION >= 0x00030300
    #import "CCNode_Private.h"
#endif//cocos2d_version

@interface CCDrawNode ()

-(CCRenderBuffer)bufferVertexes:(GLsizei)vertexCount andTriangleCount:(GLsizei)triangleCount;

@end

@implementation LHDrawNode

-(id)init
{
    if(self = [super init]){
        
#if COCOS2D_VERSION >= 0x00030300
//        _shader = [CCShader positionColorShader];
#else
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
#endif//cocos2d_version

        
    }
    return self;
}

#if COCOS2D_VERSION >= 0x00030300

-(void)setShapeTriangles:(NSArray*)triangles
                uvPoints:(NSArray*)uvPoints
                   color:(CCColor*)color
{
    [self clear];
    
    NSUInteger vertexCount = [triangles count]*3;
    CCRenderBuffer buffer = [self bufferVertexes:(GLsizei)vertexCount andTriangleCount:(GLsizei)[triangles count]];
    
    
    GLKVector4 c = color.glkVector4;
    GLKVector4 fill4 = GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);
    
    
    int vertexCursor = 0, triangleCursor = 0;
    
    const GLKVector2 GLKVector2Zero = {{0.0f, 0.0f}};
    
    int count = (int)[triangles count];
    
    for(int i = 0; i < [triangles count]; i+=3)
    {
        NSValue* valA = [triangles objectAtIndex:i];
        NSValue* valB = [triangles objectAtIndex:i+1];
        NSValue* valC = [triangles objectAtIndex:i+2];
        
        
        NSValue* uvA = [uvPoints objectAtIndex:i];
        NSValue* uvB = [uvPoints objectAtIndex:i+1];
        NSValue* uvC = [uvPoints objectAtIndex:i+2];
        
        
        CGPoint pa = CGPointFromValue(valA);
        CGPoint pb = CGPointFromValue(valB);
        CGPoint pc = CGPointFromValue(valC);
        
        CGPoint ua = CGPointFromValue(uvA);
        CGPoint ub = CGPointFromValue(uvB);
        CGPoint uc = CGPointFromValue(uvC);
        
        if(self.texture)
        {
            CCRenderBufferSetVertex(buffer,
                                    vertexCursor++,
                                    (CCVertex){ GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
                                        GLKVector2Make(ua.x, ua.y),
                                        GLKVector2Zero,
                                        fill4}
                                    );
            
            CCRenderBufferSetVertex(buffer,
                                    vertexCursor++,
                                    (CCVertex){ GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
                                        GLKVector2Make(ub.x, ub.y),
                                        GLKVector2Zero,
                                        fill4}
                                    );
            
            CCRenderBufferSetVertex(buffer,
                                    vertexCursor++,
                                    (CCVertex){ GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
                                        GLKVector2Make(uc.x, uc.y),
                                        GLKVector2Zero,
                                        fill4}
                                    );
            
        }
        else{
            CCRenderBufferSetVertex(buffer,
                                    vertexCursor++,
                                    (CCVertex){ GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
                                        GLKVector2Zero,
                                        GLKVector2Make(ua.x, ua.y),
                                        fill4}
                                    );
            
            CCRenderBufferSetVertex(buffer,
                                    vertexCursor++,
                                    (CCVertex){ GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
                                        GLKVector2Zero,
                                        GLKVector2Make(ub.x, ub.y),
                                        fill4}
                                    );
            
            CCRenderBufferSetVertex(buffer,
                                    vertexCursor++,
                                    (CCVertex){ GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
                                        GLKVector2Zero,
                                        GLKVector2Make(uc.x, uc.y),
                                        fill4}
                                    );

        }
        
    }
    
    for(int i=0; i<count; i++){
        CCRenderBufferSetTriangle(buffer, triangleCursor++, i, i + 1, i + 2);
    }
}

-(void) setTexture:(CCTexture*)texture{
    NSAssert( !texture || [texture isKindOfClass:[CCTexture class]], @"setTexture expects a CCTexture2D. Invalid argument");

    self.blendMode = [CCBlendMode premultipliedAlphaMode];
    self.shader = [CCShader positionTextureColorShader];
    [super setTexture:texture];
}

#else

-(void)setShapeTriangles:(NSArray*)triangles
                uvPoints:(NSArray*)uvPoints
                   color:(CCColor*)color;
{
    [self clear];
    
    _blendFunc.src = GL_SRC_ALPHA;
    _blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
    
    int count = (int)[triangles count];
    [self ensureCapacity:count];
    
    for(int i = 0; i < [triangles count]; i+=3)
    {
        NSValue* valA = [triangles objectAtIndex:i];
        NSValue* valB = [triangles objectAtIndex:i+1];
        NSValue* valC = [triangles objectAtIndex:i+2];
        
        
        NSValue* uvA = [uvPoints objectAtIndex:i];
        NSValue* uvB = [uvPoints objectAtIndex:i+1];
        NSValue* uvC = [uvPoints objectAtIndex:i+2];
        
        
        CGPoint pa = CGPointFromValue(valA);
        CGPoint pb = CGPointFromValue(valB);
        CGPoint pc = CGPointFromValue(valC);
        
        CGPoint ua = CGPointFromValue(uvA);
        CGPoint ub = CGPointFromValue(uvB);
        CGPoint uc = CGPointFromValue(uvC);
        
        ccColor4B c4 = ccc4(color.red*255.0f, color.green*255.0f, color.blue*255.0f, color.alpha*255.0f);
        
        ccV2F_C4B_T2F a = {{pa.x, pa.y}, c4, {ua.x, ua.y} };
        ccV2F_C4B_T2F b = {{pb.x, pb.y}, c4, {ub.x, ub.y} };
        ccV2F_C4B_T2F c = {{pc.x, pc.y}, c4, {uc.x, uc.y} };
        
        
        ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
        triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
        
        _bufferCount += 3;
    }
    
    
    _dirty = YES;
}

-(void)ensureCapacity:(NSUInteger)count
{
    if(_bufferCount + count > _bufferCapacity){
        _bufferCapacity += MAX(_bufferCapacity, count);
        _buffer = realloc(_buffer, _bufferCapacity*sizeof(ccV2F_C4B_T2F));
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
        
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
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

#endif//cocos2d_version


@end
