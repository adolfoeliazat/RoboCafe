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

typedef NS_ENUM(NSInteger, WebsocketState) {
    WebsocketStateDisconnected,
    WebsocketStateConnecting,
    WebsocketStateConnected
};

//#define DEFAULT_ALPS_WEBSOCKET  @"ws://pfet-v2.eecs.umich.edu:30005"
//#define DEFAULT_ALPS_WEBSOCKET  @"ws://solver.bitten-byte.com:30005"
#define DEFAULT_ALPS_WEBSOCKET  @"ws://192.168.11.108:30005"

//#define DEFAULT_CAFE_WEBSOCKET  @"ws://pfet-v2.eecs.umich.edu:8000"
#define DEFAULT_CAFE_WEBSOCKET    @"ws://192.168.11.108:8081"

//#define DEFAULT_LOC_ANNOUNCE_WEBSOCKET @"ws://pfet-v2.eecs.umich.edu:8001"
#define DEFAULT_LOC_ANNOUNCE_WEBSOCKET  @"ws://192.168.11.108:8082"

@class ALPSCore, ViewController, ViewControllerSettings, ViewControllerCafeSettings;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ALPSDelegate, SRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) ViewController *vC;
@property (nonatomic) ViewControllerSettings *vCSettings;
@property (nonatomic) ViewControllerCafeSettings *vCCafeSettings;

@property (nonatomic) NSString* alpsWSAddress;
@property (nonatomic) SRWebSocket *alpsWS;
@property (nonatomic) ALPSCore *ALPS;
@property (nonatomic) WebsocketState alpsWSState;
@property NSDictionary *position;
- (void) alpsWSConnect;

@property (nonatomic) NSString* cafeOrderWSAddress;
@property (nonatomic) CafeOrderWSDelegate* cafeOrderWSDelegate;
@property (nonatomic) WebsocketState cafeOrderWSState;
@property (nonatomic) SRWebSocket *cafeOrderWS;
- (void) cafeOrderWSConnect;

@property (nonatomic) NSString* locationAnnounceWSAddress;
@property (nonatomic) LocationAnnounceWSDelegate* locationAnnounceWSDelegate;
@property (nonatomic) WebsocketState locationAnnounceWSState;
@property (nonatomic) SRWebSocket* locationAnnounceWS;
- (void) locationAnnounceWSConnect;

- (void)sendToWS :(NSDictionary*)data :(SRWebSocket*) WS;
- (void)sendToCafeOrderWS:(NSDictionary*)data;
- (void)sendToLocationAnnounceWS :(NSDictionary*) data;

@end

