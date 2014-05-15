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
    CCTexture *_texture; // Texture used to render the shape
}

-(void)setShapeTriangles:(NSArray*)sPoints
                uvPoints:(NSArray*)uvPoints
                   color:(CCColor*)color;

-(void)setTexture:(CCTexture*)texture;
-(CCTexture*)texture;

@end
