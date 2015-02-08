//
//  CCNode+Transform.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 30/06/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "CCNode+Transform.h"
#import "LHScene.h"
#import "LHUtils.h"

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

-(float) convertToWorldAngle:(float)rotation
{
    CGPoint rot = ccpForAngle(-CC_DEGREES_TO_RADIANS(rotation));    
    CGPoint worldPt = [self convertToWorldSpace:rot];
    CGPoint worldOriginPt = [self convertToWorldSpace:CGPointZero];
    CGPoint worldVec = ccpSub(worldPt, worldOriginPt);
    float ang = -CC_RADIANS_TO_DEGREES(ccpToAngle(worldVec));
    return LHNormalAbsoluteAngleDegrees(ang);
}

-(float) convertToNodeAngle:(float)rotation
{
    CGPoint rot = ccpForAngle(-CC_DEGREES_TO_RADIANS(rotation));
    CGPoint nodePt = [self convertToNodeSpace:rot];
    CGPoint nodeOriginPt = [self convertToNodeSpace:CGPointZero];
    CGPoint nodeVec = ccpSub(nodePt, nodeOriginPt);
    float ang = -CC_RADIANS_TO_DEGREES(ccpToAngle(nodeVec));
    return LHNormalAbsoluteAngleDegrees(ang);
}


-(CGPoint)unitForGlobalPosition:(CGPoint)globalpt
{
    NSPoint local = [self convertToNodeSpace:globalpt];
    
    NSSize sizer = [self contentSize];
    
    float centerPointX = sizer.width*0.5;
    float centerPointY = sizer.height*0.5;
    
    local.x += centerPointX;
    local.y += centerPointY;
    
    return  NSMakePoint(local.x/sizer.width, local.y/sizer.height);
}

-(void)setAnchorByKeepingPosition:(CGPoint)newAnchor
{
    CGPoint prevAnchor = [self anchorPoint];
    CGPoint prevPos = [self position];

    prevPos = [[self parent] convertToWorldSpace:prevPos];

    CGPoint newPos = ccp(prevPos.x + (newAnchor.x - prevAnchor.x)*self.contentSize.width,
                         prevPos.y + (newAnchor.y - prevAnchor.y)*self.contentSize.height);

    [self setAnchorPoint:newAnchor];
    
    newPos = [[self parent] convertToNodeSpace:newPos];
    [self setPosition:newPos];
}

@end
