//
//  GameCenterGameViewController.m
//  GameCenter
//
//  Created by Kyle Richter on 11/14/10.
//  Copyright 2010 Dragon Forged Software. All rights reserved.
//

#import "UFOGameViewController.h"	
#import <QuartzCore/QuartzCore.h>

@implementation UFOGameViewController

@synthesize gcManager;
@synthesize motionManager;


#pragma mark Init and Teardown
#pragma mark -

- init 
{
    if (self != [super init]) 
		return nil;
	
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.05;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error)
     {
         
         [self motionOccurred:accelerometerData];
         
         if(error)
         {
             
             NSLog(@"%@", error);
         }
     }];
	
    return self;
}

-(void)viewDidLoad
{
	[self.gcManager setDelegate: self];
	
	[super viewDidLoad];
	
	accelerometerDamp = 0.3f;
	accelerometer0Angle = 0.6f;
	movementSpeed = 15;
	
	CGRect playerFrame = CGRectMake(100, 70, 80, 34);
	myPlayerImageView = [[UIImageView alloc] initWithFrame: playerFrame];
	myPlayerImageView.animationDuration = 0.75;
	myPlayerImageView.animationRepeatCount = 99999;
	NSArray *imageArray = [NSArray arrayWithObjects: [UIImage imageNamed: @"Saucer1.png"], [UIImage imageNamed: @"Saucer2.png"], nil];
	myPlayerImageView.animationImages = imageArray; 
	[myPlayerImageView startAnimating];
	[self.view addSubview: myPlayerImageView];
	
	cowArray = [[NSMutableArray alloc] init];
	tractorBeamImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
	score = 0;
	scoreLabel.text = [NSString stringWithFormat: @"SCORE %05.0f", score];
	
	for(int x = 0; x < 5; x++)
	{
		[self spawnCow];
	}	
	
	[self updateCowPaths];
}	

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear: animated];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:3.0
											 target:self
										   selector:@selector(tickThreeSeconds)
										   userInfo:nil
											repeats:YES];
}	


-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
	
	[timer invalidate];
	timer = nil;
}	
	 
