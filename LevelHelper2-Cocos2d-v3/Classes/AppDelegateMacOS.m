//
//  AppDelegate.m
//  OsX
//
//  Created by Bogdan Vladu on 25/07/14.
//  Copyright VLADU BOGDAN DANIEL PFA 2014. All rights reserved.
//

#import "AppDelegateMacOS.h"
#import "LHSceneSubclass.h"

@implementation OsXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];

	// enable FPS and SPF
	[director setDisplayStats:YES];

    [_glView setFrameSize:LH_SCREEN_RESOLUTION];

	// connect the OpenGL view with the director
	[director setView:_glView];


	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[director setResizeMode:kCCDirectorResize_NoScale];
	
    
	// Enable "moving" mouse event. Default no.
	[_window setAcceptsMouseMovedEvents:YES];
	
	// Center main window
	[_window center];
	
	[director runWithScene:[LHSceneSubclass scene]];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] end];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
}

@end
