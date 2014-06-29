//
//  LHSceneGearJointsTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneGearJointsTest.h"
#import "LHConfig.h"
#import "LHUtils.h"

@implementation LHSceneGearJointsTest
{
#if LH_USE_BOX2D
    b2MouseJoint* mouseJoint;
#endif
}
+ (LHSceneGearJointsTest *)scene
{
	return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/level07-gearJoint.plist"];
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
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Gear Joints Example.\nDrag a wheel or the red handle to move the joints.\n"
                                         fontName:@"Arial"
                                         fontSize:24];
    
#else
    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"Gear Joints Example.\nSorry, this demo is not available using Chipmunk. Try Box2d instead.\n"
                                         fontName:@"Arial"
                                         fontSize:24];
    
#endif
    [ttf setColor:[CCColor blackColor]];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.5 - ttf.contentSize.height)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    
    return self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
//    {
//        LHGearJointNode* gJointNode1 = (LHGearJointNode*)[self childNodeWithName:@"GearJoint1"];
//        if(gJointNode1){
//            NSLog(@"REMOVING THE GEAR JOINT %@", [gJointNode1 name]);
//            [gJointNode1 removeFromParent];
//            gJointNode1 = NULL;
//        }
//    }
//
//    {
//        LHGearJointNode* gJointNode1 = (LHGearJointNode*)[self childNodeWithName:@"GearJoint2"];
//        if(gJointNode1){
//            NSLog(@"REMOVING THE GEAR JOINT %@", [gJointNode1 name]);
//            [gJointNode1 removeFromParent];
//            gJointNode1 = NULL;
//        }
//    }

    //without this touch began is not called
    CCDirector* dir = [CCDirector sharedDirector];
    CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [dir convertToGL: touchLocation];
    
    [self createMouseJointForTouchLocation:touchLocation];


    //dont forget to call super
    [super touchBegan:touch withEvent:event];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CCDirector* dir = [CCDirector sharedDirector];
    CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [dir convertToGL: touchLocation];
    
    
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
                    ourBody = b;
                    break;//exit for loop
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
