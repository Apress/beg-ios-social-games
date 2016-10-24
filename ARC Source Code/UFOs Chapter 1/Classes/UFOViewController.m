//
//  GameCenterViewController.m
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import "UFOViewController.h"
#import "UFOGameViewController.h"


@implementation UFOViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		return YES;
	
	return NO;
}

-(IBAction)playButtonPressed
{
	UFOGameViewController *gameViewController = [[UFOGameViewController alloc] init];
	[self.navigationController pushViewController: gameViewController animated:YES];
}


@end
