//
//  CafeOrderWSDelegate.m
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/13/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "CafeOrderWSDelegate.h"
#import "AppDelegate.h"

@implementation CafeOrderWSDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"CafeOrderWS received message: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"CafeOrderWS Opened");
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate setValue:[NSNumber numberWithBool:YES] forKey:@"cafeOrderWSState"];
    appDelegate.cafeOrderWSState = WebsocketStateConnected;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    //NSLog(@"CafeOrderWS failed with error: %@", error);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate setValue:[NSNumber numberWithBool:NO] forKey:@"cafeOrderWSState"];
    appDelegate.cafeOrderWSState = WebsocketStateDisconnected;
    
    [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(reconnectWebSocket:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"CafeOrderWS closed (code %ld, wasClean %d)", (long)code, wasClean);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate setValue:[NSNumber numberWithBool:NO] forKey:@"cafeOrderWSState"];
    appDelegate.cafeOrderWSState = WebsocketStateDisconnected;
    
    if (!wasClean) {
        [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                         target:self
                                       selector:@selector(reconnectWebSocket:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)reconnectWebSocket:(NSTimer *)timer {
    if (appDelegate.cafeOrderWSState == WebsocketStateDisconnected) {
        //NSLog(@"Attempting to reconnect CafeOrderWS");
        [appDelegate cafeOrderWSConnect];
    }
}

@end
