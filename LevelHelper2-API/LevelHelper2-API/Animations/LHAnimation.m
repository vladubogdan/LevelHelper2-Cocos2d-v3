//
//  LHAnimation.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 22/04/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHAnimation.h"

//#import "LHNode.h"
#import "LHScene.h"
#import "LHSprite.h"
#import "LHCamera.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"

#import "LHAnimationProperty.h"
#import "LHFrame.h"

#import "LHPositionProperty.h"
#import "LHChildrenPositionsProperty.h"
#import "LHPositionFrame.h"

#import "LHRotationProperty.h"
#import "LHChildrenRotationsProperty.h"
#import "LHRotationFrame.h"

#import "LHScaleProperty.h"
#import "LHChildrenScalesProperty.h"
#import "LHScaleFrame.h"

#import "LHOpacityProperty.h"
#import "LHChildrenOpacitiesProperty.h"
#import "LHOpacityFrame.h"

#import "LHSpriteFrameProperty.h"
#import "LHSpriteFrame.h"

#import "LHCameraActivateProperty.h"

#import "LHRootBoneProperty.h"
#import "LHBoneFrame.h"
#import "LHBone.h"
#import "LHBoneNodes.h"

#import "LHGameWorldNode.h"
#import "LHBackUINode.h"
#import "LHUINode.h"

@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(CGPoint)designOffset;
-(CGSize)designResolutionSize;
@end

@implementation LHAnimation
{
    NSMutableArray* _properties;
    int _repetitions;
    float _totalFrames;
    NSString* _name;
    BOOL _active;
    float _fps;
    
    BOOL animating;
    int currentRepetition;
    float currentTime;
    float previousTime;
    
    __weak LHScene* _scene;
    __weak CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* node;
    
    int     beginFrameIdx;
}

-(void)dealloc{
    node = nil;
    _scene = nil;
    
    LH_SAFE_RELEASE(_properties);
    LH_SUPER_DEALLOC();
}

+(instancetype)animationWithDictionary:(NSDictionary*)dict node:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)n{
    return LH_AUTORELEASED([[self alloc] initAnimationWithDictionary:dict node:n]);
}

-(instancetype)initAnimationWithDictionary:(NSDictionary*)dict node:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)n{
    if(self = [super init]){
        
        node = n;
        
        _repetitions = [dict intForKey:@"repetitions"];
        _totalFrames = [dict floatForKey:@"totalFrames"];
        _name = [[NSString alloc] initWithString:[dict objectForKey:@"name"]];
        _active = [dict intForKey:@"active"];
        _fps = [dict floatForKey:@"fps"];
        
        _properties = [[NSMutableArray alloc] init];
        NSDictionary* propDictInfo = [dict objectForKey:@"properties"];
        for(NSDictionary* apInf in [propDictInfo objectEnumerator])
        {
            LHAnimationProperty* prop = [LHAnimationProperty animationPropertyWithDictionary:apInf
                                                                                   animation:self];
            
            [_properties addObject:prop];
        }
        
        if(_active){
            [self restart];
            [self setAnimating:YES];
        }
        
        currentRepetition = 0;
    }
    return self;
}

-(id<LHNodeAnimationProtocol, LHNodeProtocol>)node{
    return node;
}

-(NSString*)name{
    return _name;
}

-(BOOL)isActive{
    return _active;
}

-(void)setActive:(BOOL)val{
    _active = val;
    if(_active){
        [node setActiveAnimation:self];
    }
    else{
        [node setActiveAnimation:nil];
    }
}

-(float)totalTime{
    return _totalFrames*(1.0f/_fps);
}


-(float)currentFrame{
    return currentTime/(1.0f/_fps);
}
-(void)setCurrentFrame:(float)val{
    [self updateTimeWithValue:(val)*(1.0f/_fps)];
}

-(void)resetOneShotFrames{
    [self resetOneShotFramesStartingFromFrameNumber:0];
}

-(void)resetOneShotFramesStartingFromFrameNumber:(NSInteger)frameNumber{
    for(LHAnimationProperty* prop in _properties)
    {
        NSArray* frames = [prop keyFrames];
        for(LHFrame* frm in frames){
            if([frm frameNumber] >= frameNumber){
                [frm setWasShot:NO];
            }
        }
    }
}
-(void)setAnimating:(bool)val{
    animating = val;
}

