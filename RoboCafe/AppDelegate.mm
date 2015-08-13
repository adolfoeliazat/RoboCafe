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
    _position = nil;
    
    // Set up ALPS
    _ALPS = [[ALPSCore alloc] initWithOptions:RECORD_LENGTH :TDMA_SLOTS];
    _ALPS.delegate = self;
    [_ALPS start];
    
    // Set up websocket
    _wS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://solver.bitten-byte.com:30005"]]];
    _wS.delegate = self;
    [_wS open];

    return YES;
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
    _position = [_ALPS jsonPositionToDictionary:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        float x = [[_position objectForKey:@"x"] floatValue];
        float y = [[_position objectForKey:@"y"] floatValue];
        [[_vCSettings positionField] setText:[NSString stringWithFormat:@"X: %.2f, Y: %.2f", x, y]];
    });
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    _wSConnected = YES;
    [[_vCSettings solverConnectionStatusLabel] setText:@"Connected"];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor greenColor]];
    //[_wS send:@"{\"ALPS\" : {    \"TOA\" : {      \"t3\" : [        1.123032,        1.123511,        -1      ],      \"t1\" : [        0.618928,        0.6184697,        -1      ],      \"t6\" : [        -1,        -1,        -1      ],      \"t4\" : [        1.247115,        1.247011,        -1],      \"t2\" : [        0.7470946,        0.746928,        -1      ],      \"t5\" : [        -1,        -1,        -1      ]    } }}"];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    _wSConnected = NO;
    NSLog(@":( Websocket Failed With Error %@", error);
    _wS = nil;
    [[_vCSettings solverConnectionStatusLabel] setText:@"Disconnected"];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor redColor]];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    _wSConnected = NO;
    NSLog(@"WebSocket closed");
    _wS = nil;
    [[_vCSettings solverConnectionStatusLabel] setText:@"Disconnected"];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor redColor]];
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
