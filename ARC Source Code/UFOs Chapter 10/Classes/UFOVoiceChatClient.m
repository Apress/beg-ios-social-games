//
//  UFOVoiceChatClient.m
//  UFOs
//
//  Created by kyle on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UFOVoiceChatClient.h"

@implementation UFOVoiceChatClient

@synthesize session;

-(NSString *)participantID
{
    return self.session.peerID;
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID
{
    NSError *error = nil;
    
    if(![self.session sendData:data toPeers:[NSArray arrayWithObject: participantID] withDataMode:GKSendDataReliable error:&error])
    {
        NSLog(@"Unable to send data to peers: %@", [error localizedDescription]);
        
    }
}

- (void)receivedData:(NSData *)arbitraryData fromParticipantID:(NSString *)participantID
{
    [[GKVoiceChatService defaultVoiceChatService] receivedData:arbitraryData fromParticipantID:participantID];
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didReceiveInvitationFromParticipantID:(NSString *)participantID callID:(NSInteger)callID
{
	NSLog(@"Did Recieve Invitation");
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didNotStartWithParticipantID:(NSString *)participantID error:(NSError *)error
{
	NSLog(@"Did Not Start Invitation");
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didStartWithParticipantID:(NSString *)participantID
{
	NSLog(@"Did Start Invitation");
}

@end
