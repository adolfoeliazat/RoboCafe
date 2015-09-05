//
//  LocationAnnounceWSDelegate.m
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/13/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "LocationAnnounceWSDelegate.h"
#import "AppDelegate.h"

@implementation LocationAnnounceWSDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"LocationAnnounceWS received message: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"LocationAnnounceWS Opened");
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.locationAnnounceWSState = WebsocketStateConnected;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    //NSLog(@"LocationAnnounceWS failed with error: %@", error);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.locationAnnounceWSState = WebsocketStateDisconnected;
    
    [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(reconnectWebSocket:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"LocationAnnounceWS closed (wasClean %d)", wasClean);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.locationAnnounceWSState = WebsocketStateDisconnected;
    
    if (!wasClean) {
        [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                         target:self
                                       selector:@selector(reconnectWebSocket:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)reconnectWebSocket:(NSTimer *)timer {
    if (appDelegate.locationAnnounceWSState == WebsocketStateDisconnected) {
        //NSLog(@"Attempting to reconnect CafeOrderWS");
        [appDelegate locationAnnounceWSConnect];
    }
}

@end
