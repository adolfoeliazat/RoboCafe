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
    //NSLog(@"AppConfigWS received message: %@", message);
    
    NSError *error = nil;
    NSData* messageAsData;
    
    if ([message isKindOfClass:[NSString class]]) {
        @try {
            messageAsData = [message dataUsingEncoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            NSLog(@"Error: Unhandled exception. Bad packet? Exc: %@", exception);
            return;
        }
    } else if ([message isKindOfClass:[NSData class]]) {
        messageAsData = message;
        message = [[NSString alloc] initWithData:messageAsData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"Unknown object type from CafeOrderWS");
        return;
    }
    
    NSArray* command = [NSJSONSerialization JSONObjectWithData:messageAsData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON >>>%@<<<. Error: %@", message, error);
        return;
    }
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
    
    self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
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
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
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
