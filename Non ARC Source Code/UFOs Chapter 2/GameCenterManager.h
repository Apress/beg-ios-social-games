//
//  GameCenterManager.h
//  UFOs
//
//  Created by Kyle Richter on 1/25/11.
//  Copyright 2011 Dragon Forged Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@protocol GameCenterManagerDelegate <NSObject>
@optional
- (void)processGameCenterAuthentication:(NSError*)error;
- (void)friendsFinishedLoading:(NSArray *)friends error:(NSError *)error;
- (void)playerDataLoaded:(NSArray *)players error:(NSError *)error;
@end

@interface GameCenterManager : NSObject <GameCenterManagerDelegate> 
{
	id <GameCenterManagerDelegate, NSObject> delegate;

}

@property(nonatomic, retain) id <GameCenterManagerDelegate, NSObject> delegate;

+ (BOOL)isGameCenterAvailable;
//- (void)authenticateLocalUser;
- (void)callDelegateOnMainThread:(SEL)selector withArg:(id) arg error:(NSError*) err;
- (void)callDelegate:(SEL)selector withArg:(id)arg error:(NSError*) err;
- (void)retrieveFriendsList;
- (void)playersForIDs:(NSArray *)playerIDs;
- (void)playerforID:(NSString *)playerID;
- (void)authenticateLocalUserModern;

@end