-(bool)animating{
    return animating;
}

-(void)restart{
    [self resetOneShotFrames];
    currentRepetition = 0;
    currentTime = 0;
    beginFrameIdx = 0;
}

-(void)updateTimeWithDelta:(float)delta{
    if(animating)
        [self setCurrentTime:[self currentTime] + delta];
}
-(void)updateTimeWithValue:(float)val{
    [self setCurrentTime:val];
}

-(int)repetitions{
    return _repetitions;
}

-(void)setCurrentTime:(float)val{
    
    currentTime = val;
    
    [self animateNodeToTime:currentTime];
    
    if(currentTime > [self totalTime] && animating)
    {
        if(currentRepetition < [self repetitions] + 1)//dont grow this beyound num of repetitions as
            ++currentRepetition;
        
        
        if(![self didFinishAllRepetitions]){
            currentTime = 0.0f;
            [self resetOneShotFrames];
            [(LHScene*)[node scene] didFinishedRepetitionOnAnimation:self];
        }
        else{
            [node setActiveAnimation:nil];
            [(LHScene*)[node scene] didFinishedPlayingAnimation:self];
        }
    }
    previousTime = currentTime;
}

-(float)currentTime{
    return currentTime;
}
-(BOOL)didFinishAllRepetitions{
    if([self repetitions] == 0)
        return NO;
    
    if(animating && currentRepetition >= [self repetitions]){
        return true;
    }
    return false;
}

-(void)animateNodeToTime:(float)time
{
    if([self didFinishAllRepetitions]){
        return;
    }
    
    if(node)
    {
        if(time > [self totalTime]){
            time = [self totalTime];
        }
     
        for(LHAnimationProperty* prop in [_properties reverseObjectEnumerator])
        {
            for(LHAnimationProperty* subprop in [prop allSubproperties]){
                [self updateNodeWithAnimationProperty:subprop time:time];
            }
            [self updateNodeWithAnimationProperty:prop time:time];
        }
    }
}

