//
//  GameCenterManager.m
//  UFOs
//
//  Created by Kyle Richter on 1/25/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import "GameCenterManager.h"


@implementation GameCenterManager

@synthesize delegate;
@synthesize earnedAchievementCache;
@synthesize matchOrSession;

+ (BOOL) isGameCenterAvailable
{
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

- (void)retrieveFriendsList;
{
	if([GKLocalPlayer localPlayer].authenticated == YES)
	{
		[[GKLocalPlayer localPlayer] loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error)
		 {
			 [self callDelegateOnMainThread: @selector(friendsFinishedLoading:error:) withArg: friends error: error];
		 }];
	}
	
	else 
		NSLog(@"You must authenicate first");
}

- (void)playersForIDs:(NSArray *)playerIDs
{
	[GKPlayer loadPlayersForIdentifiers:playerIDs withCompletionHandler:^(NSArray *players, NSError *error)
	 {
		 [self callDelegateOnMainThread: @selector(playerDataLoaded:error:) withArg: players error: error];
	}];
}

- (void)playerforID:(NSString *)playerID
{
	[GKPlayer loadPlayersForIdentifiers:[NSArray arrayWithObject:playerID] withCompletionHandler:^(NSArray *players, NSError *error)
	 {
		 [self callDelegateOnMainThread: @selector(playerDataLoaded:error:) withArg: players error: error];
	 }];
}

//- (void) authenticateLocalUser
//{
//	if([GKLocalPlayer localPlayer].authenticated == NO)
//	{
//		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
//		 {
//			 if(error == nil)
//				 [self submitAllSavedScores];
//
//			 [self callDelegateOnMainThread: @selector(processGameCenterAuthentication:) withArg: NULL error: error];
//		 }];
//	}
//}


- (void)authenticateLocalUserModern
{
    if ([[GKLocalPlayer localPlayer] authenticateHandler] == nil)
    {
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error)
         {
             if (error != nil)
             {
                 if ([error code] == GKErrorNotSupported) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This device does not support Game Center" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                     [alert show];
                     [alert release];
                 }
                 else if ([error code] == GKErrorCancelled)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This device has failed login too many times from the app, you will need to login from the Game Center.app" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                     [alert show];
                     [alert release];
                 }
                 
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                     [alert show];
                     [alert release];
                 }
             }
             
             else
             {
                 if (viewController != nil)
                 {
                     [(UIViewController *)delegate presentViewController:viewController animated:YES completion:NULL];
                 }
                 
                 [self submitAllSavedScores];
             }
         }];
    }
}

-(void)setupInvitationHandler:(id)inivationHandler;
{
	[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite)
	{
		if (acceptedInvite)
		{
			GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite] autorelease];
			mmvc.matchmakerDelegate = inivationHandler;
			[inivationHandler presentModalViewController:mmvc animated:YES];
		} 
			
		else if (playersToInvite) 
		{
			GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
			request.minPlayers = 2; 
			request.maxPlayers = 2; 
			request.playersToInvite = playersToInvite;
			
			GKMatchmakerViewController *mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
			mmvc.matchmakerDelegate = inivationHandler;
			[inivationHandler presentModalViewController:mmvc animated:YES];
		}			
	};
}

- (void) reportScore: (int64_t) score forCategory: (NSString*) category 
{
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];	
	scoreReporter.value = score;
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
	 {
		 if (error != nil)
		 {
			 NSData* savedScoreData = [NSKeyedArchiver archivedDataWithRootObject:scoreReporter];
			 [self storeScoreForLater: savedScoreData];
		 }
		 
		 [self callDelegateOnMainThread: @selector(scoreReported:) withArg: NULL error: error];
	 }];
}

- (void)storeScoreForLater:(NSData *)scoreData;
{
	NSMutableArray *savedScoreArray = [[NSMutableArray alloc] initWithArray: [[NSUserDefaults standardUserDefaults] objectForKey:@"savedScores"]];
	[savedScoreArray addObject: scoreData];
	[[NSUserDefaults standardUserDefaults] setObject:savedScoreArray forKey:@"savedScores"];
	[savedScoreArray release];
}

-(void)submitAllSavedScores
{
	NSMutableArray *savedScoreArray = [[NSMutableArray alloc] initWithArray: [[NSUserDefaults standardUserDefaults] objectForKey:@"savedScores"]];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey: @"savedScores"];
	
	for(NSData *scoreData in savedScoreArray)
	{
		GKScore *scoreReporter = [NSKeyedUnarchiver unarchiveObjectWithData: scoreData];
		
		[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
		 {
			 if (error != nil)
			 {
				 NSData* savedScoreData = [NSKeyedArchiver archivedDataWithRootObject:scoreReporter];
				 [self storeScoreForLater: savedScoreData];
			 }
			 
			 else 
				 NSLog(@"Saved score submitted");
		 }];
	}
}


