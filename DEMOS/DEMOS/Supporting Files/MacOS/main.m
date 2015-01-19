//
//  main.m
//  cocos2d-mac
//
//  Created by Ricardo Quesada on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "cocos2d.h"

int main(int argc, char *argv[])
{

#if COCOS2D_VERSION >= 0x00030300
    
#else
    [CCGLView load_];
#endif//cocos2d_version
    
    return NSApplicationMain(argc,  (const char **) argv);
}
