//
//  GameCenterViewController.m
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import "UFOViewController.h"
#import "UFOGameViewController.h"
#import "UFOLeaderboardViewController.h"
#import "UFOAchievementViewController.h"


@implementation UFOViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	if([GameCenterManager isGameCenterAvailable])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(localUserAuthenticationChanged:)
													 name:GKPlayerAuthenticationDidChangeNotificationName 
												   object:nil];
		
		gcManager = [[GameCenterManager alloc] init];
		gcManager.delegate = self;
		[gcManager authenticateLocalUserModern];
		[gcManager populateAchievementCache];
		//[gcManager resetAchievements];
		
	}
	
	else
		NSLog(@"Game Center not available");	
}

-(void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:GKPlayerAuthenticationDidChangeNotificationName object:nil];	
	
	[super viewDidUnload];
}	

-(void)viewWillAppear:(BOOL)animated
{
	gcManager.delegate = self;
	[super viewWillAppear:animated];
}

- (void)playerDataLoaded:(NSArray *)players error:(NSError *)error;
{
	if(error != nil)
		NSLog(@"An error occured during player lookup: %@", [error localizedDescription]);
	else 
		NSLog(@"Players loaded: %@", players);
}

-(void)localUserAuthenticationChanged:(NSNotification *)notif; 
{
	NSLog(@"Authenication Changed: %@", notif.object);	
}

- (void)processGameCenterAuthentication:(NSError*)error;
{
	if(error != nil)
	{
		NSLog(@"An error occured during authentication: %@", [error localizedDescription]);
	}
	else 
	{

	}
}



- (void)friendsFinishedLoading:(NSArray *)friends error:(NSError *)error;
{
	if(error != nil)
		NSLog(@"An error occured during friends list request: %@", [error localizedDescription]);
	else 
		[gcManager playersForIDs: friends];
}

- (void)scoreReported: (NSError*) error;
{
	if(error)
		NSLog(@"There was an error in reporting the score: %@", [error localizedDescription]);
	
	else	
		NSLog(@"Score submitted");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		return YES;
	
	return NO;
}

-(IBAction)playButtonPressed
{
	UFOGameViewController *gameViewController = [[UFOGameViewController alloc] init];
	gameViewController.gcManager = gcManager;
	[self.navigationController pushViewController: gameViewController animated:YES];
}

-(IBAction)leaderboardButtonPressed;
{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
		leaderboardController.category = @"com.dragonforged.ufo.single"; 
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[self presentViewController: leaderboardController animated: YES completion: nil];
        
	}
}

-(IBAction)customLeaderboardButtonPressed;
{
	UFOLeaderboardViewController *leaderboardViewController = [[UFOLeaderboardViewController alloc] init];
	leaderboardViewController.gcManager = gcManager;
    [self presentViewController: leaderboardViewController animated: YES completion: nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[self dismissViewControllerAnimated: YES completion: nil];
}

-(IBAction)achievementButtonPressed;
{
	GKAchievementViewController *achievementViewController = [[GKAchievementViewController alloc] init];
	[achievementViewController setAchievementDelegate:self];
    [self presentViewController: achievementViewController animated: YES completion: nil];

	
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	[self dismissViewControllerAnimated: YES completion: nil];
}

-(IBAction)customAchievementButtonPressed;
{
	UFOAchievementViewController *achievementViewController = [[UFOAchievementViewController alloc] init];
	achievementViewController.gcManager = gcManager;
    [self presentViewController: achievementViewController animated: YES completion: nil];
}

@end
