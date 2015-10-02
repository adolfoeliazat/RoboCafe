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
#import "ViewControllerSettings.h"
#import "ViewControllerCafeSettings.h"

@implementation AppConfigWSDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"AppConfigWS received message: %@", message);
    
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
    
    NSArray* root = [NSJSONSerialization JSONObjectWithData:messageAsData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON >>>%@<<<. Error: %@", message, error);
        return;
    }
    
    
    NSDictionary* setUserDefaults = [root valueForKey:@"setUserDefaults"];
    if (setUserDefaults != nil) {
        NSArray* keys = [setUserDefaults allKeys];
        for (id key in keys) {
            [[NSUserDefaults standardUserDefaults] setObject:[setUserDefaults objectForKey:key] forKey:key];
        }

        // This is a bit of a hack, but works
        appDelegate.item1ordered = appDelegate.item1ordered;
        appDelegate.item2ordered = appDelegate.item2ordered;
        appDelegate.item3ordered = appDelegate.item3ordered;
    }

    NSString* newALPSWSURL = [root valueForKey:@"setALPSWSURL"];
    if (newALPSWSURL != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [appDelegate.alpsWSReconnectTimer invalidate];
            if (appDelegate.alpsWSState != WebsocketStateDisconnected) {
                [appDelegate.alpsWS close];
            }
            [[NSUserDefaults standardUserDefaults] setObject:newALPSWSURL forKey:@"alps_ws_address"];
            appDelegate.alpsWSAddress = newALPSWSURL;
            appDelegate.vCSettings.alpsWSEntry.text = newALPSWSURL;
            [appDelegate alpsWSConnect];
        }];
    }

    NSString* newCafeWSURL = [root valueForKey:@"setCafeStatusWSURL"];
    if (newCafeWSURL != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [appDelegate.cafeOrderWSDelegate.reconnectTimer invalidate];
            if (appDelegate.cafeOrderWSState != WebsocketStateDisconnected) {
                [appDelegate.cafeOrderWS close];
            }
            [[NSUserDefaults standardUserDefaults] setObject:newCafeWSURL forKey:@"cafe_ws_address"];
            appDelegate.cafeOrderWSAddress = newCafeWSURL;
            appDelegate.vCCafeSettings.cafeWSEntry.text = newCafeWSURL;
            [appDelegate cafeOrderWSConnect];
        }];
    }

    NSString* newLocationWSURL = [root valueForKey:@"setLocationWSURL"];
    if (newLocationWSURL != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [appDelegate.locationAnnounceWSDelegate.reconnectTimer invalidate];
            if (appDelegate.locationAnnounceWSState != WebsocketStateDisconnected) {
                [appDelegate.locationAnnounceWS close];
            }
            [[NSUserDefaults standardUserDefaults] setObject:newLocationWSURL forKey:@"loc_announce_ws_address"];
            appDelegate.locationAnnounceWSAddress = newLocationWSURL;
            appDelegate.vCCafeSettings.locationWSEntry.text = newLocationWSURL;
            [appDelegate locationAnnounceWSConnect];
        }];
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
