//
//  LHDrawNode.h
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright (c) 2014 Bogdan Vladu. All rights reserved.
//

#import "cocos2d.h"

@interface LHDrawNode : CCDrawNode <CCTextureProtocol>
{
#if COCOS2D_VERSION < 0x00030300
    CCTexture *_texture; // Texture used to render the shape
#endif//cocos2d_version
}

-(void)setShapeTriangles:(NSArray*)sPoints
                uvPoints:(NSArray*)uvPoints
                   color:(CCColor*)color;

#if COCOS2D_VERSION < 0x00030300
-(void)setTexture:(CCTexture*)texture;
-(CCTexture*)texture;
#endif//cocos2d_version

@end
