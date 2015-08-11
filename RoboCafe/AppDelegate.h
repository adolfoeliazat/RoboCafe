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

#define RECORD_LENGTH 168960 //Needs to be divisible by 1024

@class ALPSCore, ViewController, ViewControllerSettings;

@interface AppDelegate : UIResponder <UIApplicationDelegate, ALPSDelegate, SRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) ViewController *vC;
@property (nonatomic) ViewControllerSettings *vCSettings;
@property (nonatomic) SRWebSocket *wS;
@property (nonatomic) ALPSCore *ALPS;
@property (nonatomic) BOOL wSConnected;

@end