-(void)updateNodeWithAnimationProperty:(LHAnimationProperty*)prop
                                  time:(float)time
{
    NSArray* frames = [prop keyFrames];
    
    LHFrame* beginFrm = nil;
    LHFrame* endFrm = nil;
    
    for(LHFrame* frm in frames)
    {
        if([frm frameNumber]*(1.0f/_fps) <= time){
            beginFrm = frm;
        }
        
        if([frm frameNumber]*(1.0f/_fps) > time){
            endFrm = frm;
            break;//exit for
        }
    }

    
    //possible optimisation - needs more testing
//    LHFrame* beginFrm = nil;
//    LHFrame* endFrm = nil;
//    
//    if(beginFrameIdx >= [frames count]-1){
//        beginFrameIdx = 0;
//    }
//    
//    for(int i = beginFrameIdx; i < [frames count];++i)
//    {
//        LHFrame* frm = [frames objectAtIndex:i];
//        
//        LHFrame* endFrame = nil;
//        if(i+1 < [frames count]){
//            endFrame = [frames objectAtIndex:i+1];
//        }
//        
//        if([frm frameNumber]*(1.0f/_fps) <= time){
//            beginFrm = frm;
//            beginFrameIdx = i;
//        }
//        
//        if(endFrame && [endFrame frameNumber]*(1.0f/_fps) > time){
//            endFrm = endFrame;
//            break;//exit for
//        }
//        
//        if([frm frameNumber]*(1.0f/_fps) > time){
//            endFrm = frm;
//            break;//exit for
//        }
//    }
//    
//    if(!beginFrm)
//    {
//        int i = 0;
//        for(LHFrame* frm in frames)
//        {
//            if([frm frameNumber]*(1.0f/_fps) <= time){
//                beginFrm = frm;
//                beginFrameIdx = i;
//            }
//            
//            if([frm frameNumber]*(1.0f/_fps) > time){
//                endFrm = frm;
//                break;//exit for
//            }
//            ++i;
//        }
//    }
    
    
    __weak CCNode<LHNodeAnimationProtocol, LHNodeProtocol>* animNode = node;
    if([prop isSubproperty] && [prop subpropertyNode]){
        animNode = [prop subpropertyNode];
    }
    

    if([prop isKindOfClass:[LHChildrenPositionsProperty class]])
    {
        [self animateNodeChildrenPositionsToTime:time
                                      beginFrame:beginFrm
                                        endFrame:endFrm
                                            node:animNode
                                        property:prop];
    }
    else if([prop isKindOfClass:[LHPositionProperty class]])
    {
        [self animateNodePositionToTime:time
                             beginFrame:beginFrm
                               endFrame:endFrm
                                   node:animNode];
    }
    ////////////////////////////////////////////////////////////////////
    else if([prop isKindOfClass:[LHRootBoneProperty class]])
    {
         [self animateRootBonesToTime:time
                           beginFrame:beginFrm
                             endFrame:endFrm
                                 node:animNode];
    }
    
    ////////////////////////////////////////////////////////////////////
    else if([prop isKindOfClass:[LHChildrenRotationsProperty class]])
    {
        [self animateNodeChildrenRotationsToTime:time
                                      beginFrame:beginFrm
                                        endFrame:endFrm
                                            node:animNode
                                        property:prop
         ];
    }
    ////////////////////////////////////////////////////////////////////
    
    else if([prop isKindOfClass:[LHRotationProperty class]])
    {
        [self animateNodeRotationToTime:time
                             beginFrame:beginFrm
                               endFrame:endFrm
                                   node:animNode];
    }
    else if([prop isKindOfClass:[LHChildrenScalesProperty class]])
    {
        [self animateNodeChildrenScalesToTime:time
                                   beginFrame:beginFrm
                                     endFrame:endFrm
                                         node:animNode
                                     property:prop];
    }
    else if([prop isKindOfClass:[LHScaleProperty class]])
    {
        [self animateNodeScaleToTime:time
                          beginFrame:beginFrm
                            endFrame:endFrm
                                node:animNode];
    }
    else if([prop isKindOfClass:[LHChildrenOpacitiesProperty class]])
    {
        [self animateNodeChildrenOpacitiesToTime:time
                                      beginFrame:beginFrm
                                        endFrame:endFrm
                                            node:animNode
                                        property:prop];
    }
    else if([prop isKindOfClass:[LHOpacityProperty class]])
    {
        [self animateNodeOpacityToTime:time
                            beginFrame:beginFrm
                              endFrame:endFrm
                                  node:animNode];
    }
    else if([prop isKindOfClass:[LHSpriteFrameProperty class]])
    {
        [self animateSpriteFrameChangeWithFrame:beginFrm
                                      forSprite:animNode];
    }
    else if([prop isKindOfClass:[LHCameraActivateProperty class]] && [node isKindOfClass:[LHCamera class]])
    {
        [self animateCameraActivationWithFrame:beginFrm];
    }
}

-(LHScene*)scene{
    if(!_scene){
        _scene = (LHScene*)[node scene];
    }
    return _scene;
}

-(CGPoint)convertFramePosition:(CGPoint)newPos
                       forNode:(CCNode*)animNode
{
    if([animNode isKindOfClass:[LHCamera class]]){
        CGSize winSize = [[self scene] designResolutionSize];
        return CGPointMake(winSize.width*0.5  - newPos.x,
                           -winSize.height*0.5 - newPos.y);
    }
    
    
    LHScene* scene = [self scene];
    CGPoint offset = [scene designOffset];

    CCNode* p = [animNode parent];
    if([animNode parent] == nil ||
       [animNode parent] == scene ||
       [animNode parent] == [scene gameWorldNode]||
       [animNode parent] == [scene backUiNode]||
       [animNode parent] == [scene uiNode])
    {
        newPos.x += offset.x;
        newPos.y += offset.y;
        
        newPos.y += scene.designResolutionSize.height;// p.contentSize.height;
    }
    else{
        CGSize content = [p contentSizeInPoints];
    
        newPos.x += content.width*0.5;
        newPos.y += content.height*0.5;
    }
    
    return newPos;
}

