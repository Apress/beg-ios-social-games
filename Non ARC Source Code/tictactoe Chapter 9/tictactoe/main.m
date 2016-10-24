//
//  main.m
//  tictactoe
//
//  Created by kyle on 7/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "tictactoeAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([tictactoeAppDelegate class]));
    }
    return retVal;
}
