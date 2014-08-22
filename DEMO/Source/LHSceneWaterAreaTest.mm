//
//  LHSceneWaterAreaTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneWaterAreaTest.h"
#import "LevelHelper2-API/LHConfig.h"
#import "LevelHelper2-API/LHUtils.h"

@implementation LHSceneWaterAreaTest
{
#if LH_USE_BOX2D
    b2MouseJoint* mouseJoint;
#endif
}
+ (LHSceneDemo *)scene
{
	return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/waterArea.lhplist"];
}

-(void)dealloc{
    [self destroyMouseJoint];
    
    LH_SUPER_DEALLOC();
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    
    /*
     INIT YOUR CONTENT HERE
     */
    
#if LH_USE_BOX2D
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Water Area Example.\nObjects will float based on the water density property and physics density property of each object.\nIf water has a velocity value, objects will also be pushed in the direction of the velocity.\nTurbulence of the water can be bigger or smaller.\nSplashes can be disabled.\nWaves can be longer or shorter.\n\nDrag each object and throw it in the air to make a splash."
                                         fontName:@"Arial"
                                         fontSize:20];
    
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Water Area Example.\nSorry, this demo is not completely available using Chipmunk. Try Box2d instead.\n"
                                         fontName:@"Arial"
                                         fontSize:20];
    
#endif
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5+100)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    
    return self;
}

#ifdef __CC_PLATFORM_IOS

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    //without this touch began is not called
    CGPoint touchLocation = [touch locationInNode:self];
    
    [self createMouseJointForTouchLocation:touchLocation];


    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:self];
    
    [self setTargetOnMouseJoint:touchLocation];

    //dont forget to call super
    [super touchMoved:touch withEvent:event];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    [self destroyMouseJoint];
    
    [super touchCancelled:touch withEvent:event];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [self destroyMouseJoint];
    
    [super touchEnded:touch withEvent:event];
}
#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint touchLocation = [theEvent locationInNode:self];
    [self createMouseJointForTouchLocation:touchLocation];
    [super mouseDown:theEvent];
}
-(void)mouseDragged:(NSEvent *)theEvent{
    
    CGPoint touchLocation = [theEvent locationInNode:self];
    [self setTargetOnMouseJoint:touchLocation];
    
    [super mouseDragged:theEvent];
}
-(void)mouseUp:(NSEvent *)theEvent{
    
    [self destroyMouseJoint];
    [super mouseUp:theEvent];
}

#endif



-(void)createMouseJointForTouchLocation:(CGPoint)point
{
#if LH_USE_BOX2D
    b2Body* ourBody = NULL;
    
    LHSprite* mouseJointDummySpr = (LHSprite*)[self childNodeWithName:@"dummyBodyForMouseJoint"];
    b2Body* mouseJointBody = [mouseJointDummySpr box2dBody];
    
    if(!mouseJointBody)return;
    
    b2Vec2 pointToTest = [self metersFromPoint:point];
    
    for (b2Body* b = [self box2dWorld]->GetBodyList(); b; b = b->GetNext())
    {
        if(b != mouseJointBody)
        {
            b2Fixture* stFix = b->GetFixtureList();
            while(stFix != 0){
                if(stFix->TestPoint(pointToTest)){
                    if(ourBody == NULL)
                    {
                        ourBody = b;
                    }
                    else{
                        LHNode* ourNode = (LHNode*)LH_ID_BRIDGE_CAST(ourBody->GetUserData());
                        LHNode* bNode   = (LHNode*)LH_ID_BRIDGE_CAST(b->GetUserData());
                        
                        if(bNode.zOrder > ourNode.zOrder){
                            ourBody = b;
                        }
                    }
                }
                stFix = stFix->GetNext();
            }
        }
    }
    
    if(ourBody == NULL)
        return;
    
    
    b2MouseJointDef md;
    md.bodyA = mouseJointBody;
    md.bodyB = ourBody;
    b2Vec2 locationWorld = pointToTest;
    
    md.target = locationWorld;
    md.collideConnected = true;
    md.maxForce = 1000.0f * ourBody->GetMass();
    ourBody->SetAwake(true);
    
    if(mouseJoint){
        [self box2dWorld]->DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
    mouseJoint = (b2MouseJoint *)[self box2dWorld]->CreateJoint(&md);
#endif
}

-(void) setTargetOnMouseJoint:(CGPoint)point
{
#if LH_USE_BOX2D
    if(mouseJoint == 0)
        return;
    b2Vec2 locationWorld = b2Vec2([self metersFromPoint:point]);
    mouseJoint->SetTarget(locationWorld);
#endif
}

-(void)destroyMouseJoint{

#if LH_USE_BOX2D
    if(mouseJoint){
        [self box2dWorld]->DestroyJoint(mouseJoint);
    }
    mouseJoint = NULL;
#endif
}


@end
