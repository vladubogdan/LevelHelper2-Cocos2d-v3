
#import "cocos2d.h"
#import "LHConfig.h"
#import "LHNodeProtocol.h"

#if LH_USE_BOX2D
#ifdef __cplusplus
class b2World;
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
