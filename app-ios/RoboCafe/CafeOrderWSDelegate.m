//
//  CafeOrderWSDelegate.m
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/13/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "CafeOrderWSDelegate.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewControllerCafeSettings.h"

@implementation CafeOrderWSDelegate

/*
 var STATE_IDLE = 'IDLE';         // Robot is currently just sitting there.
 var STATE_SERVING = 'SERVING';   // Robot has been requested and is going to a person.
 var STATE_SPINNING = 'SPINNING'; // Applause was detected and the robot is interrupted to spin.

 {
   "robots": [
     {"state":"SERVING","servicing":"Alan"},
     {"state":"SERVING","servicing":"Kate"},
     {"state":"SERVING","servicing":"Kate"},
     {"state":"SERVING","servicing":"Kent"}
   ],
   "items": {
     "Twix": {
       "robots":[0,3],
       "queue":["Bear","Seal"]
     },
     "SquirtGun": {
       "robots":[1],
       "queue":[]
     },
     "BouncyBalls": {
       "robots":[2],
       "queue":["Kate"]
     }
   }
 }
 */

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    //NSLog(@"CafeOrderWS received message: %@", message);
    
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
    
    NSArray* status = [NSJSONSerialization JSONObjectWithData:messageAsData options:kNilOptions error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON >>>%@<<<. Error: %@", message, error);
        return;
    }

    NSArray* robots = [status valueForKey:@"robots"];
    if (robots == nil) {
        NSLog(@"Missing required key 'robots'");
        return;
    }
    if ([robots count] != 4) {
        NSLog(@"Expected 4 robots, got %lu", (unsigned long)[robots count]);
        return;
    }
    
    NSDictionary* items = [status valueForKey:@"items"];
    if (items == nil) {
        NSLog(@"Missing required key 'items'");
        return;
    }
    if ([items count] != 3) {
        NSLog(@"Expected 3 items, got %lu", (unsigned long)[items count]);
        return;
    }
    
    NSDictionary* twix = [items valueForKey:@"Twix"];
    if (twix == nil) {
        NSLog(@"No 'Twix' in items");
        return;
    }
    NSArray* twixRobots = [twix valueForKey:@"robots"];
    if (twixRobots == nil) {
        NSLog(@"No 'robots' in twix");
        return;
    }
    NSArray* twixQueue = [twix valueForKey:@"queue"];
    if (twixQueue == nil) {
        NSLog(@"No 'queue' in twix");
        return;
    }
    
    NSDictionary* squirtGun = [items valueForKey:@"SquirtGun"];
    if (squirtGun == nil) {
        NSLog(@"No 'SquirtGun' in items");
        return;
    }
    NSArray* squirtGunRobots = [squirtGun valueForKey:@"robots"];
    if (squirtGunRobots == nil) {
        NSLog(@"No 'robots' in squirtGun");
        return;
    }
    NSArray* squirtGunQueue = [squirtGun valueForKey:@"queue"];
    if (squirtGunQueue == nil) {
        NSLog(@"No 'queue' in squirtGun");
        return;
    }
    
    NSDictionary* bouncyBalls = [items valueForKey:@"BouncyBalls"];
    if (bouncyBalls == nil) {
        NSLog(@"No 'BouncyBalls' in items");
        return;
    }
    NSArray* bouncyBallsRobots = [bouncyBalls valueForKey:@"robots"];
    if (bouncyBallsRobots == nil) {
        NSLog(@"No 'robots' in bouncyBalls");
        return;
    }
    NSArray* bouncyBallsQueue = [bouncyBalls valueForKey:@"queue"];
    if (bouncyBallsQueue == nil) {
        NSLog(@"No 'queue' in bouncyBalls");
        return;
    }

    NSString* item1 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item1"];
    NSString* item2 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item2"];
    NSString* item3 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item3"];
    
    NSString* twixStatus = [self generateStatusTextForItem:item1 forItemQueue:twixQueue forItemRobotList:twixRobots forRobots:robots];
    NSString* squirtGunStatus = [self generateStatusTextForItem:item2 forItemQueue:squirtGunQueue forItemRobotList:squirtGunRobots forRobots:robots];
    NSString* bouncyBallsStatus = [self generateStatusTextForItem:item3 forItemQueue:bouncyBallsQueue forItemRobotList:bouncyBallsRobots forRobots:robots];
    
    appDelegate.item1ordered = [[NSNumber alloc] initWithBool:[self hasUserOrderedForItemQueue:twixQueue forItemRobotList:twixRobots forRobots:robots]];
    appDelegate.item2ordered = [[NSNumber alloc] initWithBool:[self hasUserOrderedForItemQueue:squirtGunQueue forItemRobotList:squirtGunRobots forRobots:robots]];
    appDelegate.item3ordered = [[NSNumber alloc] initWithBool:[self hasUserOrderedForItemQueue:bouncyBallsQueue forItemRobotList:bouncyBallsRobots forRobots:robots]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [appDelegate.vC.twixStatus setText:twixStatus];
        [appDelegate.vC.squirtGunStatus setText:squirtGunStatus];
        [appDelegate.vC.bouncyBallStatus setText:bouncyBallsStatus];
    });
}

