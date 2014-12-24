//
//  AppDelegate.h
//  OsX
//
//  Created by Bogdan Vladu on 25/07/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//

#import "cocos2d.h"

@interface OsXAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSWindow    *window;
@property (nonatomic, weak) IBOutlet CCGLView    *glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
