//
//  AppConfigWSDelegate.h
//  RoboCafe
//
//  Created by Patrick Pannuto on 9/17/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "SRWebSocket.h"

@class AppDelegate;

@interface AppConfigWSDelegate : NSObject <SRWebSocketDelegate> {
    AppDelegate *appDelegate;
}

@property (nonatomic) NSTimer* reconnectTimer;

@end
