//
//  AppDelegate.m
//  RoboCafe
//
//  Created by Patrick Lazik on 8/9/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewControllerSettings.h"
#import "ViewControllerCafeSettings.h"
#import "LocationAnnounceWSDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set up default parameter values
    NSDictionary* userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithFloat:DEFAULT_ALPS_THRESHOLD_DIVISOR], @"alps_thresholdDivisor",
                                          [NSNumber numberWithFloat:DEFAULT_ALPS_THRESHOLD_MULTIPLIER], @"alps_thresholdMultiplier",
                                          DEFAULT_ALPS_WEBSOCKET, @"alps_ws_address",
                                          DEFAULT_CAFE_WEBSOCKET, @"cafe_ws_address",
                                          DEFAULT_LOC_ANNOUNCE_WEBSOCKET, @"loc_announce_ws_address",
                                          DEFAULT_APP_CONFIG_WEBSOCKET, @"app_config_ws_address",
                                          @"Item #1", @"item1",
                                          @"Item #2", @"item2",
                                          @"Item #3", @"item3",
                                          [NSNumber numberWithInt:1], @"debug_post_location_x",
                                          [NSNumber numberWithInt:2], @"debug_post_location_y",
                                          nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    _position = nil;
    
    // Set up ALPS
    _ALPS = [[ALPSCore alloc] initWithOptions:RECORD_LENGTH :TDMA_SLOTS];
    _ALPS.delegate = self;
    [_ALPS start];
    
    // ALPS websocket
    self.alpsWSAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"alps_ws_address"];
    [self alpsWSConnect];
    
    // Café reporting websocket
    self.cafeOrderWSAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"cafe_ws_address"];
    self.cafeOrderWSDelegate = [[CafeOrderWSDelegate alloc] init];
    [self cafeOrderWSConnect];
    
    // Location result reporting websocket
    self.locationAnnounceWSAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"loc_announce_ws_address"];
    self.locationAnnounceWSDelegate = [[LocationAnnounceWSDelegate alloc] init];
    [self locationAnnounceWSConnect];
    
    // App configuration websocket
    self.appConfigWSAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"app_config_ws_address"];
    self.appConfigWSDelegate = [[AppConfigWSDelegate alloc] init];
    [self appConfigWSConnect];
    
    // Debugging support options
    _debugForceEnableAllButtons = [[NSNumber alloc] initWithBool:NO];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    return YES;
}

- (void)cafeOrderWSConnect {
    self.cafeOrderWSState = WebsocketStateConnecting;
    self.cafeOrderWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_cafeOrderWSAddress]]];
    self.cafeOrderWS.delegate = self.cafeOrderWSDelegate;
    [self.cafeOrderWS open];
}

- (void)locationAnnounceWSConnect {
    self.locationAnnounceWSState = WebsocketStateConnecting;
    self.locationAnnounceWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.locationAnnounceWSAddress]]];
    self.locationAnnounceWS.delegate = self.locationAnnounceWSDelegate;
    [self.locationAnnounceWS open];
}

- (void)appConfigWSConnect {
    self.appConfigWSState = WebsocketStateConnecting;
    self.appConfigWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.appConfigWSAddress]]];
    self.appConfigWS.delegate = self.appConfigWSDelegate;
    [self.appConfigWS open];
}

- (void)sendToWS: (NSDictionary *)data :(SRWebSocket*) WS{
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    if (json != nil && error == nil) {
        NSString *jsonString = [[NSString alloc] initWithData:json encoding: NSUTF8StringEncoding];
        [WS send:jsonString];
    } else if (error != nil) {
        NSLog(@"Error sending to %@ WS: %@", WS, error);
    }
}

- (void)sendToCafeOrderWS:(NSDictionary *)data {
    if (self.cafeOrderWSState == WebsocketStateConnected) {
        [self sendToWS:data :_cafeOrderWS];
    }
}

- (void)sendToLocationAnnounceWS :(NSDictionary*) data {
    if (self.locationAnnounceWSState == WebsocketStateConnected) {
        [self sendToWS :data :_locationAnnounceWS];
    }
}

- (void)sendToAppConfigWS:(NSDictionary*) data {
    if (self.appConfigWSState == WebsocketStateConnected) {
        [self sendToWS:data :_appConfigWS];
    }
}

/*----------ALPS Methods-----------*/

- (void)ALPSDidReceiveData:(NSArray*) toa :(NSArray*) rssi{
    NSLog(@"Got ALPS data");
    
    // Send ALPS data to solver via websocket
    if(self.alpsWSState == WebsocketStateConnected){
        NSData *jsonData = [_ALPS toaAndRSSIToJSON:toa :rssi];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        [self.alpsWS send:jsonString];
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
    
    NSLog(@"X: %f, Y: %f", [[_position objectForKey:@"x"] floatValue], [[_position objectForKey:@"y"] floatValue]);
    
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                        [[UIDevice currentDevice] identifierForVendor].UUIDString, @"id",
                         @"ALPS", @"type",
                         [NSNumber numberWithFloat:[[_position objectForKey:@"x"] floatValue]], @"X",
                         [NSNumber numberWithFloat:[[_position objectForKey:@"y"] floatValue]], @"Y",
                         [NSNumber numberWithFloat: 0.0], @"Z",
                         nil];
    
    [_locationResendTimer invalidate];
    [self setLocationMsg:msg];
    [self sendToLocationAnnounceWS:msg];
    _locationResendTimer = [NSTimer scheduledTimerWithTimeInterval:LOCAITON_REPEAT_TIME
                                     target:self
                                   selector:@selector(repeatLocation:)
                                   userInfo:[self locationMsg]
                                    repeats:YES];
}

- (void)repeatLocation:(NSTimer *)timer {
    NSLog(@"Resending location");
    [self sendToLocationAnnounceWS:[self locationMsg]];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"ALPS Websocket Connected");
    self.alpsWSState = WebsocketStateConnected;
    [[_vCSettings solverConnectionStatusLabel] setText:@"Connected"];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor greenColor]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    //NSLog(@"ALPS Websocket Failed With Error %@", error);
    self.alpsWSState = WebsocketStateDisconnected;
    self.alpsWS = nil;
    [[_vCSettings solverConnectionStatusLabel] setText:@"Disconnected"];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor redColor]];
    [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(reconnectWebSocket:)
                                   userInfo:webSocket
                                    repeats:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"ALPS WebSocket closed");
    self.alpsWSState = WebsocketStateDisconnected;
    self.alpsWS = nil;
    [[_vCSettings solverConnectionStatusLabel] setText:@"Disconnected"];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor redColor]];
    [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(reconnectWebSocket:)
                                   userInfo:webSocket
                                    repeats:NO];
}

- (void)reconnectWebSocket:(NSTimer *)timer {
    //NSLog(@"Attempting to reconnect ALPS websocket");
    [self alpsWSConnect];
}

- (void)alpsWSConnect {
    [[_vCSettings solverConnectionStatusLabel] setText:@"Reconnecting..."];
    [[_vCSettings solverConnectionStatusLabel] setTextColor:[UIColor orangeColor]];
    
    self.alpsWSState = WebsocketStateConnecting;

    self.alpsWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.alpsWSAddress]]];
    self.alpsWS.delegate = self;
    [self.alpsWS open];

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
