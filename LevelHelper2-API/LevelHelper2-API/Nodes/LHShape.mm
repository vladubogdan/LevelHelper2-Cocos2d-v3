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
#import "LHConfig.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix:(BOOL)keep2x;
@end

@implementation LHShape
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
    
    NSMutableArray* outlinePoints;
    NSMutableArray* trianglePoints;
    
    BOOL _tile;
    CGSize _tileScale;
}


-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    
    
    LH_SAFE_RELEASE(outlinePoints);
    LH_SAFE_RELEASE(trianglePoints);
    
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
        
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
        
        _tile = [dict boolForKey:@"tileTexture"];
        _tileScale = [dict sizeForKey:@"tileScale"];
        
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
        
        self.contentSize = CGSizeZero;
        
        
        NSArray* triangles = [dict objectForKey:@"triangles"];
        [self ensureCapacity:[triangles count]];
        
        CCColor* colorOverlay = [dict colorForKey:@"colorOverlay"];
        float alpha = [dict floatForKey:@"alpha"];
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
        
        int count = (int)[triangles count]/3;
        [self ensureCapacity:count];
        
        CGSize imageSize;
        if(self.texture)
            imageSize = CGSizeMake([self.texture pixelWidth], [self.texture pixelHeight]);
        
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
            
            if(_tile && self.texture){
                
                uvA.x = (posA.x/imageSize.width)*(_tileScale.width);
                uvA.y = -(posA.y/imageSize.height)*(_tileScale.height);
                
                uvB.x = (posB.x/imageSize.width)*(_tileScale.width);
                uvB.y = -(posB.y/imageSize.height)*(_tileScale.height);
                
                uvC.x = (posC.x/imageSize.width)*(_tileScale.width);
                uvC.y = -(posC.y/imageSize.height)*(_tileScale.height);
            }

            [trianglePoints addObject:LHValueWithCGPoint(posA)];
            [trianglePoints addObject:LHValueWithCGPoint(posB)];
            [trianglePoints addObject:LHValueWithCGPoint(posC)];
            
            ccV2F_C4B_T2F a = {{(GLfloat)posA.x, (GLfloat)posA.y}, c4A, {(GLfloat)uvA.x, (GLfloat)uvA.y} };
            ccV2F_C4B_T2F b = {{(GLfloat)posB.x, (GLfloat)posB.y}, c4B, {(GLfloat)uvB.x, (GLfloat)uvB.y} };
            ccV2F_C4B_T2F c = {{(GLfloat)posC.x, (GLfloat)posC.y}, c4C, {(GLfloat)uvC.x, (GLfloat)uvC.y} };
            
            ccV2F_C4B_T2F_Triangle *triangles = (ccV2F_C4B_T2F_Triangle *)(_buffer + _bufferCount);
            triangles[0] = (ccV2F_C4B_T2F_Triangle){a, b, c};
            
            _bufferCount += 3;
        }

        _dirty = YES;
    

        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
                
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
    }
    
    return self;
}


-(void)ensureCapacity:(NSUInteger)count
{
	if(_bufferCount + count > _bufferCapacity){
		_bufferCapacity += MAX(_bufferCapacity, count);
		_buffer = (ccV2F_C4B_T2F*)realloc(_buffer, _bufferCapacity*sizeof(ccV2F_C4B_T2F));
		
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
