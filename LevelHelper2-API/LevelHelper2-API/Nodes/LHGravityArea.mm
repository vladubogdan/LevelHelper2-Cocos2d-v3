//
//  LHGravityArea.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 31/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHGravityArea.h"
#import "LHUtils.h"
#import "NSDictionary+LHDictionary.h"
#import "LHScene.h"
#import "LHConfig.h"
#import "LHGameWorldNode.h"

@implementation LHGravityArea
{
    LHNodeProtocolImpl* _nodeProtocolImp;
    
    BOOL _radial;
    float _force;
    CGPoint _direction;
}

-(void)dealloc{
    LH_SAFE_RELEASE(_nodeProtocolImp);
    
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
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];
        
        //we reset the scale back to 1 because the NodeProtocolImpl is setting the scale to wrong value
        [self setScaleX:1];
        [self setScaleY:1];
        
        CGPoint scl = [dict pointForKey:@"scale"];
        CGSize size = [dict sizeForKey:@"size"];
        size.width *= scl.x;
        size.height *= scl.y;
        self.contentSize = size;
        
        
        _direction = [dict pointForKey:@"direction"];
        _force = [dict floatForKey:@"force"];
        _radial = [dict intForKey:@"type"] == 1;
        
        
#if LH_DEBUG
        CCDrawNode* debug = [CCDrawNode node];
        [self addChild:debug];
        
        
        if(_radial)
        {
            const float k_segments = 32.0f;
            int vertexCount=32;
            const float k_increment = 2.0f * M_PI / k_segments;
            float theta = 0.0f;
            
            CGPoint* vertices = new CGPoint[vertexCount];
            for (int i = 0; i < k_segments; ++i){
                vertices[i] = CGPointMake(size.width*0.5 *cosf(theta), size.width*0.5 *sinf(theta));
                theta += k_increment;
            }
            
            CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(0, 0, 1, 1)];
            CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(0, 0, 1, 0.3)];
            [debug drawPolyWithVerts:vertices
                               count:vertexCount
                           fillColor:fillColor
                         borderWidth:1 borderColor:borderColor];
            
            delete[] vertices;
        }
        else{
            
            CGPoint* vertices = new CGPoint[4];

            vertices[0] = CGPointMake(-size.width*0.5, -size.height*0.5);
            vertices[1] = CGPointMake(size.width*0.5, -size.height*0.5);
            vertices[2] = CGPointMake(size.width*0.5, size.height*0.5);
            vertices[3] = CGPointMake(-size.width*0.5, size.height*0.5);
            
            CCColor* borderColor = [CCColor colorWithCcColor4f:ccc4f(0, 1, 0, 1)];
            CCColor* fillColor = [CCColor colorWithCcColor4f:ccc4f(0, 1, 0, 0.3)];
            
            [debug drawPolyWithVerts:vertices
                               count:4
                           fillColor:fillColor
                         borderWidth:1 borderColor:borderColor];
            
            delete[] vertices;
        }
#endif//LH_DEBUG
        
    }
    
    return self;
}

-(BOOL)isRadial{
    return _radial;
}

-(CGPoint)direction{
    return _direction;
}

-(float)force{
    return _force;
}

-(CGRect)globalRect{
    
    CGPoint pos = [self convertToWorldSpaceAR:CGPointZero];
    
    CGSize size = self.contentSize;
    return CGRectMake(pos.x - size.width*0.5,
                      pos.y - size.height*0.5,
                      size.width,
                      size.height);
}

#if LH_USE_BOX2D
-(void)visit
{
    LHScene* scene = (LHScene*)[self scene];
    LHGameWorldNode* pNode = (LHGameWorldNode*)[scene gameWorldNode];

    b2World* world =  [pNode box2dWorld];
    
    if(!world)return;
    
    CGSize size = self.contentSize;
    float ptm = [scene ptm];
    CGRect rect = [self globalRect];
    
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
        if([self isRadial])
        {
            CGPoint globalPos = [self convertToWorldSpaceAR:CGPointZero];
            
            b2Vec2 b2TouchPosition = [scene metersFromPoint:globalPos];
            b2Vec2 b2BodyPosition = b2Vec2(b->GetPosition().x, b->GetPosition().y);
    
            float maxDistance = [scene metersFromValue:(size.width*0.5)];
            float maxForce = -[self force]/ptm;
            
            CGFloat distance = b2Distance(b2BodyPosition, b2TouchPosition);
            if(distance < maxDistance)
            {
                CGFloat strength = (maxDistance - distance) / maxDistance;
                float force = strength * maxForce;
                CGFloat angle = atan2f(b2BodyPosition.y - b2TouchPosition.y, b2BodyPosition.x - b2TouchPosition.x);

                b->ApplyLinearImpulse(b2Vec2(cosf(angle) * force, sinf(angle) * force), b->GetPosition(), true);
            }
        }
        else{
            b2Vec2 b2BodyPosition = b2Vec2(b->GetPosition().x, b->GetPosition().y);
            
            CGPoint pos = [scene pointFromMeters:b2BodyPosition];
            
            if(CGRectContainsPoint(rect, pos))
            {
                float force = [self force]/ptm;
                
                float directionX = [self direction].x;
                float directionY = [self direction].y;
                b->ApplyLinearImpulse(b2Vec2(directionX * force, directionY * force), b->GetPosition(), true);
            }
        }
	}
    
    [super visit];
}

#else //chipmunk

-(void)visit
{
    CGRect rect = [self globalRect];
    
    LHGameWorldNode* world = [(LHScene*)[self scene] gameWorldNode];
    for(CCNode* node in [world children])
    {
        CCPhysicsBody* body = [node physicsBody];
        if(body && [body type] == CCPhysicsBodyTypeDynamic)
        {
            CGPoint pos = [node convertToWorldSpaceAR:CGPointZero];

            if(CGRectContainsPoint(rect, pos))
            {
                if([self isRadial])
                {
                    CGPoint position = [self position];
                    
                    float maxDistance = self.contentSize.width*0.5f;
                    CGFloat distance = LHDistanceBetweenPoints(position, pos);
                    
                    if(distance < maxDistance)
                    {
                        float maxForce = -[self force]*3;
                        CGFloat strength = (maxDistance - distance) / maxDistance;
                        float force = strength * maxForce;
                        CGFloat angle = atan2f(pos.y - position.y, pos.x - position.x);
                        
                        [body applyImpulse:CGPointMake(cosf(angle) * force,
                                                        sinf(angle) * force)];
                    }
                }
                else{
                    float force = [self force]*3;
                    float directionX = [self direction].x;
                    float directionY = [self direction].y;
                    
                    CGPoint pt = CGPointMake(directionX * force, directionY * force);
                    [body applyImpulse:pt];
                }
            }
        }
    }
    
    [super visit];
}
#endif

#pragma mark LHNodeProtocol Required

LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


@end
