//
//  tictactoeGameViewController.m
//  tictactoe
//
//  Created by Kyle Richter on 7/10/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import "tictactoeGameViewController.h"

@implementation tictactoeGameViewController

@synthesize match;

-(void)viewDidLoad
{
    gameDictionary = [[NSMutableDictionary alloc] init];
   
    [super viewDidLoad];
    
    if(match.currentParticipant == [match.participants objectAtIndex:0])
    {
        myPlayerCharacter = @"X";
        identifyTeamLabel.text = @"It is X's Turn";
    }
    
    else
    {
        myPlayerCharacter = @"O";
        identifyTeamLabel.text = @"It is O's Turn";
    }

    [self.match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error)
     {
         
         NSDictionary *myDict = [NSPropertyListSerialization propertyListFromData:match.matchData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
         
         [gameDictionary addEntriesFromDictionary: myDict];         
         [self populateExistingGameBoard];

         if(error)
         {
             NSLog(@"loadMatchData - %@", [error localizedDescription]);
         }
     }];
}

-(void)populateExistingGameBoard
{
    NSArray *dataArray = [gameDictionary allKeys];
    
    for(NSString *key in dataArray)
    {
        UIButton *button = (UIButton *)[self.view viewWithTag: [key intValue]];
        [button setTitle:[gameDictionary objectForKey:key] forState:UIControlStateNormal];
        [button setEnabled: NO];
    }
}

-(IBAction)makeMove:(id)sender;
{   
    [(UIButton *)sender setTitle:myPlayerCharacter forState:UIControlStateNormal];
    
    NSString *buttonIndexString = [NSString stringWithFormat:@"%d", [(UIButton *)sender tag]];
    [gameDictionary setObject:myPlayerCharacter forKey:buttonIndexString];
        
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:gameDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
        
    GKTurnBasedParticipant *nextPlayer; 
    
    if(match.currentParticipant == [match.participants objectAtIndex:0])
    {
        nextPlayer = [[match participants] lastObject];
    }
    else
    {
        nextPlayer = [[match participants] objectAtIndex:0];
    }

    if([self checkWinner] != nil)
    {
        if([[self checkWinner] isEqualToString:@"Tie"])
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"Its a draw" delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:nil delegate:nil cancelButtonTitle:@"Dimiss" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }

        [self.match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeWon nextParticipants:@[nextPlayer] turnTimeout:360000 matchData:data completionHandler:^(NSError *error)
        {
            if(error)
            {
                NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
            }
        }];
    }
    else
    {
        [self.match endTurnWithNextParticipants:@[nextPlayer] turnTimeout:360000 matchData:data completionHandler:^(NSError *error)
        {
            if(error)
            {
                NSLog(@"An error occurred updating turn: %@", [error localizedDescription]);
            }
            
            [self.navigationController popViewControllerAnimated: YES];
        }];
    }
}

-(NSString *)checkWinner
{
    //top row
    if([gameButton1.titleLabel.text isEqualToString:gameButton2.titleLabel.text] && [gameButton2.titleLabel.text isEqualToString:gameButton3.titleLabel.text])
        return gameButton1.titleLabel.text;
    //middle row
    if([gameButton4.titleLabel.text isEqualToString:gameButton5.titleLabel.text] && [gameButton5.titleLabel.text isEqualToString:gameButton6.titleLabel.text])
        return gameButton4.titleLabel.text;
    //bottom row
    if([gameButton7.titleLabel.text isEqualToString:gameButton8.titleLabel.text] && [gameButton8.titleLabel.text isEqualToString:gameButton9.titleLabel.text])
        return gameButton7.titleLabel.text; 
    
    //first column
    if([gameButton1.titleLabel.text isEqualToString:gameButton4.titleLabel.text] && [gameButton4.titleLabel.text isEqualToString:gameButton7.titleLabel.text])
        return gameButton1.titleLabel.text;
    //middle column
    if([gameButton2.titleLabel.text isEqualToString:gameButton5.titleLabel.text] && [gameButton5.titleLabel.text isEqualToString:gameButton8.titleLabel.text])
        return gameButton2.titleLabel.text;
    //last column
    if([gameButton3.titleLabel.text isEqualToString:gameButton6.titleLabel.text] && [gameButton6.titleLabel.text isEqualToString:gameButton9.titleLabel.text])
        return gameButton3.titleLabel.text;
    
    //diagonal
    if([gameButton1.titleLabel.text isEqualToString:gameButton5.titleLabel.text] && [gameButton5.titleLabel.text isEqualToString:gameButton9.titleLabel.text])
        return gameButton1.titleLabel.text;
    if([gameButton3.titleLabel.text isEqualToString:gameButton5.titleLabel.text] && [gameButton5.titleLabel.text isEqualToString:gameButton7.titleLabel.text])
        return gameButton3.titleLabel.text;
    
    
    if(gameButton1.titleLabel.text != nil && gameButton2.titleLabel.text != nil && gameButton3.titleLabel.text != nil &&
       gameButton4.titleLabel.text != nil && gameButton5.titleLabel.text != nil && gameButton6.titleLabel.text != nil &&
       gameButton7.titleLabel.text != nil && gameButton8.titleLabel.text != nil && gameButton9.titleLabel.text != nil)
    {
        return @"Tie";
    }
    
        
    return nil;
}

-(IBAction)forfeit:(id)sender;
{
    [self.match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) 
     {
         if(error)
         {
             NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
         }
         
     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [gameDictionary release];
    [match release]; match = nil;
    [super dealloc];
}

@end
