//
//  LHBoneFrame.h
//  LevelHelper2-API
//
//  Created by Bogdan Vladu on 7/10/13.
//  Copyright (c) 2013 Bogdan Vladu. All rights reserved.
//

#import "LHFrame.h"
@class LHNode;
@class LHBone;
@class LHBoneConnection;

@interface LHBoneFrameInfo : NSObject
{
    float       rotation;
    NSPoint     position;
}

-(float)rotation;
-(void)setRotation:(float)rot;
-(NSPoint)position;
-(void)setPosition:(NSPoint)pt;

@end

@interface LHBoneFrame : LHFrame

-(LHBoneFrameInfo*)boneFrameInfoForBoneNamed:(NSString*)nm;

@end
