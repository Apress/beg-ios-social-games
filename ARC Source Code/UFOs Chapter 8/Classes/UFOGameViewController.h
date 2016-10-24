//
//  GameCenterGameViewController.h
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCenterManager.h"
#import <CoreMotion/CoreMotion.h>


@interface UFOGameViewController : UIViewController <UIAccelerometerDelegate, GameCenterManagerDelegate>
{
	float accelerationX;
	float accelerationY;
	UIAccelerationValue accel[3];

	BOOL tractorBeamOn;
	
	IBOutlet UILabel *scoreLabel;
    IBOutlet UILabel *enemeyScoreLabel;

	UIImageView *myPlayerImageView;
	UIImageView *currentAbductee;
	UIImageView *tractorBeamImageView;

    UIImageView *otherPlayerImageView;
    UIImageView *otherPlayerTractorBeamImageView;
	UIImageView *otherPlayerCurrentAbductee;

	NSMutableArray *cowArray;
	
	float movementSpeed;
	float accelerometerDamp;
	float accelerometer0Angle;
	
	float score;
	
	GameCenterManager *gcManager;
	
	IBOutlet UIView *achievementCompletionView;
	IBOutlet UILabel *achievementcompletionLabel;
	
	NSTimer *timer;
    
    BOOL gameIsMultiplayer;
    BOOL isHost;
    
    NSString *peerIDString;
    GKMatch *peerMatch;
    
    double randomHostNumber;
    CMMotionManager *motionManager;

}

@property(nonatomic, strong) GameCenterManager *gcManager;
@property(nonatomic, assign) BOOL gameIsMultiplayer;

@property(nonatomic, strong) NSString *peerIDString;
@property(nonatomic, strong) GKMatch *peerMatch;
@property(nonatomic, strong) CMMotionManager *motionManager;




-(IBAction)exitAction:(id)sender;

-(void)spawnCow;
-(void)updateCowPaths;
-(void)abductCow:(UIImageView *)cowImageView;
-(void)finishAbducting;
-(void)movePlayer:(float)vertical :(float)horizontal;
-(UIImageView *)hitTest;
-(void)tickThreeSeconds;

-(void)determineHost:(NSDictionary *)dataDictionary;
-(void)generateAndSendHostNumber;
-(void)drawEnemyShipWithData:(NSDictionary *)dataDictionary;
-(void)spawnCowFromNetwork:(int)x;
-(void)updateCowPathsFromNetwork:(NSDictionary *)dataDictionary;
-(void)beginTractorFromNetwork;
-(void)endTractorFromNetwork;
-(void)abductCowFromNetworkAtIndex:(int)x;
-(void)finishAbductingFromNetwork;

@end
