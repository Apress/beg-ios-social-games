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
		[gcManager findAllActivity];
		
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
		[gcManager setupInvitationHandler:self];
	}
}

- (void)findProgrammaticMatch
{
	GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
	request.minPlayers = 2;
	request.maxPlayers = 4;
	
	[[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
		if (error) 
		{
			NSLog(@"An error occurrred during finding a match: %@", [error localizedDescription]);
		} 
		
		else if (match != nil)
		{
			NSLog(@"A match has been found: %@", match);
		}
	}];
}

- (void)findProgrammaticHostedMatch
{
	GKMatchRequest *request = [[GKMatchRequest alloc] init]; 
	request.minPlayers = 2;
	request.maxPlayers = 16;
	
	[[GKMatchmaker sharedMatchmaker] findPlayersForHostedMatchRequest:request withCompletionHandler:^(NSArray *playerIDs, NSError *error){
		if (error) 
		{
			NSLog(@"An error occurrred during finding a match: %@", [error localizedDescription]);
		} 
		
		else if (playerIDs != nil)
		{
			NSLog(@"Players have been found for match: %@", playerIDs);
		}
	}];
}

- (void)addPlayerToMatch:(GKMatch *)match withRequest:(GKMatchRequest *)request
{
	[[GKMatchmaker sharedMatchmaker] addPlayersToMatch:match matchRequest:request completionHandler:^(NSError *error)
	{
		if (error) 
		{
			NSLog(@"An error occurrred during adding a player to match: %@", [error localizedDescription]);
		} 
		
		else if (match != nil)
		{
			NSLog(@"A player has been added to the match");
		}
	}];
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
        [self presentViewController:leaderboardController animated:YES completion:nil];
	}
}

-(IBAction)customLeaderboardButtonPressed;
{
	UFOLeaderboardViewController *leaderboardViewController = [[UFOLeaderboardViewController alloc] init];
	leaderboardViewController.gcManager = gcManager;
    [self presentViewController:leaderboardViewController animated:YES completion:nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)achievementButtonPressed;
{
	GKAchievementViewController *achievementViewController = [[GKAchievementViewController alloc] init];
	[achievementViewController setAchievementDelegate:self];
    [self presentViewController:achievementViewController animated:YES completion:nil];
}

-(void)player:(GKPlayer *)player exchangeCanceled:(GKTurnBasedExchange *)exchange
        match:(GKTurnBasedMatch *)match
{
    
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)customAchievementButtonPressed;
{
	UFOAchievementViewController *achievementViewController = [[UFOAchievementViewController alloc] init];
	achievementViewController.gcManager = gcManager;
    [self presentViewController:achievementViewController animated:YES completion:nil];
}

-(IBAction)multiplayerButtonPressed;
{
	GKMatchRequest *request = [[GKMatchRequest alloc] init];
	request.minPlayers = 2; 
	request.maxPlayers = 4;
	
	GKMatchmakerViewController *matchmakerViewController = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
	matchmakerViewController.matchmakerDelegate = self; 
		
    [self presentViewController:matchmakerViewController animated:YES completion:nil];
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error 
{
    [self dismissViewControllerAnimated:YES completion:nil];
	
	if(error != nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:[NSString stringWithFormat:@"An error occurred: %@", [error localizedDescription]] 
													   delegate:nil 
											  cancelButtonTitle:@"Dismiss" 
											  otherButtonTitles:nil];
		[alert show];
	}	
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match 
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs
{
    [self dismissViewControllerAnimated:YES completion:nil];
	
	NSLog(@"Players: %@", playerIDs);
	
	//Begin Hosted Game
}

- (void)playerActivity:(NSNumber *)activity error:(NSError *)error
{
	if(error != nil)
	{
		NSLog(@"An error occurred while querying player activity: %@", [error localizedDescription]);
	}	
	
	else
	{
		NSLog(@"All recent player activity: %@", activity);
	}

	
}
- (void)playerActivityForGroup:(NSDictionary *)activityDict error:(NSError *)error
{
	if(error != nil)
	{
		NSLog(@"An error occurred while querying player activity: %@", [error localizedDescription]);
	}	
	
	else
	{
		NSLog(@"All recent player activity: %@ For Group: %@", [activityDict objectForKey:@"activity"], [activityDict objectForKey:@"group"]);
	}
}	

@end