-(void)tickThreeSeconds
{
	if([self.gcManager achievementWithIdentifierIsComplete: @"com.dragonforged.ufo.play5"])
		return;	
	else
	{
		double percentComplete = [self.gcManager percentageCompleteOfAchievementWithIdentifier:@"com.dragonforged.ufo.play5"];	
		percentComplete++;
		[self.gcManager submitAchievement:@"com.dragonforged.ufo.play5" percentComplete:percentComplete];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//only allow landscape orientations
	if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
		return YES;
	
	return NO;
}



- (void)dealloc 
{
	[gcManager release]; gcManager = nil;
	[cowArray release];
    [super dealloc];
}

#pragma mark Input and Actions
#pragma mark -

-(void)motionOccurred:(CMAccelerometerData *)accelerometerData;
{
    //Use a basic low-pass filter to only keep the gravity in the accelerometer values
	accel[0] = accelerometerData.acceleration.x * accelerometerDamp + accel[0] * (1.0 - accelerometerDamp);
	accel[1] = accelerometerData.acceleration.y * accelerometerDamp + accel[1] * (1.0 - accelerometerDamp);
	accel[2] = accelerometerData.acceleration.z * accelerometerDamp + accel[2] * (1.0 - accelerometerDamp);
	
	if(!tractorBeamOn)
		[self movePlayer:accel[0] :accel[1]];
}

-(void) movePlayer:(float)vertical :(float)horizontal;
{
	vertical += accelerometer0Angle;
	
	if(vertical > .50)
		vertical = .50;
	else if (vertical < -.50)
		vertical = -.50;
	
	if(horizontal > .50)
		horizontal = .50;
	else if (horizontal < -.50)
		horizontal = -.50;
	
	CGRect playerFrame = myPlayerImageView.frame; 
	
	if ((vertical < 0 && playerFrame.origin.y < 120) || (vertical > 0 && playerFrame.origin.y > 20)) 
		playerFrame.origin.y -= vertical*movementSpeed;
	
	if ((horizontal < 0 && playerFrame.origin.x < 440) || (horizontal > 0 && playerFrame.origin.x > 0)) 
		playerFrame.origin.x -= horizontal*movementSpeed;

		
	myPlayerImageView.frame = playerFrame;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	currentAbductee = nil;
	
	tractorBeamOn = YES;
	
	tractorBeamImageView.frame = CGRectMake(myPlayerImageView.frame.origin.x+25, myPlayerImageView.frame.origin.y+10, 28, 318);
	tractorBeamImageView.animationDuration = 0.5;
	tractorBeamImageView.animationRepeatCount = 99999;
	NSArray *imageArray = [NSArray arrayWithObjects: [UIImage imageNamed: @"Tractor1.png"], [UIImage imageNamed: @"Tractor2.png"], nil];
	
	tractorBeamImageView.animationImages = imageArray;
	[tractorBeamImageView startAnimating];
	
	[self.view insertSubview:tractorBeamImageView atIndex:4];
	
	UIImageView *cowImageView = [self hitTest]; 
	
	if(cowImageView)
	{
		currentAbductee = cowImageView;
		[self abductCow: cowImageView];
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	tractorBeamOn = NO;
	
	[tractorBeamImageView removeFromSuperview];
	
	if(currentAbductee)
	{
		[UIView beginAnimations: @"dropCow" context:nil];
		[UIView setAnimationDuration: 1.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationBeginsFromCurrentState: YES];
		
		CGRect frame = currentAbductee.frame;
		
		frame.origin.y = 260;
		frame.origin.x = myPlayerImageView.frame.origin.x +15;
		
		currentAbductee.frame = frame;
		
		[UIView commitAnimations];
	}
	
	currentAbductee = nil;
}

-(IBAction)exitAction:(id)sender;
{
	[[self navigationController] popViewControllerAnimated: YES];
	[self.gcManager reportScore:score forCategory:@"com.dragonforged.ufo.single"];
}

#pragma mark Gameplay
#pragma mark -


-(void)spawnCow;
{
	UIImageView *cowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arc4random()%480, 260, 64, 42)];
	cowImageView.image = [UIImage imageNamed: @"Cow1.png"];
	[self.view addSubview: cowImageView];
	[cowArray addObject: cowImageView];

	[cowImageView release];
}

-(void)updateCowPaths
{
	for(int x = 0; x < [cowArray count]; x++)
	{
		UIImageView *tempCow = [cowArray objectAtIndex: x];
		
		if(tempCow != currentAbductee)
		{
			[UIView beginAnimations:@"cowWalk" context:nil];
			[UIView setAnimationDuration: 3.0];
			[UIView setAnimationCurve:UIViewAnimationCurveLinear];
			
			float currentX = tempCow.frame.origin.x;
			float newX = currentX + arc4random()%100-50;
			
			if(newX > 480)
				newX = 480;
			if(newX < 0)
				newX = 0;
			
			if(tempCow != currentAbductee)
				tempCow.frame = CGRectMake(newX, 260, 64, 42);
			
			[UIView commitAnimations];
			
			tempCow.animationDuration = 0.75;
			tempCow.animationRepeatCount = 99999;

			//flip cow
			if(newX < currentX)
			{	
				NSArray *flippedCowImageArray = [NSArray arrayWithObjects: [UIImage imageNamed: @"Cow1Reversed.png"], [UIImage imageNamed: @"Cow2Reversed.png"], [UIImage imageNamed: @"Cow3Reversed.png"], nil];
				tempCow.animationImages = flippedCowImageArray;
			}	
			else
			{
				NSArray *cowImageArray = [NSArray arrayWithObjects: [UIImage imageNamed: @"Cow1.png"], [UIImage imageNamed: @"Cow2.png"], [UIImage imageNamed: @"Cow3.png"], nil];
				tempCow.animationImages = cowImageArray;
			}
			
			[tempCow startAnimating];
		}
	}
	
	//change the paths for the cows every 3 seconds
	[self performSelector:@selector(updateCowPaths) withObject:nil afterDelay:3.0];
}


