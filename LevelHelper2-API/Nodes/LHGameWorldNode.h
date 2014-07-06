
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
#endif

#else//CHIPMUNK
@interface LHGameWorldNode : CCPhysicsNode <LHNodeProtocol>
#endif


+ (instancetype)gameWorldNodeWithDictionary:(NSDictionary*)dict
                                     parent:(CCNode*)prnt;


-(void)setDebugDraw:(BOOL)val;
-(BOOL)debugDraw;

-(CGPoint)gravity;
-(void)setGravity:(CGPoint)val;

@end
