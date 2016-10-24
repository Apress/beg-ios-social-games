//
//  GameCenterGameViewController.h
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface UFOGameViewController : UIViewController <UIAccelerometerDelegate>
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
    
    CMMotionManager *motionManager;
	
	float score;
}

@property(nonatomic, strong) CMMotionManager *motionManager;


-(void)spawnCow;
-(void)updateCowPaths;
-(void)abductCow:(UIImageView *)cowImageView;
-(void)finishAbducting;
-(void)movePlayer:(float)vertical :(float)horizontal;
-(UIImageView *)hitTest;

@end
