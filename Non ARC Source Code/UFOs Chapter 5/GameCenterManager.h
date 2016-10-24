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
- (void)scoreReported: (NSError*) error;
- (void)leaderboardUpdated: (NSArray *)scores error:(NSError *)error;
- (void)mappedPlayerIDToPlayer:(GKPlayer *)player error:(NSError *)error;
- (void)mappedPlayerIDsToPlayers:(NSArray *)players error:(NSError *)error;
- (void)localPlayerScore:(GKScore *)score error:(NSError *)error;
- (void)achievementSubmitted:(GKAchievement *)achievement error:(NSError *)error;
- (void)achievementEarned:(GKAchievementDescription *)achievement;
- (void)achievementDescriptionsLoaded:(NSArray *)descriptions error:(NSError *)error;
- (void)playerActivity:(NSNumber *)activity error:(NSError *)error;
- (void)playerActivityForGroup:(NSDictionary *)activityDict error:(NSError *)error;

@end

@interface GameCenterManager : NSObject <GameCenterManagerDelegate> 
{
	id <GameCenterManagerDelegate, NSObject> delegate;
	NSMutableDictionary* earnedAchievementCache;

}

@property(nonatomic, retain) id <GameCenterManagerDelegate, NSObject> delegate;
@property(nonatomic, retain) NSMutableDictionary* earnedAchievementCache;


+ (BOOL)isGameCenterAvailable;
//- (void)authenticateLocalUser;
- (void)authenticateLocalUserModern;
- (void)callDelegateOnMainThread:(SEL)selector withArg:(id) arg error:(NSError*) err;
- (void)callDelegate:(SEL)selector withArg:(id)arg error:(NSError*) err;
- (void)retrieveFriendsList;
- (void)playersForIDs:(NSArray *)playerIDs;
- (void)playerforID:(NSString *)playerID;
- (void)reportScore: (int64_t) score forCategory: (NSString*) category;
- (void)storeScoreForLater:(NSData *)scoreData;
- (void)submitAllSavedScores;
- (void)retrieveScoresForCategory:(NSString *)category withPlayerScope:(GKLeaderboardPlayerScope)playerScope timeScope:(GKLeaderboardTimeScope)timeScope withRange: (NSRange)range;
- (void)mapPlayerIDtoPlayer:(NSString*)playerID;
- (void)mapPlayerIDstoPlayers:(NSArray*)playerIDs;
- (void)retrieveLocalScoreForCategory:(NSString *)category;
- (void)submitAchievement:(NSString*)identifier percentComplete:(double)percentComplete;
- (double)percentageCompleteOfAchievementWithIdentifier:(NSString *)identifier;
- (BOOL)achievementWithIdentifierIsComplete:(NSString *)identifier;
- (void)populateAchievementCache;
- (void)resetAchievements;
- (void)retrieveAchievmentMetadata;
- (void)storeAchievementToSubmitLater:(GKAchievement *)achievement;
- (void)submitAllSavedAchievements;
- (void)setupInvitationHandler:(id)inivationHandler;
- (void)findActivityForPlayerGroup:(NSUInteger)playerGroup;
- (void)findAllActivity;
@end
