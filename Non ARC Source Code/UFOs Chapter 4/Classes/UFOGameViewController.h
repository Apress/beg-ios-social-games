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
	
	UIImageView *myPlayerImageView;
	UIImageView *currentAbductee;
	UIImageView *tractorBeamImageView;

	NSMutableArray *cowArray;
	
	float movementSpeed;
	float accelerometerDamp;
	float accelerometer0Angle;
	
	float score;
	
	GameCenterManager *gcManager;
	
	IBOutlet UIView *achievementCompletionView;
	IBOutlet UILabel *achievementcompletionLabel;
	
	NSTimer *timer;
    
    CMMotionManager *motionManager;


}

@property(nonatomic, retain) GameCenterManager *gcManager;
@property(nonatomic, retain) CMMotionManager *motionManager;


-(IBAction)exitAction:(id)sender;

-(void)spawnCow;
-(void)updateCowPaths;
-(void)abductCow:(UIImageView *)cowImageView;
-(void)finishAbducting;
-(void)movePlayer:(float)vertical :(float)horizontal;
-(UIImageView *)hitTest;
-(void)tickThreeSeconds;
-(void)motionOccurred:(CMAccelerometerData *)accelerometerData;


@end
