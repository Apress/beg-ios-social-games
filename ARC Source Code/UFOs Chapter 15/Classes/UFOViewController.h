//
//  GameCenterViewController.h
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"

@interface UFOViewController : UIViewController <GameCenterManagerDelegate>
{
	GameCenterManager *gcManager;
    
    bool findingWirelessController;
    NSArray *gameControllerArray;
}

-(IBAction)playButtonPressed;
-(IBAction)leaderboardButtonPressed;
-(IBAction)customLeaderboardButtonPressed;
- (IBAction)findWirelessController:(id)sender;
-(void)localUserAuthenticationChanged:(NSNotification *)notif;


@property(nonatomic, strong) NSArray *gameControllerArray;

@end