- (BOOL)hasUserOrderedForItemQueue:(NSArray*)queue forItemRobotList:(NSArray*)itemRobotList forRobots:robots {
    unsigned i;

    for (i=0; i < [itemRobotList count]; i++ ) {
        NSNumber* index = [itemRobotList objectAtIndex:i];
        unsigned idx = [index unsignedIntValue];
        NSDictionary* robot = [robots objectAtIndex:idx];
        if (robot != nil) {
            NSString* state = [robot objectForKey:@"state"];
            if (state != nil) {
                if ([state isEqualToString:@"SERVING"]) {
                    NSString* servicing = [robot objectForKey:@"servicing"];
                    if (servicing != nil) {
                        if ([servicing isEqualToString:[[UIDevice currentDevice] identifierForVendor].UUIDString]) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    
    for (i=0; i < [queue count]; i++) {
        if ([queue[i] isEqualToString:[[UIDevice currentDevice] identifierForVendor].UUIDString]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSString*)generateStatusTextForItem:(NSString*)itemType forItemQueue:(NSArray*)queue forItemRobotList:(NSArray*)itemRobotList forRobots:(NSArray*) robots {
    NSString* currentBestStatus = @"";
    unsigned i;
    BOOL isSpinning = false;
    
    for (i=0; i < [itemRobotList count]; i++) {
        NSNumber* index = [itemRobotList objectAtIndex:i];
        unsigned idx = [index unsignedIntValue];
        NSDictionary* robot = [robots objectAtIndex:idx];
        if (robot != nil) {
            NSString* state = [robot objectForKey:@"state"];
            if (state != nil) {
                if ([state isEqualToString:@"IDLE"]) {
                    if ([currentBestStatus isEqualToString:@""]) {
                        currentBestStatus = [NSString stringWithFormat:@"All %@ robots are idle.", itemType];
                    }
                } else if ([state isEqualToString:@"SERVING"]) {
                    NSString* servicing = [robot objectForKey:@"servicing"];
                    if (servicing != nil) {
                        if ([servicing isEqualToString:[[UIDevice currentDevice] identifierForVendor].UUIDString])  {
                            return [NSString stringWithFormat:@"Robot %u is on its way!", idx];
                        } else {
                            currentBestStatus = [NSString stringWithFormat:@"Robot %u is making its last delivery.", idx];
                        }
                    }
                } else if ([state isEqualToString:@"SPINNING"]) {
                    currentBestStatus = [NSString stringWithFormat:@"A %@ robot is spinning.", itemType];
                    isSpinning = true;
                }
            }
        }
    }
    
    if ([itemRobotList count] == 0) {
        currentBestStatus = @"No robots are currently assigned to this item.";
    }
    
    if ([queue count]) {
        for (i = 0; i < [queue count]; i++) {
            if ([queue[i] isEqualToString:[[UIDevice currentDevice] identifierForVendor].UUIDString]) {
                break;
            }
        }
        if (i < [queue count]) {
            if (isSpinning) {
                return [NSString stringWithFormat:@"Robot stopped to spin! (%u/%lu in queue)", i+1, (unsigned long)[queue count]];
            }
            return [NSString stringWithFormat:@"Ordered. You are %u/%lu in the queue.", i+1, (unsigned long)[queue count]];
        } else {
            if (!isSpinning) {
                currentBestStatus = [NSString stringWithFormat:@"Current queue length: %lu", (unsigned long)[queue count]];
            }
        }
    }
    
    return currentBestStatus;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"CafeOrderWS Opened");
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[appDelegate setValue:[NSNumber numberWithBool:YES] forKey:@"cafeOrderWSState"];
    appDelegate.cafeOrderWSState = WebsocketStateConnected;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    //NSLog(@"CafeOrderWS failed with error: %@", error);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.cafeOrderWSState = WebsocketStateDisconnected;
    
    self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                     target:self
                                   selector:@selector(reconnectWebSocket:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"CafeOrderWS closed (code %ld, wasClean %d)", (long)code, wasClean);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.cafeOrderWSState = WebsocketStateDisconnected;
    
    if (!wasClean) {
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:WEBSOCKET_RECONNECT_TIMEOUT
                                         target:self
                                       selector:@selector(reconnectWebSocket:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)reconnectWebSocket:(NSTimer *)timer {
    if (appDelegate.cafeOrderWSState == WebsocketStateDisconnected) {
        //NSLog(@"Attempting to reconnect CafeOrderWS");
        [appDelegate cafeOrderWSConnect];
    }
}

@end
