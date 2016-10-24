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
#import "GameController/GCController.h"

@implementation UFOViewController

@synthesize gameControllerArray;

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
	}
	
	else
		NSLog(@"Game Center not available");
    
    //Populate any controllers available before notficaitons get added
    self.gameControllerArray = [GCController controllers];

    //Handle Game Controller Connection Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers:) name:GCControllerDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupControllers:) name:GCControllerDidDisconnectNotification object:nil];
}

-(void)setupControllers:(NSNotification *)notif
{
    self.gameControllerArray = [GCController controllers];
    
    if([gameControllerArray count] > 0)
    {
        NSLog(@"Game Controllers Found: %i", [gameControllerArray count]);
    }
    
    else
    {
        NSLog(@"No game controllers found");
    }
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
		NSLog(@"An error occured during authentication: %@", [error localizedDescription]);
	else 
		[gcManager retrieveFriendsList];
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
	[gameViewController release];
}

-(IBAction)leaderboardButtonPressed;
{
    GKGameCenterViewController *leaderboardController = [[GKGameCenterViewController alloc] init];
    leaderboardController.viewState = GKGameCenterViewControllerStateLeaderboards;
    
	if (leaderboardController != NULL)
	{
		[self presentViewController: leaderboardController animated: YES completion: nil];
	}
}

-(IBAction)customLeaderboardButtonPressed;
{
	UFOLeaderboardViewController *leaderboardViewController = [[UFOLeaderboardViewController alloc] init];
	leaderboardViewController.gcManager = gcManager;
    [self presentViewController: leaderboardViewController animated: YES completion: nil];
	[leaderboardViewController release];
}

- (IBAction)findWirelessController:(id)sender
{
    findingWirelessController = !findingWirelessController;
    
    if(findingWirelessController)
    {
        [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
            NSLog(@"Wireless controller searching has finished");
        }];
    }
    else
    {
        [GCController stopWirelessControllerDiscovery];
        NSLog(@"Wireless controller stopped by user");
    }
    
}


@end
