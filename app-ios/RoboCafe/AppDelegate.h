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
#import "AppConfigWSDelegate.h"

#define RECORD_LENGTH 211200 //Needs to be divisible by 1024
#define TDMA_SLOTS 6
#define WEBSOCKET_RECONNECT_TIMEOUT 3 // Websocket reconnect timeout in seconds
#define LOCAITON_REPEAT_TIME 0.5f //seconds

#define POSITION_INVALIDATE_TIME 30.0f // seconds

typedef NS_ENUM(NSInteger, WebsocketState) {
    WebsocketStateDisconnected,
    WebsocketStateConnecting,
    WebsocketStateConnected
};

#define DEFAULT_ALPS_THRESHOLD_DIVISOR 5.0f
#define DEFAULT_ALPS_THRESHOLD_MULTIPLIER 30.0f

//#define DEFAULT_ALPS_WEBSOCKET  @"ws://pfet-v2.eecs.umich.edu:30005"
//#define DEFAULT_ALPS_WEBSOCKET  @"ws://solver.bitten-byte.com:30005"
#define DEFAULT_ALPS_WEBSOCKET  @"ws://192.168.11.108:30005"

//#define DEFAULT_CAFE_WEBSOCKET  @"ws://pfet-v2.eecs.umich.edu:8000"
//#define DEFAULT_CAFE_WEBSOCKET    @"ws://35.2.70.92:8081"
#define DEFAULT_CAFE_WEBSOCKET    @"ws://192.168.11.108:8081"

//#define DEFAULT_LOC_ANNOUNCE_WEBSOCKET @"ws://pfet-v2.eecs.umich.edu:8001"
//#define DEFAULT_LOC_ANNOUNCE_WEBSOCKET  @"ws://35.2.70.92:8082"
#define DEFAULT_LOC_ANNOUNCE_WEBSOCKET  @"ws://192.168.11.108:8082"

//#define DEFAULT_APP_CONFIG_WEBSOCKET @"ws://pfet-v2.eecs.umich.edu:8008"
#define DEFAULT_APP_CONFIG_WEBSOCKET @"ws://35.2.33.183:8008"

@class ALPSCore, ViewController, ViewControllerSettings, ViewControllerCafeSettings;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ALPSDelegate, SRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) ViewController *vC;
@property (nonatomic) ViewControllerSettings *vCSettings;
@property (nonatomic) ViewControllerCafeSettings *vCCafeSettings;

@property (nonatomic) NSNumber *item1ordered;
@property (nonatomic) NSNumber *item2ordered;
@property (nonatomic) NSNumber *item3ordered;

@property (nonatomic) NSString* alpsWSAddress;
@property (nonatomic) SRWebSocket *alpsWS;
@property (nonatomic) ALPS *ALPS;
@property (nonatomic) WebsocketState alpsWSState;
@property NSDictionary *position;
@property (nonatomic) NSDictionary *locationMsg;
@property (nonatomic) NSTimer *locationResendTimer;
@property (nonatomic) NSTimer* alpsWSReconnectTimer;
@property (nonatomic) NSTimer* invalidPositionTimer;
@property (nonatomic) NSNumber* alpsPositionValid;

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

@property (nonatomic) NSString* appConfigWSAddress;
@property (nonatomic) AppConfigWSDelegate* appConfigWSDelegate;
@property (nonatomic) WebsocketState appConfigWSState;
@property (nonatomic) SRWebSocket* appConfigWS;
- (void) appConfigWSConnect;

- (void)sendToWS :(NSDictionary*)data :(SRWebSocket*) WS;
- (void)sendToCafeOrderWS:(NSDictionary*)data;
- (void)sendToLocationAnnounceWS :(NSDictionary*) data;

@property (nonatomic) NSNumber* debugForceEnableAllButtons;

@end

