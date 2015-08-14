//
//  AppDelegate.h
//  RoboCafe
//
//  Created by Patrick Lazik on 8/9/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ALPS/ALPS.h>
#import "SRWebSocket.h"
#import "CafeOrderWSDelegate.h"
#import "LocationAnnounceWSDelegate.h"

#define RECORD_LENGTH 168960 //Needs to be divisible by 1024
#define TDMA_SLOTS 6
#define WEBSOCKET_RECONNECT_TIMEOUT 3 // Websocket reconnect timeout in seconds

//#define DEFAULT_ALPS_WEBSOCKET  @"ws://solver.bitten-byte.com:30005"
#define DEFAULT_ALPS_WEBSOCKET  @"ws://35.2.70.159:30005"

//#define DEFAULT_CAFE_WEBSOCKET  @"ws://pfet-v2.eecs.umich.edu:8000"
#define DEFAULT_CAFE_WEBSOCKET    @"ws://141.212.11.234:8081"

#define DEFAULT_LOC_ANNOUNCE_WEBSOCKET  @"ws://141.212.11.234:8082"

@class ALPSCore, ViewController, ViewControllerSettings, ViewControllerCafeSettings;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ALPSDelegate, SRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) ViewController *vC;
@property (nonatomic) ViewControllerSettings *vCSettings;
@property (nonatomic) ViewControllerCafeSettings *vCCafeSettings;
@property (nonatomic) SRWebSocket *wS;
@property (nonatomic) ALPSCore *ALPS;
@property (nonatomic) BOOL wSConnected;
@property NSDictionary *position;

@property (nonatomic) CafeOrderWSDelegate* cafeOrderWSDelegate;
@property (nonatomic) NSInteger cafeOrderWSConnected;
@property (nonatomic) SRWebSocket *cafeOrderWS;

@property (nonatomic) LocationAnnounceWSDelegate* locationAnnounceWSDelegate;
@property (nonatomic) NSInteger locationAnnounceWSConnected;
@property (nonatomic) SRWebSocket* locationAnnounceWS;

- (void)sendToWS :(NSDictionary*)data :(SRWebSocket*) WS;
- (void)sendToCafeOrderWS:(NSDictionary*)data;
- (void)sendToLocationAnnounceWS :(NSDictionary*) data;

@end