-(void)animateNodeChildrenPositionsToTime:(float)time
                               beginFrame:(LHFrame*)beginFrm
                                 endFrame:(LHFrame*)endFrm
                                     node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                                 property:(LHAnimationProperty*)prop
{
    //here we handle positions
    LHPositionFrame* beginFrame = (LHPositionFrame*)beginFrm;
    LHPositionFrame* endFrame   = (LHPositionFrame*)endFrm;

    NSArray* children = [animNode childrenOfType:[CCNode class]];

    if(beginFrame && endFrame)
    {
        double beginTime = [beginFrame frameNumber]*(1.0/_fps);
        double endTime = [endFrame frameNumber]*(1.0/_fps);
        
        double framesTimeDistance = endTime - beginTime;
        double timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        for(CCNode<LHNodeProtocol, LHNodeAnimationProtocol>* child in children){
            if(![prop subpropertyForUUID:[child uuid]])
            {
                CGPoint beginPosition   = [beginFrame positionForUUID:[child uuid]];
                CGPoint endPosition     = [endFrame positionForUUID:[child uuid]];
                
                //lets calculate the new node position based on the start - end and unit time
                double newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
                double newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;
                
                CGPoint newPos = CGPointMake(newX, -newY);
                newPos = [self convertFramePosition:newPos
                                            forNode:child];
                [child setPosition:newPos];
            }
        }
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set positions based on this frame
        for(CCNode<LHNodeProtocol, LHNodeAnimationProtocol>* child in children){
            if(![prop subpropertyForUUID:[child uuid]])
            {
                CGPoint beginPosition = [beginFrame positionForUUID:[child uuid]];
                
                CGPoint newPos = CGPointMake(beginPosition.x, -beginPosition.y);
                
                newPos = [self convertFramePosition:newPos
                                            forNode:child];
                
                [child setPosition:newPos];
            }
        }
    }
}


-(void)animateNodePositionToTime:(float)time
                      beginFrame:(LHFrame*)beginFrm
                        endFrame:(LHFrame*)endFrm
                            node:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)animNode
{
    //here we handle positions
    LHPositionFrame* beginFrame = (LHPositionFrame*)beginFrm;
    LHPositionFrame* endFrame   = (LHPositionFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        double beginTime = [beginFrame frameNumber]*(1.0/_fps);
        double endTime = [endFrame frameNumber]*(1.0/_fps);
        
        double framesTimeDistance = endTime - beginTime;
        double timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        CGPoint beginPosition = [beginFrame positionForUUID:[animNode uuid]];
        CGPoint endPosition = [endFrame positionForUUID:[animNode uuid]];
        
        //lets calculate the new node position based on the start - end and unit time
        double newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
        double newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;

        CGPoint newPos = CGPointMake(newX, -newY);
        newPos = [self convertFramePosition:newPos
                                    forNode:animNode];

        [animNode setPosition:newPos];
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set positions based on this frame
        CGPoint beginPosition = [beginFrame positionForUUID:[animNode uuid]];
        
        CGPoint newPos = CGPointMake(beginPosition.x, -beginPosition.y);
        
        newPos = [self convertFramePosition:newPos
                                    forNode:animNode];
        
        [animNode setPosition:newPos];
    }
}

