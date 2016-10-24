//
//  UFOLeaderboardViewController.m
//  UFOs
//
//  Created by Kyle Richter on 2/13/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import "UFOLeaderboardViewController.h"
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>


@implementation UFOLeaderboardViewController
@synthesize gcManager, scoreArray;

-(void)viewDidLoad
{
	self.gcManager.delegate = self;
	[super viewDidLoad];
	[self segementedControllerDidChange: nil];
	
	playerArray = [[NSMutableArray alloc] init];
	[self.gcManager retrieveLocalScoreForCategory: @"com.dragonforged.ufo.single"];
}	

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
		return YES;
	
	return NO;
}

#pragma mark -
#pragma mark Actions

-(IBAction)segementedControllerDidChange:(id)sender;
{
	GKLeaderboardPlayerScope playerScope;
	
	if([scopeSegementedController selectedSegmentIndex] == 0)
	{
		playerScope = GKLeaderboardPlayerScopeFriendsOnly;
	}
	else 
	{
		playerScope = GKLeaderboardPlayerScopeGlobal;
	}

	self.scoreArray = nil;
	[self.gcManager retrieveScoresForCategory:@"com.dragonforged.ufo.single" withPlayerScope:playerScope timeScope:GKLeaderboardTimeScopeAllTime withRange:NSMakeRange(1,50)];
	[leaderboardTableView reloadData];
}

-(IBAction)dismiss;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark Table Game Center Delegate
- (void)leaderboardUpdated: (NSArray *)scores error:(NSError *)error;
{
	if(error != nil)
		NSLog(@"An error occurred: %@", [error localizedDescription]);
	else 
		self.scoreArray = [NSArray arrayWithArray: scores];
	
	[leaderboardTableView reloadData];
}

- (void)mappedPlayerIDToPlayer:(GKPlayer *)player error:(NSError *)error
{
	if(error != nil)
		NSLog(@"Error during player mapping: %@", [error localizedDescription]);
	else 
		[playerArray addObject: player];	
	
	[leaderboardTableView reloadData];
}

- (void)mappedPlayerIDsToPlayers:(NSArray *)players error:(NSError *)error
{
	if(error != nil)
		NSLog(@"Error during player mapping: %@", [error localizedDescription]);
	else 
		[playerArray addObjectsFromArray:players];
	
	[leaderboardTableView reloadData];
}

- (void)localPlayerScore:(GKScore *)score error:(NSError *)error;
{
	if(error != nil)
		NSLog(@"Error getting local score: %@", [error localizedDescription]);
	else 
		NSLog(@"Local User Score: %@", score);
}

#pragma mark -
#pragma mark Table View DataSource

-(NSString *)playerNameforID:(NSString *)playerID;
{
	for(GKPlayer *player in playerArray)
	{
		if([player.playerID isEqualToString: playerID])
			return player.alias;
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	return [self.scoreArray count];
}	

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	GKScore *score = [self.scoreArray objectAtIndex: indexPath.row];
		
	NSString *playerName = [self playerNameforID: score.playerID];
	
	if(playerName == nil)
	{
		[self.gcManager mapPlayerIDtoPlayer: score.playerID];
		cell.textLabel.text = @"Loading Name...";
	}
	else 
	{
		cell.textLabel.text = playerName;
	}
	
	cell.detailTextLabel.text = score.formattedValue;
		
    return cell;
}

#pragma mark -
#pragma mark Teardown

-(void)dealloc
{
	[scoreArray release]; scoreArray = nil;
	[gcManager release]; gcManager = nil;
    [super dealloc];
}


@end