-(void)abductCow:(UIImageView *)cowImageView;
{
	[UIView beginAnimations: @"abduct" context:nil];
	[UIView setAnimationDuration: 4.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(finishAbducting)];
	[UIView setAnimationBeginsFromCurrentState: YES];

	CGRect frame = cowImageView.frame;
	frame.origin.y = myPlayerImageView.frame.origin.y;
	cowImageView.frame = frame;
	
	[UIView commitAnimations];
}

-(void)finishAbducting;
{
	if(!currentAbductee || !tractorBeamOn)
		return;
	
	[cowArray removeObjectIdenticalTo:currentAbductee];
	
	[tractorBeamImageView removeFromSuperview];
	
	tractorBeamOn = NO;
	
	score++;
	scoreLabel.text = [NSString stringWithFormat: @"SCORE %05.0f", score];
	
	[currentAbductee.layer removeAllAnimations];
	[currentAbductee removeFromSuperview];
	
	currentAbductee = nil;
	
	[self spawnCow];
	
	if(![self.gcManager achievementWithIdentifierIsComplete:@"com.dragonforged.ufo.aduct1"])
	{
		[self.gcManager submitAchievement:@"com.dragonforged.ufo.aduct1" percentComplete:100];
	}	
	
	if(![self.gcManager achievementWithIdentifierIsComplete:@"com.dragonforged.ufo.abduct25"])
	{
		double percentComplete = [self.gcManager percentageCompleteOfAchievementWithIdentifier:@"com.dragonforged.ufo.abduct25"];
		percentComplete += 4;
		[self.gcManager submitAchievement:@"com.dragonforged.ufo.abduct25" percentComplete:percentComplete];
	}	
}

-(UIImageView *)hitTest
{
	if(!tractorBeamOn)
		return nil;
	
	for(int x = 0; x < [cowArray count]; x++)
	{
		UIImageView *tempCow = [cowArray objectAtIndex: x];
		CALayer *cowLayer= [[tempCow layer] presentationLayer];
		CGRect cowFrame = [cowLayer frame];
		
		if (CGRectIntersectsRect(cowFrame, tractorBeamImageView.frame))
		{
			tempCow.frame = cowLayer.frame;
			[tempCow.layer removeAllAnimations];
			return tempCow;
		}	
	}
	
	return nil;
}

#pragma mark Game Center Delegate
#pragma mark -

- (void)scoreReported: (NSError*) error;
{
	if(error)
		NSLog(@"There was an error in reporting the score: %@", [error localizedDescription]);
			  
	else	
		NSLog(@"Score submitted");
	
}	

- (void)achievementSubmitted:(GKAchievement *)achievement error:(NSError *)error;
{
	if(error)
		NSLog(@"There was an error in reporting the achievement: %@", [error localizedDescription]);
	
	else	
		NSLog(@"achievement submitted");
}

- (void)achievementEarned:(GKAchievementDescription *)achievement;
{	
	achievementCompletionView.frame = CGRectMake(0, 320, 480, 25);
	[self.view addSubview: achievementCompletionView];
	achievementcompletionLabel.text = achievement.achievedDescription;
	
	[UIView beginAnimations:@"SlideInAchievement" context:nil];
	[UIView setAnimationDuration: 0.5];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector(achievementEarnedAnimationDone)];
	achievementCompletionView.frame = CGRectMake(0, 295, 480, 25);
	[UIView commitAnimations];
}	
												   
-(void)achievementEarnedAnimationDone
{						
	[UIView beginAnimations:@"SlideInAchievement" context:nil];
	[UIView setAnimationDelay: 5.0];
	[UIView setAnimationDuration: 1.0];
	achievementCompletionView.frame = CGRectMake(0, 320, 480, 25);
	[UIView commitAnimations];
}											

@end
