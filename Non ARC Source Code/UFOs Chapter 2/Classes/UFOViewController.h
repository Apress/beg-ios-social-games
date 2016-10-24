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
    

}

-(IBAction)playButtonPressed;
-(void)localUserAuthenticationChanged:(NSNotification *)notif;

@end

