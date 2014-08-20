//
//  CCNode+Transform.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "CCNode+Transform.h"
#import "LHScene.h"

@implementation CCNode (Transform)

-(CGPoint)convertToWorldScale:(CGPoint)nodeScale{
    for (CCNode *p = _parent; p != nil && ![p isKindOfClass:[LHScene class]]; p = p.parent)
    {
        CGPoint scalePt = CGPointMake(p.scaleX, p.scaleY);
        nodeScale.x *= scalePt.x;
        nodeScale.y *= scalePt.y;
    }
    return nodeScale;
}
-(CGPoint)convertToNodeScale:(CGPoint)worldScale{
    for (CCNode *p = _parent; p != nil && ![p isKindOfClass:[LHScene class]]; p = p.parent)
    {
        CGPoint scalePt = CGPointMake(p.scaleX, p.scaleY);
        worldScale.x /= scalePt.x;
        worldScale.y /= scalePt.y;
    }
    return worldScale;
}


-(float)globalAngleFromLocalAngle:(float)la{
    CCNode* prnt = [self parent];
    while(prnt && ![prnt isKindOfClass:[CCScene class]]){
        la += [prnt rotation];
        prnt = [prnt parent];
    }
    return la;
}

-(float)localAngleFromGlobalAngle:(float)ga{
    CCNode* prnt = [self parent];
    while(prnt && ![prnt isKindOfClass:[CCScene class]]){
        ga -= [prnt rotation];
        prnt = [prnt parent];
    }
    return ga;
}


@end
