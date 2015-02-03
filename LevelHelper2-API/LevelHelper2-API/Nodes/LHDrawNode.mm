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

#else
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
#endif//cocos2d_version

        
    }
    return self;
}

#if COCOS2D_VERSION >= 0x00030300

-(void)setShapeTriangles:(NSArray*)triangles
                   color:(CCColor*)color
{
    [self clear];
    
    GLKVector4 c = color.glkVector4;
    GLKVector4 fill4 = GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);
    
    const GLKVector2 GLKVector2Zero = {{0.0f, 0.0f}};
    
    for(int i = 0; i < [triangles count]; i+=3)
    {
        NSValue* valA = [triangles objectAtIndex:i];
        NSValue* valB = [triangles objectAtIndex:i+1];
        NSValue* valC = [triangles objectAtIndex:i+2];
        
        CGPoint pa = CGPointFromValue(valA);
        CGPoint pb = CGPointFromValue(valB);
        CGPoint pc = CGPointFromValue(valC);
        
        CCRenderBuffer buffer = [self bufferVertexes:3 andTriangleCount:1];
        

        CCVertex va = (CCVertex){GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
                    GLKVector2Zero,
                    GLKVector2Zero,
                    fill4};
        
        CCVertex vb = (CCVertex){   GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
                    GLKVector2Zero,
                    GLKVector2Zero,
                    fill4};
        
        CCVertex vc = (CCVertex){   GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
                    GLKVector2Zero,
                    GLKVector2Zero,
                    fill4};
                
        CCRenderBufferSetVertex(buffer, 0, va);
        CCRenderBufferSetVertex(buffer, 1, vb);
        CCRenderBufferSetVertex(buffer, 2, vc);
        
        CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    }
}
-(void)setShapeTriangles:(NSArray*)triangles//contains NSValue with point
                uvPoints:(NSArray*)uvPoints//contains NSValue with point
            vertexColors:(NSArray*)colors//contains CCColor
{
    [self clear];
    
    const GLKVector2 GLKVector2Zero = {{0.0f, 0.0f}};
    
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
        
        CCColor* cA = [colors objectAtIndex:i];
        CCColor* cB = [colors objectAtIndex:i+1];
        CCColor* cC = [colors objectAtIndex:i+2];
        
        GLKVector4 c = cA.glkVector4;
        GLKVector4 fill4A = GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);

        c = cB.glkVector4;
        GLKVector4 fill4B = GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);

        c = cC.glkVector4;
        GLKVector4 fill4C = GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);

        
        CCRenderBuffer buffer = [self bufferVertexes:3 andTriangleCount:1];
        
        CCVertex va = (CCVertex){   GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
            GLKVector2Make(ua.x, ua.y),
            GLKVector2Zero,
            fill4A};
        
        if(!self.texture){
            va = (CCVertex){GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
                GLKVector2Zero,
                GLKVector2Make(ua.x, ua.y),
                fill4A};
        }
        
        
        CCVertex vb = (CCVertex){   GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
            GLKVector2Make(ub.x, ub.y),
            GLKVector2Zero,
            fill4B};
        
        if(!self.texture){
            vb = (CCVertex){GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
                GLKVector2Zero,
                GLKVector2Make(ub.x, ub.y),
                fill4B};
        }
        
        
        CCVertex vc = (CCVertex){   GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
            GLKVector2Make(uc.x, uc.y),
            GLKVector2Zero,
            fill4C};
        
        if(!self.texture){
            vc = (CCVertex){GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
                GLKVector2Zero,
                GLKVector2Make(uc.x, uc.y),
                fill4C};
        }
        
        
        CCRenderBufferSetVertex(buffer, 0, va);
        CCRenderBufferSetVertex(buffer, 1, vb);
        CCRenderBufferSetVertex(buffer, 2, vc);
        
        CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    }
}
-(void)setShapeTriangles:(NSArray*)triangles
                uvPoints:(NSArray*)uvPoints
                   color:(CCColor*)color
{
    [self clear];
    
    GLKVector4 c = color.glkVector4;
    GLKVector4 fill4 = GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);
    
    const GLKVector2 GLKVector2Zero = {{0.0f, 0.0f}};
    
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

        CCRenderBuffer buffer = [self bufferVertexes:3 andTriangleCount:1];
        
        CCVertex va = (CCVertex){   GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
                                    GLKVector2Make(ua.x, ua.y),
                                    GLKVector2Zero,
                                    fill4};
        
        if(!self.texture){
            va = (CCVertex){GLKVector4Make(pa.x, pa.y, 0.0f, 1.0f),
                            GLKVector2Zero,
                            GLKVector2Make(ua.x, ua.y),
                            fill4};
        }
        
        
        CCVertex vb = (CCVertex){   GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
                                    GLKVector2Make(ub.x, ub.y),
                                    GLKVector2Zero,
                                    fill4};

        if(!self.texture){
                vb = (CCVertex){GLKVector4Make(pb.x, pb.y, 0.0f, 1.0f),
                                GLKVector2Zero,
                                GLKVector2Make(ub.x, ub.y),
                                fill4};
        }

        
        CCVertex vc = (CCVertex){   GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
                                    GLKVector2Make(uc.x, uc.y),
                                    GLKVector2Zero,
                                    fill4};
        
        if(!self.texture){
            vc = (CCVertex){GLKVector4Make(pc.x, pc.y, 0.0f, 1.0f),
                            GLKVector2Zero,
                            GLKVector2Make(uc.x, uc.y),
                            fill4};
        }


        CCRenderBufferSetVertex(buffer, 0, va);
        CCRenderBufferSetVertex(buffer, 1, vb);
        CCRenderBufferSetVertex(buffer, 2, vc);
        
        CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
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
                   color:(CCColor*)color
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
        
        CGPoint posA = CGPointFromValue(valA);
        CGPoint posB = CGPointFromValue(valB);
        CGPoint posC = CGPointFromValue(valC);
        
        ccV2F_C4B_T2F a = { {(GLfloat)posA.x, (GLfloat)posA.y},
            {   (GLubyte)(color.red*255.0f),
                (GLubyte)(color.green*255.0f),
                (GLubyte)(color.blue*255.0f),
                (GLubyte)(color.alpha*255.0f)}};
        ccV2F_C4B_T2F b = { {(GLfloat)posB.x, (GLfloat)posB.y},
            {   (GLubyte)(color.red*255.0f),
                (GLubyte)(color.green*255.0f),
                (GLubyte)(color.blue*255.0f),
                (GLubyte)(color.alpha*255.0f)}};
        ccV2F_C4B_T2F c = { {(GLfloat)posC.x, (GLfloat)posC.y},
            {   (GLubyte)(color.red*255.0f),
                (GLubyte)(color.green*255.0f),
                (GLubyte)(color.blue*255.0f),
                (GLubyte)(color.alpha*255.0f)}};
        
        ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
        triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
        
        _bufferCount += 3;
    }
    
    _dirty = YES;
}

-(void)setShapeTriangles:(NSArray*)triangles//contains NSValue with point
                uvPoints:(NSArray*)uvPoints//contains NSValue with point
            vertexColors:(NSArray*)colors//contains CCColor
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
        
        CCColor* cA = [colors objectAtIndex:i];
        CCColor* cB = [colors objectAtIndex:i+1];
        CCColor* cC = [colors objectAtIndex:i+2];
        
        ccV2F_C4B_T2F a = {{pa.x, pa.y}, [cA ccColor4b], {ua.x, ua.y} };
        ccV2F_C4B_T2F b = {{pb.x, pb.y}, [cB ccColor4b], {ub.x, ub.y} };
        ccV2F_C4B_T2F c = {{pc.x, pc.y}, [cC ccColor4b], {uc.x, uc.y} };
        
        ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
        triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
        
        _bufferCount += 3;
    }
    
    _dirty = YES;
}

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
