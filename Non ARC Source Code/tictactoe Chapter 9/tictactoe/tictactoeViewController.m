//
//  tictactoeViewController.m
//  tictactoe
//
//  Created by Kyle Richter on 7/10/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import "tictactoeViewController.h"
#import "tictactoeGameViewController.h"

@implementation tictactoeViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if([GameCenterManager isGameCenterAvailable])
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localUserAuthenticationChanged:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
		
		gcManager = [[GameCenterManager alloc] init];
		[gcManager setDelegate: self];
		[gcManager authenticateLocalUserModern];
	}
}

- (void)processGameCenterAuthentication:(NSError*)error;
{
	if(error != nil)
		NSLog(@"An error occured during authentication: %@", [error localizedDescription]);
}


-(void)localUserAuthenticationChanged:(NSNotification *)notif; 
{
	NSLog(@"Authenication Changed: %@", notif.object);	
}


-(IBAction)beginGame:(id)sender
{
    GKMatchRequest *match = [[GKMatchRequest alloc] init];
    [match setMaxPlayers:2];
    [match setMinPlayers:2];
    
    GKTurnBasedMatchmakerViewController *turnMatchmakerViewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:match];
    
    [turnMatchmakerViewController setTurnBasedMatchmakerDelegate: self];
    [self presentViewController:turnMatchmakerViewController animated:YES completion:nil];
    [turnMatchmakerViewController release];
    [match release];  
}

- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    [self dismissViewControllerAnimated: YES completion: nil];
    
    tictactoeGameViewController *gameVC = [[tictactoeGameViewController alloc] init];
    gameVC.match = match;
    [[self navigationController] pushViewController:gameVC animated:YES];
    [gameVC release];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    [match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) 
    {
        if(error)
        {
            NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
        }

    }];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    NSLog(@"Turned Based Matchmaker Failed with Error: %@", [error localizedDescription]);
}

-(void)newGameWithMatch:(GKTurnBasedMatch *)match
{
    tictactoeGameViewController *gameVC = [[tictactoeGameViewController alloc] init];
    gameVC.match = match;
    [[self navigationController] pushViewController:gameVC animated:YES];
    [gameVC release];
    
}

-(void)findMatch
{
    GKMatchRequest *match = [[GKMatchRequest alloc] init];
    [match setMaxPlayers:2];
    [match setMinPlayers:2];
    
    [GKTurnBasedMatch findMatchForRequest:match withCompletionHandler:^(GKTurnBasedMatch *match, NSError *error) 
    {
        if(error == nil)
        {
            [self performSelectorOnMainThread:@selector(newGameWithMatch:) withObject:match waitUntilDone:NO];
        }
        
        else
        {
            NSLog(@"An error occurred when finding a match: %@", [error localizedDescription]);
            
            
        }
    }];
}

-(void)loadMatches
{
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error) 
    {
        if(error == nil)
        {
            NSLog(@"Existing Matches: %@", matches);
        }
        
        else
        {
            NSLog(@"An error occurred while loading matches: %@", [error localizedDescription]);
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
