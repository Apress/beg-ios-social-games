//
//  UFOAchievementViewController.h
//  UFOs
//
//  Created by Kyle Richter on 3/4/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"

@interface UFOAchievementViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GameCenterManagerDelegate>
{
	GameCenterManager *gcManager;
	
	IBOutlet UITableView *achievementTableView;
	
	NSArray *achievementArray;
}

@property(nonatomic, strong) GameCenterManager *gcManager;
@property(nonatomic, strong) NSArray *achievementArray;

-(IBAction)dismissAction;

@end
