//
//  GameCenterAppDelegate.m
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import "UFOAppDelegate.h"
#import "UFOViewController.h"

@implementation UFOAppDelegate

@synthesize window;
@synthesize navController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window.rootViewController = navController;
    [window makeKeyAndVisible];

    return YES;
}
#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [navController release];
    [window release];
    [super dealloc];
}


@end
