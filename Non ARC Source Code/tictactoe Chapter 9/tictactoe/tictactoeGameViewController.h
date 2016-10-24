//
//  tictactoeGameViewController.h
//  tictactoe
//
//  Created by Kyle Richter on 7/10/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface tictactoeGameViewController : UIViewController
{
    GKTurnBasedMatch *match;
    NSMutableDictionary *gameDictionary;
    
    NSString *myPlayerCharacter;
    
    IBOutlet UILabel *identifyTeamLabel;
    
    IBOutlet UIButton *gameButton1;
    IBOutlet UIButton *gameButton2;
    IBOutlet UIButton *gameButton3;
    IBOutlet UIButton *gameButton4;
    IBOutlet UIButton *gameButton5;
    IBOutlet UIButton *gameButton6;
    IBOutlet UIButton *gameButton7;
    IBOutlet UIButton *gameButton8;
    IBOutlet UIButton *gameButton9;

}

@property(nonatomic, retain) GKTurnBasedMatch *match;

-(IBAction)forfeit:(id)sender;
-(IBAction)makeMove:(id)sender;
-(void)populateExistingGameBoard;
-(NSString *)checkWinner;

@end
