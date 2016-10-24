//
//  GameCenterViewController.h
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"

@interface UFOViewController : UIViewController <GameCenterManagerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
	GameCenterManager *gcManager;
}

-(IBAction)playButtonPressed;
-(IBAction)leaderboardButtonPressed;
-(IBAction)customLeaderboardButtonPressed;
-(IBAction)achievementButtonPressed;
-(IBAction)customAchievementButtonPressed;

-(void)localUserAuthenticationChanged:(NSNotification *)notif; 
@end

