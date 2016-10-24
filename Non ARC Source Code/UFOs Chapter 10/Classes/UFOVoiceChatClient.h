//
//  UFOVoiceChatClient.h
//  UFOs
//
//  Created by kyle on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>

@interface UFOVoiceChatClient : NSObject <GKVoiceChatClient>
{
    GKSession *session;
    
}

@property(nonatomic, retain) GKSession *session;

@end