-(void)animateRootBonesToTime:(float)time
                   beginFrame:(LHFrame*)beginFrm
                     endFrame:(LHFrame*)endFrm
                         node:(CCNode<LHNodeAnimationProtocol, LHNodeProtocol>*)nd
{
    LHBoneFrame* beginFrame    = (LHBoneFrame*)beginFrm;
    LHBoneFrame* endFrame      = (LHBoneFrame*)endFrm;
    
    if(![beginFrame isKindOfClass:[LHBoneFrame class]] ||
       ![endFrame isKindOfClass:[LHBoneFrame class]])
        return;
    
    LHBone* rootBone = (LHBone*)nd;
    
    if([rootBone isKindOfClass:[LHBone class]] && [rootBone isRoot])
    {
        NSArray* allBones = [rootBone childrenOfType:[LHBone class]];

        if(beginFrame && endFrame && beginFrm != endFrm)
        {
            double beginTime = [beginFrame frameNumber]*(1.0/_fps);
            double endTime = [endFrame frameNumber]*(1.0/_fps);
            
            double framesTimeDistance = endTime - beginTime;
            double timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
            LHBoneFrameInfo* beginFrmInfo = [beginFrame boneFrameInfoForBoneNamed:@"__rootBone__"];
            LHBoneFrameInfo* endFrmInfo = [endFrame boneFrameInfoForBoneNamed:@"__rootBone__"];
            
            if(beginFrmInfo && endFrmInfo)
            {
                float beginRotation =  [beginFrmInfo rotation];
                float endRotation = [endFrmInfo rotation];
                
                float shortest_angle = fmodf( (fmodf( (endRotation - beginRotation), 360.0f) + 540.0f), 360.0) - 180.0f;
                //lets calculate the new value based on the start - end and unit time
                float newRotation = beginRotation + shortest_angle*timeUnit;
                
                CGPoint beginPosition = [beginFrmInfo position];
                CGPoint endPosition = [endFrmInfo position];
                
                //lets calculate the new node position based on the start - end and unit time
                double newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
                double newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;
                
                CGPoint newPos = CGPointMake(newX, -newY);

                newPos = [self convertFramePosition:newPos
                                            forNode:rootBone];
                
                [rootBone setRotation:newRotation];
                [rootBone setPosition:newPos];
            }
            
            for(LHBone* b in allBones)
            {
                beginFrmInfo = [beginFrame boneFrameInfoForBoneNamed:[b name]];
                endFrmInfo = [endFrame boneFrameInfoForBoneNamed:[b name]];
                
                if(beginFrmInfo && endFrmInfo)
                {
                    
                    float beginRotation =  [beginFrmInfo rotation];
                    float endRotation = [endFrmInfo rotation];
                    
                    float shortest_angle = fmodf( (fmodf( (endRotation - beginRotation), 360.0f) + 540.0f), 360.0) - 180.0f;
                    //lets calculate the new value based on the start - end and unit time
                    float newRotation = beginRotation + shortest_angle*timeUnit;
                    
                    
                    [b setRotation:newRotation];
                    
                    if(![b rigid])
                    {
                        CGPoint beginPosition = [beginFrmInfo position];
                        CGPoint endPosition = [endFrmInfo position];
                        
                        //lets calculate the new node position based on the start - end and unit time
                        double newX = beginPosition.x + (endPosition.x - beginPosition.x)*timeUnit;
                        double newY = beginPosition.y + (endPosition.y - beginPosition.y)*timeUnit;
                        
                        CGPoint newPos = CGPointMake(newX, -newY);
                        
                        newPos = [self convertFramePosition:newPos
                                                    forNode:b];
                        
                        [b setPosition:newPos];
                    }
                }
            }
        }
        else if(beginFrame && !endFrame){
            
            LHBoneFrameInfo* beginFrmInfo = [beginFrame boneFrameInfoForBoneNamed:@"__rootBone__"];
            
            if(beginFrmInfo)
            {
                CGPoint beginPosition = [beginFrmInfo position];
                CGPoint newPos = CGPointMake(beginPosition.x, -beginPosition.y);
                
                newPos = [self convertFramePosition:newPos
                                            forNode:rootBone];
                
                float beginRot =  [beginFrmInfo rotation];
                
                [rootBone setRotation:beginRot];
                [rootBone setPosition:newPos];
            }
            
            for(LHBone* b in allBones)
            {
                beginFrmInfo = [beginFrame boneFrameInfoForBoneNamed:[b name]];
                
                if(beginFrmInfo)
                {
                    float newRotation = [beginFrmInfo rotation];
                    [b setRotation:newRotation];
                    
                    if(![b rigid])
                    {
                        CGPoint beginPosition = [beginFrmInfo position];
                        CGPoint newPos = CGPointMake(beginPosition.x, -beginPosition.y);
                        
                        newPos = [self convertFramePosition:newPos
                                                    forNode:b];
                        
                        [b setPosition:newPos];
                    }
                }
            }
        }
    }
}


