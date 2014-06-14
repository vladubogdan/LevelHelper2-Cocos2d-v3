//
//  LHBox2dDebug.m
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 10/16/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "LHBox2dDebug.h"
#import "LHUtils.h"

#include <cstdio>
#include <cstdarg>

#include <cstring>

#import "LHScene.h"

#if LH_USE_BOX2D


@implementation LHBox2dDrawNode
{
    LHBox2dDebug* debug;
}

-(id)init{
    if(self = [super init]){
        debug = NULL;
    }
    return self;
}

-(void)dealloc{
    LH_SAFE_DELETE(debug);
    LH_SUPER_DEALLOC();
}

-(LHBox2dDebug*)box2dDebug{
    if(!debug){
        debug = new LHBox2dDebug(32, self);
    }
    return debug;
}
//-(void)render
//{
//    [super render];
//    
//	if( _dirty ) {
//		glBindBuffer(GL_ARRAY_BUFFER, _vbo);
//		glBufferData(GL_ARRAY_BUFFER, sizeof(ccV2F_C4B_T2F)*_bufferCapacity, _buffer, GL_STREAM_DRAW);
//		glBindBuffer(GL_ARRAY_BUFFER, 0);
//		_dirty = NO;
//	}
//	
//	ccGLBindVAO(_vao);
//	glDrawArrays(GL_TRIANGLES, 0, _bufferCount);
//	
//	CC_INCREMENT_GL_DRAWS(1);
//	
//	CHECK_GL_ERROR();
//}

-(void)draw
{
    [self clear];
    LHScene* scene = (LHScene*)[self scene];
    [scene box2dWorld]->DrawDebugData();
    
    [super draw];
}
@end







LHBox2dDebug::LHBox2dDebug( float ratio, LHBox2dDrawNode* node )
: mRatio( ratio ){
    drawNode = node;
}
void LHBox2dDebug::setRatio(float ratio){
    mRatio = ratio;
}

void LHBox2dDebug::DrawPolygon(const b2Vec2* old_vertices, int32 vertexCount, const b2Color& color)
{
    CGPoint* vertices = new CGPoint[vertexCount];
    for( int i=0;i<vertexCount;i++) {
		b2Vec2 tmp = old_vertices[i];
		tmp *= mRatio;
		vertices[i] = CGPointMake(tmp.x, tmp.y);
	}
    
    CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 0.5)];
    CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 1)];
    [drawNode drawPolyWithVerts:vertices count:vertexCount fillColor:fillColor borderWidth:1 borderColor:borderColor];
    
    delete[] vertices;
}

void LHBox2dDebug::DrawSolidPolygon(const b2Vec2* old_vertices, int32 vertexCount, const b2Color& color)
{
    CGPoint* vertices = new CGPoint[vertexCount];
    
    for( int i=0;i<vertexCount;i++) {
		b2Vec2 tmp = old_vertices[i];
		tmp *= mRatio;
        vertices[i] = CGPointMake(tmp.x, tmp.y);
	}
    
    CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 0.5)];
    CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 1)];
    [drawNode drawPolyWithVerts:vertices count:vertexCount fillColor:fillColor borderWidth:1 borderColor:borderColor];

    delete[] vertices;
}

void LHBox2dDebug::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
	CGPoint* vertices = new CGPoint[vertexCount];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));

        vertices[i] = CGPointMake(v.x*mRatio, v.y*mRatio);
		theta += k_increment;
	}
	
    CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 1)];
    [drawNode drawPolyWithVerts:vertices count:vertexCount fillColor:[CCColor blackColor] borderWidth:1 borderColor:borderColor];

    delete[] vertices;
}

void LHBox2dDebug::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	int vertexCount=16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;
	
    CGPoint* vertices = new CGPoint[vertexCount];
	for (int32 i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
        vertices[i] = CGPointMake(v.x*mRatio, v.y*mRatio);
		theta += k_increment;
	}

    CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 0.5)];
    CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 1)];
    [drawNode drawPolyWithVerts:vertices
                          count:vertexCount
                      fillColor:fillColor
                    borderWidth:1
                    borderColor:borderColor];

    delete[] vertices;
    
	// Draw the axis line
	DrawSegment(center,center+radius*axis,color);
}

void LHBox2dDebug::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	CGPoint pointA  = CGPointMake(p1.x *mRatio,p1.y*mRatio);
    CGPoint pointB  = CGPointMake(p2.x*mRatio,p2.y*mRatio);
    
    CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(color.r, color.g, color.b, 1)];
    [drawNode drawSegmentFrom:pointA to:pointB radius:1 color:borderColor];
}

void LHBox2dDebug::DrawTransform(const b2Transform& xf)
{
//	b2Vec2 p1 = xf.p, p2;
//	const float32 k_axisScale = 0.4f;
//    
//	p2 = p1 + k_axisScale * xf.q.col1;
//	DrawSegment(p1,p2,b2Color(1,0,0));
//	
//	p2 = p1 + k_axisScale * xf.q.col2;
//	DrawSegment(p1,p2,b2Color(0,1,0));
}

void LHBox2dDebug::DrawPoint(const b2Vec2& p, float32 size, const b2Color& color)
{
//	glColor4f(color.r, color.g, color.b,1);
//	glPointSize(size);
//	GLfloat				glVertices[] = {
//		p.x*mRatio,p.y*mRatio
//	};
//	glVertexPointer(2, GL_FLOAT, 0, glVertices);
//	glDrawArrays(GL_POINTS, 0, 1);
//	glPointSize(1.0f);
}

void LHBox2dDebug::DrawString(int x, int y, const char *string, ...)
{
    
	/* Unsupported as yet. Could replace with bitmap font renderer at a later date */
}

void LHBox2dDebug::DrawAABB(b2AABB* aabb, const b2Color& c)
{
//	glColor4f(c.r, c.g, c.b,1);
//    
//	GLfloat				glVertices[] = {
//		aabb->lowerBound.x, aabb->lowerBound.y,
//		aabb->upperBound.x, aabb->lowerBound.y,
//		aabb->upperBound.x, aabb->upperBound.y,
//		aabb->lowerBound.x, aabb->upperBound.y
//	};
//	glVertexPointer(2, GL_FLOAT, 0, glVertices);
//	glDrawArrays(GL_LINE_LOOP, 0, 8);
	
}

#endif //LH_USE_BOX2D
