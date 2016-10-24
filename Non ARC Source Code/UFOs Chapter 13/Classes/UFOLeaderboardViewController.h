//
//  UFOLeaderboardViewController.h
//  UFOs
//
//  Created by Kyle Richter on 2/13/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"

@interface UFOLeaderboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GameCenterManagerDelegate>
{
	NSArray *scoreArray;
	
	IBOutlet UITableView *leaderboardTableView;
	IBOutlet UISegmentedControl *scopeSegementedController;
	
	NSMutableArray *playerArray;
	
	GameCenterManager *gcManager;
}

@property(nonatomic, retain) GameCenterManager *gcManager;
@property(nonatomic, retain) NSArray *scoreArray;


-(IBAction)dismiss;
-(IBAction)segementedControllerDidChange:(id)sender;

@end
