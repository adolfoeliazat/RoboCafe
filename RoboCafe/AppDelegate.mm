//
//  AppDelegate.m
//  RoboCafe
//
//  Created by Patrick Lazik on 8/9/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerSettings.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _wSConnected = NO;
    
    // Set up ALPS
    _ALPS = [[ALPSCore alloc] initWithOptions:RECORD_LENGTH :6];
    _ALPS.delegate = self;
    [_ALPS start];
    
    // Set up websocket
    _wS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.1.3:30000"]]];
    _wS.delegate = self;
    [_wS open];
    
    // Reporting websocket
    _reportWSConnected = NO;
    //_reportWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://141.212.11.234:8081"]]];
    _reportWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://pfet-v2.eecs.umich.edu:8080"]]];
    _reportWS.delegate = self;
    [_reportWS open];

    return YES;
}

- (void)sendToRobotWS:(NSDictionary *)data {
    
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    if (json != nil && error == nil) {
        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        
        if (_reportWSConnected) {
            NSLog(@"Sending to robot WS: %@", jsonString);
            [_reportWS send:jsonString];
        }
    } else if (error != nil) {
        NSLog(@"Error sending to Robot WS: %@", error);
    }
}

/*----------ALPS Methods-----------*/

- (void)ALPSDidReceiveData:(NSArray*) toa :(NSArray*) rssi{
    NSLog(@"Got ALPS data");
    
    // Send ALPS data to solver via websocket
    if(_wSConnected){
        NSData *jsonData = [_ALPS toaAndRSSIToJSON:toa :rssi];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        [_wS send:jsonString];
    }
    // Update TDOA values
    NSString *tdoaString = [_ALPS toaToTDOAString:toa];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[_vCSettings tdoaDataField] setText:tdoaString];
    });
}


/*----------Websocket Methods-----------*/

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"Got message");
    NSLog(message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    if (webSocket == _reportWS) {
        _reportWSConnected = YES;
    } else if (webSocket == _wS) {
        _wSConnected = YES;
        [[_vCSettings solverConnectionStatusLabel] setText:@"Connected"];
        [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor greenColor]];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    if (webSocket == _reportWS) {
        _reportWSConnected = NO;
        _reportWS = nil;
    } else if (webSocket == _wS) {
        _wSConnected = NO;
        _wS = nil;
        [[_vCSettings solverConnectionStatusLabel] setText:@"Disconnected"];
        [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor redColor]];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    if (webSocket == _reportWS) {
        _reportWSConnected = NO;
        _reportWS = nil;
    } else if (webSocket == _wS) {
        _wSConnected = NO;
        _wS = nil;
        [[_vCSettings solverConnectionStatusLabel] setText:@"Disconnected"];
        [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor redColor]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