- (void)retrieveScoresForCategory:(NSString *)category withPlayerScope:(GKLeaderboardPlayerScope)playerScope timeScope:(GKLeaderboardTimeScope)timeScope withRange: (NSRange)range;
{
	GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
	leaderboardRequest.playerScope = playerScope;
	leaderboardRequest.timeScope = timeScope;
	leaderboardRequest.range = range;
	leaderboardRequest.category = category;
	
	[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores,NSError *error) 
	 {
		 [self callDelegateOnMainThread: @selector(leaderboardUpdated:error:) withArg: scores error: error];
	 }];
}

-(void)retrieveLocalScoreForCategory:(NSString *)category
{
	GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
	leaderboardRequest.category = category;

	[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores,NSError *error) 
	 {
		 [self callDelegateOnMainThread: @selector(localPlayerScore:error:) withArg: leaderboardRequest.localPlayerScore error: error];
	 }];
}

- (void)mapPlayerIDtoPlayer:(NSString*)playerID
{
	[GKPlayer loadPlayersForIdentifiers: [NSArray arrayWithObject: playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error)
	 {
		 GKPlayer* player= NULL;
		 for (GKPlayer* tempPlayer in playerArray)
		 {
			 if([tempPlayer.playerID isEqualToString: playerID])
			 {
				 player = tempPlayer;
				 break;
			 }
		 }
		 [self callDelegateOnMainThread: @selector(mappedPlayerIDToPlayer:error:) withArg: player error: error];
	 }];
}

- (void)mapPlayerIDstoPlayers:(NSArray*)playerIDs
{
	[GKPlayer loadPlayersForIdentifiers: playerIDs withCompletionHandler:^(NSArray *playerArray, NSError *error)
	 {
		[self callDelegateOnMainThread: @selector(mappedPlayerIDs:error:) withArg: playerArray error: error];
	 }];
}

- (void)resetAchievements
{
	self.earnedAchievementCache = NULL;
	
	[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) 
	 {
		 if(error == NULL)
		 {
			 NSLog(@"Achievements have been reset");

		 }
		 else 
		 {
			 NSLog(@"There was an error in resetting the achievements: %@", [error localizedDescription]);
		 }
	 }];
}


- (void)submitAchievement:(NSString*)identifier percentComplete:(double)percentComplete
{
    if([GKLocalPlayer localPlayer].authenticated == NO)
        return;
    
    
	if(self.earnedAchievementCache == NULL)
	{
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *achievements, NSError *error)
		 {
			 if(error == NULL)
			 {
				 NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [achievements count]];
				 
				 for (GKAchievement* achievement in achievements)
				 {
					 [tempCache setObject: achievement forKey: achievement.identifier];
				 }
				 
				 self.earnedAchievementCache = tempCache;
				 [self submitAchievement: identifier percentComplete: percentComplete];
			 }

			 else
			 {
				 [self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg: NULL error: error];
			 }
			 
		 }];
	}
	
	else
	{
		GKAchievement* achievement= [self.earnedAchievementCache objectForKey: identifier];
				
		if(achievement != NULL)
		{
			if((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete))
			{
				achievement = NULL;
			}
			
			achievement.percentComplete = percentComplete;
		}
		
		else
		{
			achievement= [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
			achievement.percentComplete= percentComplete;

			[self.earnedAchievementCache setObject: achievement forKey: achievement.identifier];
		}
	
		if(achievement!= NULL)
		{

			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			 {
				 if(error != nil)
				 {
					 [self storeAchievementToSubmitLater: achievement];	
					 
				 }
				 
				 if(percentComplete >= 100)
				 {
					 [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler: ^(NSArray *descriptions, NSError *error) 
					 {
						 for(GKAchievementDescription *achievementDescription in descriptions)
						 {
							if([achievement.identifier isEqualToString: achievementDescription.identifier])
							{
								[self callDelegateOnMainThread:@selector(achievementEarned:) withArg:achievementDescription error:nil];
							}
							 
						 }	
						 

					 }];
				 }
				 
				 [self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg: achievement error: error];
			 }];
		}
	}
}

