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
@synthesize facebookAccount;

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
    
    
    NSLog(@"Past: %@",[NSDate distantPast]);
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//only allow landscape orientations
	if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
		return YES;
	
	return NO;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Score" message:@"Do you want to post your score to your Facebook wall?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Facebook Composer", @"Custom Post", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //facebook composer
    if(buttonIndex == 1)
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewController *facebookController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result)
            {
                if (result == SLComposeViewControllerResultCancelled)
                {
                    NSLog(@"Facebook Controller Canceled");
                    [[self navigationController] popViewControllerAnimated: YES];
                    [self.gcManager reportScore:score forCategory:@"com.dragonforged.ufo.single"];
                }
                
                else
                {
                    NSLog(@"Facebook Controller Done");
                    [[self navigationController] popViewControllerAnimated: YES];
                    [self.gcManager reportScore:score forCategory:@"com.dragonforged.ufo.single"];
                }
                
                [facebookController dismissViewControllerAnimated:YES completion:nil];
                
            };
            
            facebookController.completionHandler = myBlock;
            
            [facebookController setInitialText:[NSString stringWithFormat: @"I just abducted %0.0f cow(s) in UFOs for iPhone!", score]];
            [facebookController addImage:[UIImage imageNamed:@"Cow1.png"]];
            [facebookController addURL:[NSURL URLWithString:@"http://bit.ly/19ak0Uv"]];
            
            [self presentViewController:facebookController animated:YES completion:nil];
        }
        
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook Composer is not available, make sure an account is configured in Settings.app" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
        }

    }
    
    //custom facebook post
    else if(buttonIndex == 2)
    {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = @{
                                  ACFacebookAudienceKey : ACFacebookAudienceEveryone,
                                  ACFacebookAppIdKey : @"165243936994502",
                                  ACFacebookPermissionsKey : @[@"email"]};
        
        [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 NSLog(@"Basic access granted");
                 
                 NSDictionary *secondOptions = @{
                             ACFacebookAudienceKey : ACFacebookAudienceEveryone,
                             ACFacebookAppIdKey : @"165243936994502",
                             ACFacebookPermissionsKey : @[@"publish_stream"]};
                 
                 [accountStore requestAccessToAccountsWithType:facebookAccountType options:secondOptions completion:^(BOOL granted, NSError *error)
                  {
                      if (granted)
                      {
                          NSLog(@"Extended access granted");

                          NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                          self.facebookAccount = [accounts lastObject];
                          
                          [self performSelectorOnMainThread:@selector(postFromFacebook) withObject:nil waitUntilDone:NO];
                      }
                      
                      else
                      {
                          [self performSelectorOnMainThread:@selector(displayAlertWithString:) withObject:error waitUntilDone:NO];
                      }
                  }];


             }
             
             else
             {
                 NSLog(@"Basic access denied: %@", [error localizedDescription]);
             }
         }];
        


    }
    
    
    else if(buttonIndex == 0)
    {
        [[self navigationController] popViewControllerAnimated: YES];
        [self.gcManager reportScore:score forCategory:@"com.dragonforged.ufo.single"];
        
    }
}

-(void)postFromFacebook
{
    BOOL attachedImage = YES;
    NSURL *feedURL = nil;
    
    if(attachedImage)
    {
        feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
    }
    
    else
    {
        feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:[NSString stringWithFormat: @"I just abducted %0.0f cow(s) in UFOs for iPhone!", score] forKey:@"message"];
    
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodPOST
                              URL:feedURL
                              parameters:parameters];
    
    if(attachedImage)
    {
        NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"Saucer1.png"]);
        [feedRequest addMultipartData:imageData withName:@"source" type:@"multipart/form-data" filename:@"Image"];
    }
    
    feedRequest.account = self.facebookAccount;
    
    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         
         NSLog(@"Facebook post statusCode: %u", [urlResponse statusCode]);
         
         if([urlResponse statusCode] == 200)
         {
             [self performSelectorOnMainThread:@selector(displayAlertWithString:) withObject:@"Your message has been posted to Facebook" waitUntilDone:NO];
             
         }
         
         else if(error != nil)
         {
             [self performSelectorOnMainThread:@selector(displayAlertWithString:) withObject:error waitUntilDone:NO];
         }
         
     }];
}

-(void)displayAlertWithString:(NSString *)alertString
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertString delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    
}

#pragma mark Gameplay
#pragma mark -


-(void)spawnCow;
{
	UIImageView *cowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(arc4random()%480, 260, 64, 42)];
	cowImageView.image = [UIImage imageNamed: @"Cow1.png"];
	[self.view addSubview: cowImageView];
	[cowArray addObject: cowImageView];

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
	
	//make a new cow
	[self spawnCow];
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

	

@end
