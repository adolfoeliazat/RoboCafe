//
//  AppConfigWSDelegate.m
//  RoboCafe
//
//  Created by Patrick Pannuto on 9/17/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "AppConfigWSDelegate.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewControllerCafeSettings.h"

@implementation AppConfigWSDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"AppConfigWS received message: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"AppConfigWS Opened");
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.appConfigWSState = WebsocketStateConnected;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.appConfigWSState = WebsocketStateDisconnected;
    
    [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(reconnectWebSocket:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"AppConfigWS closed (wasClean %d)", wasClean);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.appConfigWSState = WebsocketStateDisconnected;
    
    if (!wasClean) {
        [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                         target:self
                                       selector:@selector(reconnectWebSocket:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)reconnectWebSocket:(NSTimer *)timer {
    if (appDelegate.appConfigWSState == WebsocketStateDisconnected) {
        [appDelegate appConfigWSConnect];
    }
}

@end