-(void)animateNodeChildrenRotationsToTime:(float)time
                               beginFrame:(LHFrame*)beginFrm
                                 endFrame:(LHFrame*)endFrm
                                     node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                                 property:(LHAnimationProperty*)prop
{
    LHRotationFrame* beginFrame    = (LHRotationFrame*)beginFrm;
    LHRotationFrame* endFrame      = (LHRotationFrame*)endFrm;
    
    NSArray* children = [animNode childrenOfType:[CCNode class]];
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                float beginRotation = [beginFrame rotationForUUID:[child uuid]];
                float endRotation   = [endFrame rotationForUUID:[child uuid]];
                
                float shortest_angle = fmodf( (fmodf( (endRotation - beginRotation), 360.0f) + 540.0f), 360.0) - 180.0f;
                
                //lets calculate the new value based on the start - end and unit time
                float newRotation = beginRotation + shortest_angle*timeUnit;
                
                [child setRotation:newRotation];
            }
        }
    }
    else if(beginFrame)
    {
        for(CCNode<LHNodeProtocol, LHNodeAnimationProtocol>* child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                //we only have begin frame so lets set value based on this frame
                float beginRotation = [beginFrame rotationForUUID:[child uuid]];
                
                [child setRotation:beginRotation];
            }
        }
    }
}


-(void)animateNodeRotationToTime:(float)time
                      beginFrame:(LHFrame*)beginFrm
                        endFrame:(LHFrame*)endFrm
                            node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    LHRotationFrame* beginFrame    = (LHRotationFrame*)beginFrm;
    LHRotationFrame* endFrame      = (LHRotationFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        float beginRotation = [beginFrame rotationForUUID:[animNode uuid]];
        float endRotation   = [endFrame rotationForUUID:[animNode uuid]];
        
        float shortest_angle = fmodf( (fmodf( (endRotation - beginRotation), 360.0f) + 540.0f), 360.0) - 180.0f;
        
        //lets calculate the new value based on the start - end and unit time
        float newRotation = beginRotation + shortest_angle*timeUnit;
        
        [animNode setRotation:newRotation];
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set value based on this frame
        float beginRotation = [beginFrame rotationForUUID:[animNode uuid]];
        [animNode setRotation:beginRotation];
    }
}

-(void)animateNodeChildrenScalesToTime:(float)time
                            beginFrame:(LHFrame*)beginFrm
                              endFrame:(LHFrame*)endFrm
                                  node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                              property:(LHAnimationProperty*)prop
{
    //here we handle scale
    LHScaleFrame* beginFrame    = (LHScaleFrame*)beginFrm;
    LHScaleFrame* endFrame      = (LHScaleFrame*)endFrm;
    
    NSArray* children = [animNode childrenOfType:[CCNode class]];
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                CGSize beginScale = [beginFrame scaleForUUID:[child uuid]];
                CGSize endScale = [endFrame scaleForUUID:[child uuid]];
                
                //lets calculate the new node scale based on the start - end and unit time
                float newX = beginScale.width + (endScale.width - beginScale.width)*timeUnit;
                float newY = beginScale.height + (endScale.height - beginScale.height)*timeUnit;

                
                [child setScaleX:newX];
                [child setScaleY:newY];
            }
        }
    }
    else if(beginFrame)
    {
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                CGSize beginScale = [beginFrame scaleForUUID:[child uuid]];
                [child setScaleX:beginScale.width];
                [child setScaleY:beginScale.height];
            }
        }
    }
}

-(void)animateNodeScaleToTime:(float)time
                   beginFrame:(LHFrame*)beginFrm
                     endFrame:(LHFrame*)endFrm
                         node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    //here we handle scale
    LHScaleFrame* beginFrame    = (LHScaleFrame*)beginFrm;
    LHScaleFrame* endFrame      = (LHScaleFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        CGSize beginScale = [beginFrame scaleForUUID:[animNode uuid]];
        CGSize endScale = [endFrame scaleForUUID:[animNode uuid]];
        
        //lets calculate the new node scale based on the start - end and unit time
        float newX = beginScale.width + (endScale.width - beginScale.width)*timeUnit;
        float newY = beginScale.height + (endScale.height - beginScale.height)*timeUnit;
        
        [animNode setScaleX:newX];
        [animNode setScaleY:newY];
    }
    else if(beginFrame)
    {
        CGSize beginScale = [beginFrame scaleForUUID:[animNode uuid]];
        [animNode setScaleX:beginScale.width];
        [animNode setScaleY:beginScale.height];
    }
}


