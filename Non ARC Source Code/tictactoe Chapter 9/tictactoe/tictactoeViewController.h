//
//  tictactoeViewController.h
//  tictactoe
//
//  Created by Kyle Richter on 7/10/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"

@interface tictactoeViewController : UIViewController <GameCenterManagerDelegate, GKTurnBasedMatchmakerViewControllerDelegate>
{
    GameCenterManager *gcManager;
}

-(IBAction)beginGame:(id)sender;

@end
