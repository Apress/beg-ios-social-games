//
//  tictactoeAppDelegate.m
//  tictactoe
//
//  Created by Kyle Richter on 7/10/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import "tictactoeAppDelegate.h"

#import "tictactoeViewController.h"

@implementation tictactoeAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    tictactoeViewController *controller = [[tictactoeViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;

}

@end
