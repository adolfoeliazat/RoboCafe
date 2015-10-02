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


    NSString* newCafeWSURL = [root valueForKey:@"setCafeStatusWSURL"];
    if (newCafeWSURL != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            appDelegate.vCCafeSettings.cafeWSEntry.text = newCafeWSURL;
            [appDelegate.vCCafeSettings cafeWSEditingEnd:self];
        }];
    }

    NSString* newLocationWSURL = [root valueForKey:@"setLocationWSURL"];
    if (newLocationWSURL != nil) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            appDelegate.vCCafeSettings.locationWSEntry.text = newLocationWSURL;
            [appDelegate.vCCafeSettings locationWSEditingEnd:self];
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