-(void)populateAchievementCache
{
	if(self.earnedAchievementCache == NULL)
	{
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *achievements, NSError *error)
		 {
			 if(error == NULL)
			 {
				 NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [achievements count]];
				 
				 for (GKAchievement* achievement in achievements)
				 {
					 [tempCache setObject: achievement forKey: achievement.identifier];
				 }
				 
				 self.earnedAchievementCache = tempCache;
			 }
			 
			 else
			 {
				 NSLog(@"An error occurred while loading achievements: %@", [error localizedDescription]);
			 }
			 
		 }];
	}
}

-(void)storeAchievementToSubmitLater:(GKAchievement *)achievement
{
	NSMutableDictionary *achievementDictionary = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] objectForKey:@"savedAchievements"]];
	
	if([achievementDictionary objectForKey: achievement.identifier] == nil)
	{
		[achievementDictionary setObject:[NSNumber numberWithDouble: achievement.percentComplete] forKey:achievement.identifier];
	}	
	
	else
	{
		double storedProgress = [[achievementDictionary objectForKey: achievement.identifier] doubleValue];
		
		if(achievement.percentComplete > storedProgress)
		{
			[achievementDictionary setObject:[NSNumber numberWithDouble: achievement.percentComplete] forKey:achievement.identifier];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:achievementDictionary forKey:@"savedAchievements"];
	
	[achievementDictionary release];	
}


-(void)submitAllSavedAchievements
{
	NSMutableDictionary *achievementDictionary = [[NSMutableDictionary alloc] initWithDictionary: [[NSUserDefaults standardUserDefaults] objectForKey:@"savedAchievements"]];
	NSArray *keys = [achievementDictionary allKeys];
	
	for(int x = 0; x < [keys count]; x++)
	{
		[self submitAchievement:[keys objectAtIndex:x] percentComplete:[[achievementDictionary objectForKey: [keys objectAtIndex:x]] doubleValue]];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey: [keys objectAtIndex:x]];
	}	
	
	[achievementDictionary release];
}

- (void)retrieveAchievmentMetadata
{
	[GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler: ^(NSArray *descriptions, NSError *error) 
	{
		[self callDelegateOnMainThread:@selector(achievementDescriptionsLoaded:error:) withArg:descriptions error:error];
	}];
}

