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
#import "LHDrawNode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix:(BOOL)keep2x;
@end

@implementation LHShape
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
    __weak LHDrawNode* _drawNode;

    NSMutableArray* outlinePoints;
    NSMutableArray* trianglePoints;
    
    BOOL _tile;
    CGSize _tileScale;
}


-(void)dealloc{
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    
    _drawNode = nil;
    
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
        
        LHDrawNode* shape = [LHDrawNode node];
        [self addChild:shape];
        _drawNode = shape;
        
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
        }
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        NSArray* triangles = [dict objectForKey:@"triangles"];

        CCColor* colorOverlay = [dict colorForKey:@"colorOverlay"];
        float alpha = [dict floatForKey:@"alpha"];
        ccColor4B c4 = ccc4(colorOverlay.red*255.0f,
                            colorOverlay.green*255.0f,
                            colorOverlay.blue*255.0f, alpha);
        
        CCColor* color = [CCColor colorWithCcColor4b:c4];
        
        outlinePoints = [[NSMutableArray alloc] init];
        
        NSArray* points = [dict objectForKey:@"points"];
        for(NSDictionary* dict in points){
            CGPoint pt = [dict pointForKey:@"point"];
            pt.y = -pt.y;
            [outlinePoints addObject:LHValueWithCGPoint(pt)];
        }
        
        
        trianglePoints = [[NSMutableArray alloc] init];
        
        NSMutableArray* uvPoints = [NSMutableArray array];
        NSMutableArray* colors = [NSMutableArray array];
        
        CGSize imageSize;
        if(self.texture)
            imageSize = CGSizeMake([self.texture pixelWidth], [self.texture pixelHeight]);
        
        for(int i = 0; i < [triangles count]; i+=3)
        {
            NSDictionary* dictA = [triangles objectAtIndex:i];
            NSDictionary* dictB = [triangles objectAtIndex:i+1];
            NSDictionary* dictC = [triangles objectAtIndex:i+2];

            if(!_drawNode.texture){
                
                [colors addObject:color];
                [colors addObject:color];
                [colors addObject:color];
            }
            else{
                float alpha= [dictA floatForKey:@"alpha"];
                CCColor* color = [dictA colorForKey:@"color"];
                ccColor4B c4A = ccc4(color.red*255.0f, color.green*255.0f, color.blue*255.0f, alpha);
                
                alpha= [dictB floatForKey:@"alpha"];
                color = [dictB colorForKey:@"color"];
                ccColor4B c4B = ccc4(color.red*255.0f, color.green*255.0f, color.blue*255.0f, alpha);

                alpha= [dictC floatForKey:@"alpha"];
                color = [dictC colorForKey:@"color"];
                ccColor4B c4C = ccc4(color.red*255.0f,color.green*255.0f,color.blue*255.0f, alpha);
                
                [colors addObject:[CCColor colorWithCcColor4b:c4A]];
                [colors addObject:[CCColor colorWithCcColor4b:c4B]];
                [colors addObject:[CCColor colorWithCcColor4b:c4C]];
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
            
            [uvPoints addObject:LHValueWithCGPoint(uvA)];
            [uvPoints addObject:LHValueWithCGPoint(uvB)];
            [uvPoints addObject:LHValueWithCGPoint(uvC)];
            
            [_drawNode setShapeTriangles:trianglePoints
                                uvPoints:uvPoints
                            vertexColors:colors];
        }

        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:dict
                                                                                                node:self];
        
        self.contentSize = CGSizeZero;
        
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
    }
    
    return self;
}

-(void) setTexture:(CCTexture*)texture{
    if(_drawNode)
        _drawNode.texture = texture;
}
-(CCTexture*) texture{
	return _drawNode.texture;
}

-(void) setBlendFunc:(ccBlendFunc)blendFunc{
    if(_drawNode){
        [_drawNode setBlendFunc:blendFunc];
    }
}
-(ccBlendFunc) blendFunc{
    return [_drawNode blendFunc];
}

-(NSMutableArray*)trianglePoints{
    return trianglePoints;
}
-(NSMutableArray*)outlinePoints{
    return outlinePoints;
}

#if COCOS2D_VERSION >= 0x00030300
-(void) visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
    if(!renderer)return;
    
    [_physicsProtocolImp visit];
    [_animationProtocolImp visit];
    
    [super visit:renderer parentTransform:parentTransform];
}
#else
- (void)visit
{
    [_physicsProtocolImp visit];
    [_animationProtocolImp visit];
    
    [super visit];
}
#endif//cocos2d_version

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
