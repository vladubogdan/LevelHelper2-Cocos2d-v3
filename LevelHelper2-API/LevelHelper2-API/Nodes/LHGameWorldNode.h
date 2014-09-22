
#import "cocos2d.h"
#import "LHConfig.h"
#import "LHNodeProtocol.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
#include "Box2d/Box2D.h"

class LHBox2dWorld : public b2World
{
public:
    
    LHBox2dWorld(const b2Vec2& gravity, void* sceneObj):b2World(gravity),_scene(sceneObj){}
    virtual ~LHBox2dWorld(){_scene = NULL;}
    
    void* _scene;
};


#endif

@interface LHGameWorldNode : CCDrawNode <LHNodeProtocol>

#ifdef __cplusplus
-(b2World*)box2dWorld;

-(void)setBox2dFixedTimeStep:(float)val;
-(void)setBox2dMinimumTimeStep:(float)val;
-(void)setBox2dVelocityIterations:(int)val;
-(void)setBox2dPositionIterations:(int)val;
-(void)setBox2dMaxSteps:(int)val;

#endif

#else//CHIPMUNK
@interface LHGameWorldNode : CCPhysicsNode <LHNodeProtocol>
#endif


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(CCNode*)prnt;

- (instancetype)initWithDictionary:(NSDictionary*)dict
                                parent:(CCNode*)prnt;

-(void)setDebugDraw:(BOOL)val;
-(BOOL)debugDraw;

-(CGPoint)gravity;
-(void)setGravity:(CGPoint)val;

@end