-(GKAchievement *)achievementForIdentifier:(NSString *)identifier
{
	GKAchievement *achievement = [self.earnedAchievementCache objectForKey:identifier]; 
	
	if (achievement == nil) 
	{
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
		[self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
	} 
	
	return [[achievement retain] autorelease];	
}

-(double)percentageCompleteOfAchievementWithIdentifier:(NSString *)identifier
{
    if([GKLocalPlayer localPlayer].authenticated == NO)
        return -1;
    
	if(self.earnedAchievementCache == NULL)
	{
		NSLog(@"Unable to determine achievement progress, local cache is empty");
 
	}
	
	else
	{
		GKAchievement* achievement= [self.earnedAchievementCache objectForKey: identifier];
	
		if(achievement != NULL)
		{
			return achievement.percentComplete;
		}
		
		else
		{
			return 0;	
		}
	}
	
	return -1;
}

-(BOOL)achievementWithIdentifierIsComplete:(NSString *)identifier
{
	if([self percentageCompleteOfAchievementWithIdentifier: identifier] >= 100)
	{
		return YES;
	}
	else 
	{
		return NO;
	}
}

- (void)findAllActivity
{
	[[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError *error) {
		[self callDelegateOnMainThread:@selector(playerActivity:error:) withArg:[NSNumber numberWithInt: activity] error:error];
	}];
}

- (void)findActivityForPlayerGroup:(NSUInteger)playerGroup
{
	[[GKMatchmaker sharedMatchmaker] queryPlayerGroupActivity:playerGroup withCompletionHandler:^(NSInteger activity, NSError *error) {
		
		NSDictionary *activityDictionary = [[NSDictionary alloc] initWithObjects:
											[NSArray arrayWithObjects:[NSNumber numberWithInt: activity],
											[NSNumber numberWithInt: playerGroup], nil] 
											forKeys:[NSArray arrayWithObjects:@"activity", @"group", nil]];
		
		
		[self callDelegateOnMainThread:@selector(playerActivityForGroup:error:) withArg:activityDictionary error:error];
		
		[activityDictionary release];
	}];
}

-(void)sendStringToAllPeers:(NSString *)dataString reliable:(BOOL)reliable
{
    
    if(self.matchOrSession == nil)
    {
        NSLog(@"Game Center Manager matchOrSession ivar was not set, this needs to be set with the GKMatch or GKSession before sending or receiving data");
        
        
        return;
    }
    
    NSData *dataToSend = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    GKSendDataMode mode;
    
    if(reliable)
        mode = GKSendDataReliable;
    else
        mode = GKSendDataUnreliable;
    
    NSError *error = nil;
    
    
    if([self.matchOrSession isKindOfClass: [GKSession class]])
    {
        [self.matchOrSession sendDataToAllPeers:dataToSend withDataMode:mode error:&error];
    }
    
    else if([self.matchOrSession isKindOfClass: [GKMatch class]])
    {
        [self.matchOrSession sendDataToAllPlayers:dataToSend withDataMode:mode error:&error];
    }
    
    else 
    {
       NSLog(@"Game Center Manager matchOrSession was not a GKMatch or a GKSession, we are unable to send data"); 
    }
    
    if(error != nil)
    {
        NSLog(@"An error occurred while sending data: %@", [error localizedDescription]);
    }
}


-(void)sendString:(NSString *)dataString toPeers:(id)peers reliable:(BOOL)reliable
{
    if(self.matchOrSession == nil)
    {
        NSLog(@"Game Center Manager matchOrSession ivar was not set, this needs to be set with the GKMatch or GKSession before sending or receiving data");
        
        
        return;
    }
    
    NSData *dataToSend = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    GKSendDataMode mode;
    
    if(reliable)
        mode = GKSendDataReliable;
    else
        mode = GKSendDataUnreliable;
    
    NSError *error = nil;

    
    if([self.matchOrSession isKindOfClass: [GKSession class]])
    {
        if([peers isKindOfClass:[NSArray class]])
        {
            [self.matchOrSession sendData:dataToSend toPeers:peers withDataMode:mode error:&error];
            
        }
        
        else    
        {
            NSLog(@"Game Kit requires peers be sent as an NSArray of Peer ID Strings"); 
            
        }
    }
    
    else if([self.matchOrSession isKindOfClass: [GKMatch class]])
    {
       
        if([peers isKindOfClass:[NSArray class]])
        {
            [self.matchOrSession sendData:dataToSend toPlayers:peers withDataMode:mode error:&error];
            
        }
        
        else    
        {
            NSLog(@"Game Center requires peers be sent as an NSArray of Peer ID Strings"); 

        }
        
    }
    
    else 
    {
        NSLog(@"Game Center Manager matchOrSession was not a GKMatch or a GKSession, we are unable to send data"); 
        
        
    }
    
    if(error != nil)
    {
        NSLog(@"An error occurred while sending data: %@", [error localizedDescription]);
    }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context;
{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];   
    
    if(dataString == nil)
    {
        [[GKVoiceChatService defaultVoiceChatService] receivedData:data fromParticipantID:peer];

        [dataString release];
        return;
    }
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataString, peer, session,  nil] forKeys:[NSArray arrayWithObjects: @"data", @"peer", @"session",  nil]];
    
    [dataString release];
    
    [self callDelegateOnMainThread: @selector(receivedData:) withArg: dataDictionary error: nil];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSString* dataString = [NSString stringWithUTF8String:[data bytes]];    

     NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dataString, playerID, match, nil] forKeys:[NSArray arrayWithObjects:@"data", @"peer", @"session", nil]];
    
    [self callDelegateOnMainThread: @selector(receivedData:) withArg: dataDictionary error: nil];
}


- (void)disconnect;
{
    if([self.matchOrSession isKindOfClass: [GKSession class]])
    {
        [self.matchOrSession disconnectFromAllPeers];
    }
    
    else if([self.matchOrSession isKindOfClass: [GKMatch class]])
    {
        [self.matchOrSession disconnect];
    }
}

- (void) callDelegateOnMainThread: (SEL) selector withArg: (id) arg error: (NSError*) err
{
	dispatch_async(dispatch_get_main_queue(), ^(void)
   {
	   [self callDelegate: selector withArg: arg error: err];
   });
}

- (void) callDelegate: (SEL) selector withArg: (id) arg error: (NSError*) err
{
	assert([NSThread isMainThread]);
	if([delegate respondsToSelector: selector])
	{
		if(arg != NULL)
			[delegate performSelector: selector withObject: arg withObject: err];
		
		else
			[delegate performSelector: selector withObject: err];
	}
	
	else
		NSLog(@"Missed Method");
}


-(void)dealloc
{
    [matchOrSession release]; matchOrSession = nil;
	[delegate release]; delegate = nil;
	[super dealloc];
}	

@end
