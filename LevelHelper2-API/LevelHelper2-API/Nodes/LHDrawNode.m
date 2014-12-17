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

@implementation LHDrawNode

-(id)init
{
    if(self = [super init]){
        
#if COCOS2D_VERSION >= 0x00030300
//        _shader = [CCShader shaderNamed:@""];
#else
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
#endif//cocos2d_version

        
    }
    return self;
}


-(void)setShapeTriangles:(NSArray*)triangles
                uvPoints:(NSArray*)uvPoints
                   color:(CCColor*)color;
{
    [self clear];

#if COCOS2D_VERSION >= 0x00030300
    //XXX
#else
    _blendFunc.src = GL_SRC_ALPHA;
    _blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
#endif//cocos2d_version


    
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
        
        
#if COCOS2D_VERSION >= 0x00030300
        //XXX
#else
        ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
        triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
        
        _bufferCount += 3;
#endif//cocos2d_version

    }
    
    
#if COCOS2D_VERSION >= 0x00030300
    //XXX
#else
    _dirty = YES;
#endif//cocos2d_version

}


-(void)ensureCapacity:(NSUInteger)count
{
#if COCOS2D_VERSION >= 0x00030300
    //XXX
#else
    if(_bufferCount + count > _bufferCapacity){
        _bufferCapacity += MAX(_bufferCapacity, count);
        _buffer = realloc(_buffer, _bufferCapacity*sizeof(ccV2F_C4B_T2F));
    }
#endif//cocos2d_version

}



-(void) updateBlendFunc{
	if( !_texture || ! [_texture hasPremultipliedAlpha] ) {
        
#if COCOS2D_VERSION >= 0x00030300
        //XXX
#else
        _blendFunc.src = GL_SRC_ALPHA;
        _blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;

#endif//cocos2d_version

        
		[self setOpacityModifyRGB:NO];
	} else {
        
#if COCOS2D_VERSION >= 0x00030300
        //XXX
#else
        _blendFunc.src = CC_BLEND_SRC;
        _blendFunc.dst = CC_BLEND_DST;
#endif//cocos2d_version

		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture*)texture{
    NSAssert( !texture || [texture isKindOfClass:[CCTexture class]], @"setTexture expects a CCTexture2D. Invalid argument");
	if(_texture != texture ) {
		_texture = texture;
        
#if COCOS2D_VERSION >= 0x00030300
        //XXX
#else
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
#endif//cocos2d_version

		[self updateBlendFunc];
	}
}
-(CCTexture*) texture{
	return _texture;
}




-(void)render
{
#if COCOS2D_VERSION >= 0x00030300
    //XXX
#else
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
#endif//cocos2d_version

    
	
}

-(void)draw
{
    
#if COCOS2D_VERSION >= 0x00030300
    //XXX
#else
    ccGLBlendFunc(_blendFunc.src, _blendFunc.dst);
    
    ccGLBindTexture2D( [_texture name] );
    
    [_shaderProgram use];
    [_shaderProgram setUniformsForBuiltins];
    
    [self render];

#endif//cocos2d_version

}

@end
