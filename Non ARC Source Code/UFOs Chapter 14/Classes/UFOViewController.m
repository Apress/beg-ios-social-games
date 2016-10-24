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
#import <MediaPlayer/MediaPlayer.h>

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
	}
	
	else
		NSLog(@"Game Center not available");
    
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(15, 15, 0, 0)];
    [volumeView setShowsVolumeSlider:NO];
    [self.view addSubview: volumeView];
    [volumeView release];
    
    
}

- (bool)checkForExistingScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1)
    {
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
    
        CGRect screenBounds = secondScreen.bounds;
        UIWindow * secondWindow = [[UIWindow alloc] initWithFrame:screenBounds];
        secondWindow.screen = secondScreen;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(fireStop) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

        [button setTitle:@"Fire!" forState:UIControlStateNormal];
        button.frame = CGRectMake(80.0, 180.0, 160.0, 40.0);
        [self.view addSubview:button];
        
        
        secondWindow.hidden = NO;
        
        gameViewController = [[UFOGameViewController alloc] init];
        gameViewController.view.frame = screenBounds;
        gameViewController.gcManager = gcManager;
        [secondWindow addSubview:gameViewController.view];

        
        return YES;
    }
    
    return NO;
}

-(void)fire
{
    [gameViewController touchesBegan:nil withEvent:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenDidConnectNotification:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenDidDisconnectNotification:) name:UIScreenDidDisconnectNotification object:nil];
    
}

-(void)fireStop
{
    [gameViewController touchesEnded:nil withEvent:nil];
    
}

-(void)viewDidUnload
{
    [gameViewController release];
    
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
    if([self checkForExistingScreenAndInitializeIfPresent])
    {
        //Using second screen
    }
    
    else
    {
        gameViewController = [[UFOGameViewController alloc] init];
        gameViewController.gcManager = gcManager;
        [self.navigationController pushViewController: gameViewController animated:YES];
        
    }
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


@end
