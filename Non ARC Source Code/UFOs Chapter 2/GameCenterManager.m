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
                 
             }
         }];
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
	[delegate release]; delegate = nil;
	[super dealloc];
}	

@end
