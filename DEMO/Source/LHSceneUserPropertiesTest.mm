//
//  LHSceneUserPropertiesTest.m
//  LevelHelper2-Cocos2d-v3
//
//  Created by Bogdan Vladu on 15/05/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "LHSceneUserPropertiesTest.h"

@implementation LHSceneUserPropertiesTest

+ (LHSceneDemo *)scene{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/userPropertiesDemo.lhplist"];
}

- (id)initWithContentOfFile:(NSString *)levelPlistFile
{
    self = [super initWithContentOfFile:levelPlistFile];

    if (!self) return(nil);
    

    CCLabelTTF* ttf = [CCLabelTTF labelWithString:@"USER PROPERTIES ON A NODE\nDemonstrate using user properties that were setup inside LevelHelper 2.\nLook at the console for the output.\nLook inside LHSceneUserPropertiesTest.mm for help on how you can set this up."
                                         fontName:@"Arial"
                                         fontSize:22];
    [ttf setColor:[CCColor blackColor]];
    [ttf setHorizontalAlignment:CCTextAlignmentCenter];
    [ttf setPosition:CGPointMake(self.contentSize.width*0.5,
                                 self.contentSize.height*0.7)];
    
    [[self uiNode] addChild:ttf];//add the text to the ui element as we dont want it to move with the camera

    
    /*HELP
     
     //Creating the property class
     1. Inside LevelHelper 2 go to "Tools" menu and choose "Properties Manager"
     2. Write a "Class Name" and click enter to create that class.
     3. With the class selected write a "Member Name" and click enter to create that property.
     4. In the list of properties choose the type of property you want (number, string, connection, boolean)
     //connection is a way to connect one node to another for fast referencing.
     5. Set the "Code Generation Path" to the LHUserProperties.h file that comes with LH 2 api if not already set.
     
     //Assigning the property class on a node
     1. Inside the "Level Editor" select the node you want to assign a property to.
     2. Go to the "Properties Inspector" tab - the first tab on the right side.
     3. Further down you will find "User Info Properties".
     4. Select the property class you want from the "User Info" list.
     5. Assign any value you want on the members you have setup for that property class.
     
     Further down you will see how you can access the properties you have setup.
     First you search for the node that has the property assign to it.
     Then you get the userProperty pointer and convert it to the right property class.
     Then its a matther of reading/writing the property members.
     */
    
    
#ifdef __LH_USER_PROPERTY_ROBOTUSERPROPERTY__
    //we test for this define here as the user might have this class inside its own project which may have
    //different properties or no properties defined. We dont want a compilation error if that happens.
    
    LHSprite* pinkRobot = (LHSprite*)[self childNodeWithName:@"pinkRobot"];
    if(pinkRobot){
        RobotUserProperty* prop = (RobotUserProperty*)[pinkRobot userProperty];
        NSLog(@"...............Pink Robot - User properites.................");
        NSLog(@"LIFE (number property) %f", [prop life]);
        NSLog(@"ACTIVATED (boolean property) %d", [prop activated]);
        NSLog(@"MODEL (string property) %@", [prop model]);
        
        CCNode* connectedRobot = (CCNode*)[prop connection];
        if(connectedRobot){
            LHSprite* spr = (LHSprite*)connectedRobot;
            if(spr){
                NSLog(@"CONNECTED TO (pointer to another node - connection property) %@ class: %@", [spr name], NSStringFromClass([spr class]));
            }
        }
    }
    
    
    LHSprite* blueRobot = (LHSprite*)[self childNodeWithName:@"blueRobot"];
    if(blueRobot){
        RobotUserProperty* prop = (RobotUserProperty*)[blueRobot userProperty];
        NSLog(@"...............Blue Robot - User properites.................");
        NSLog(@"LIFE (number property) %f", [prop life]);
        NSLog(@"ACTIVATED (boolean property) %d", [prop activated]);
        NSLog(@"MODEL (string property) %@", [prop model]);
        
        CCNode* connectedRobot = (CCNode*)[prop connection];
        if(connectedRobot){
            LHSprite* spr = (LHSprite*)connectedRobot;
            if(spr){
                NSLog(@"CONNECTED TO (pointer to another node - connection property) %@ class: %@", [spr name], NSStringFromClass([spr class]));
            }
        }
    }
    
    
    
    LHSprite* greenRobot = (LHSprite*)[self childNodeWithName:@"greenRobot"];
    if(greenRobot){
        RobotUserProperty* prop = (RobotUserProperty*)[greenRobot userProperty];
        NSLog(@"...............Green Robot - User properites.................");
        NSLog(@"LIFE (number property) %f", [prop life]);
        NSLog(@"ACTIVATED (boolean property) %d", [prop activated]);
        NSLog(@"MODEL (string property) %@", [prop model]);
        
        CCNode* connectedRobot = (CCNode*)[prop connection];
        if(connectedRobot){
            LHSprite* spr = (LHSprite*)connectedRobot;
            if(spr){
                NSLog(@"CONNECTED TO (pointer to another node - connection property) %@ class: %@", [spr name], NSStringFromClass([spr class]));
            }
        }
    }
    
#endif
    
    
    
    
    // done
	return self;
}


@end