-(void)animateNodeChildrenOpacitiesToTime:(float)time
                               beginFrame:(LHFrame*)beginFrm
                                 endFrame:(LHFrame*)endFrm
                                     node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
                                 property:(LHAnimationProperty*)prop
{
    //here we handle sprites opacity
    LHOpacityFrame* beginFrame    = (LHOpacityFrame*)beginFrm;
    LHOpacityFrame* endFrame      = (LHOpacityFrame*)endFrm;
    
    NSArray* children = [node childrenOfType:[CCNode class]];
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                float beginValue = [beginFrame opacityForUUID:[child uuid]];
                float endValue = [endFrame opacityForUUID:[child uuid]];
                
                //lets calculate the new value based on the start - end and unit time
                float newValue = beginValue + (endValue - beginValue)*timeUnit;
                
                if([child respondsToSelector:@selector(setCascadeOpacityEnabled:)]){
                    ((CCNode*)child).cascadeOpacityEnabled = NO;
                }

                [(CCNode*)child setOpacity:newValue/255.0f];
            }
        }
    }
    else if(beginFrame)
    {
        for(id<LHNodeProtocol, LHNodeAnimationProtocol> child in children){
            if([child respondsToSelector:@selector(uuid)] &&
               ![prop subpropertyForUUID:[child uuid]])
            {
                //we only have begin frame so lets set value based on this frame
                float beginValue = [beginFrame opacityForUUID:[child uuid]];
                
                if([child respondsToSelector:@selector(setCascadeOpacityEnabled:)]){
                    ((CCNode*)child).cascadeOpacityEnabled = NO;
                }
                
                [(CCNode*)child setOpacity:beginValue/255.0f];
            }
        }
    }
}


-(void)animateNodeOpacityToTime:(float)time
                     beginFrame:(LHFrame*)beginFrm
                       endFrame:(LHFrame*)endFrm
                           node:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    //here we handle sprites opacity
    LHOpacityFrame* beginFrame    = (LHOpacityFrame*)beginFrm;
    LHOpacityFrame* endFrame      = (LHOpacityFrame*)endFrm;
    
    if(beginFrame && endFrame)
    {
        float beginTime = [beginFrame frameNumber]*(1.0f/_fps);
        float endTime = [endFrame frameNumber]*(1.0f/_fps);
        
        float framesTimeDistance = endTime - beginTime;
        float timeUnit = (time-beginTime)/framesTimeDistance; //a value between 0 and 1
        
        float beginValue = [beginFrame opacityForUUID:[animNode uuid]];
        float endValue = [endFrame opacityForUUID:[animNode uuid]];
        
        //lets calculate the new value based on the start - end and unit time
        float newValue = beginValue + (endValue - beginValue)*timeUnit;
        
        [animNode setOpacity:newValue/255.0f];
    }
    else if(beginFrame)
    {
        //we only have begin frame so lets set value based on this frame
        float beginValue = [beginFrame opacityForUUID:[animNode uuid]];
        
        [animNode setOpacity:beginValue/255.0f];
    }
}

-(void)animateSpriteFrameChangeWithFrame:(LHFrame*)beginFrm
                               forSprite:(id<LHNodeAnimationProtocol, LHNodeProtocol>)animNode
{
    LHSprite* sprite = [animNode isKindOfClass:[LHSprite class]] ? (LHSprite*)animNode : nil;
    if(!sprite)return;
    
    LHSpriteFrame* beginFrame = (LHSpriteFrame*)beginFrm;
    if(beginFrame && sprite)
    {
        if(animating)
        {
            if(![beginFrame wasShot])
            {
                [sprite setSpriteFrameWithName:[beginFrame spriteFrameName]];
                [beginFrame setWasShot:YES];
            }
        }
        else{
            [sprite setSpriteFrameWithName:[beginFrame spriteFrameName]];
        }
    }
}

-(void)animateCameraActivationWithFrame:(LHFrame*)beginFrm
{
    LHFrame* beginFrame = (LHFrame*)beginFrm;
    if(beginFrame)
    {
        if(animating)
        {
            if(![beginFrame wasShot])
            {
                [(LHCamera*)node setActive:YES];
                [beginFrame setWasShot:YES];
            }
        }
        else{
            [(LHCamera*)node setActive:YES];
        }
    }
}

@end
