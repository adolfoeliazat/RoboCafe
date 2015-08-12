//
//  ViewController.m
//  RoboCafe
//
//  Created by Patrick Lazik on 8/9/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

AppDelegate *appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setVC:self];

    _cancelTwixButton.hidden = YES;
    _cancelBouncyBallButton.hidden = YES;
    _cancelSquirtGunButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* {
 "phone_id": "string",
 "type": "selection",
 "selection": "Twix|SquirtGun|BouncyBalls"
 }
 {
 "phone_id": "string",
 "type": "finished"
 }*/

- (IBAction)orderTwixTouch:(id)sender {
    if ([_orderTwixButton.currentTitle isEqual: @"Order Twix"]) {
        [_orderTwixButton setTitle:@"Got Twix" forState:UIControlStateNormal];
        _cancelTwixButton.hidden = NO;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"Twix", @"selection",
                             nil];
        [appDelegate sendToRobotWS:msg];
        
        [_twixStatus setText:@"Ordered Twix"];
    } else {
        [_orderTwixButton setTitle:@"Order Twix" forState:UIControlStateNormal];
        _cancelTwixButton.hidden = YES;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             @"Twix", @"selection",
                             nil];
        [appDelegate sendToRobotWS:msg];
        
        [_twixStatus setText:@""];
    }
}
- (IBAction)cancelTwixTouch:(id)sender {
    [_orderTwixButton setTitle:@"Order Twix" forState:UIControlStateNormal];
    _cancelTwixButton.hidden = YES;
    
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"Twix", @"selection",
                         nil];
    [appDelegate sendToRobotWS:msg];
    
    [_twixStatus setText:@"Cancelled Twix order"];
}
- (IBAction)orderSquirtGunTouch:(id)sender {
    if ([_orderSquirtGunButton.currentTitle isEqual: @"Order Squirt Gun"]) {
        [_orderSquirtGunButton setTitle:@"Got Squirt Gun" forState:UIControlStateNormal];
        _cancelSquirtGunButton.hidden = NO;
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"Squirt Gun", @"selection",
                             nil];
        [appDelegate sendToRobotWS:msg];
        
        [_squirtGunStatus setText:@"Ordered Squirt Gun"];
    } else {
        [_orderSquirtGunButton setTitle:@"Order Squirt Gun" forState:UIControlStateNormal];
        _cancelSquirtGunButton.hidden = YES;
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             @"Squirt Gun", @"selection",
                             nil];
        [appDelegate sendToRobotWS:msg];
        [_squirtGunStatus setText:@""];
    }
}

- (IBAction)cancelSquirtGunTouch:(id)sender {
    [_orderSquirtGunButton setTitle:@"Order Squirt Gun" forState:UIControlStateNormal];
    _cancelSquirtGunButton.hidden = YES;
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"Squirt Gun", @"selection",
                         nil];
    [appDelegate sendToRobotWS:msg];
    [_squirtGunStatus setText:@"Cancelled Squirt Gun order"];
}
- (IBAction)orderBouncyBallTouch:(id)sender {
    if ([_orderBouncyBallButton.currentTitle isEqual: @"Order Bouncy Ball"]) {
        [_orderBouncyBallButton setTitle:@"Got Bouncy Ball" forState:UIControlStateNormal];
        _cancelBouncyBallButton.hidden = NO;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"Bouncy Ball", @"selection",
                             nil];
        [appDelegate sendToRobotWS:msg];
        
        [_bouncyBallStatus setText:@"Ordered Bouncy Ball"];
    } else {
        [_orderBouncyBallButton setTitle:@"Order Bouncy Ball" forState:UIControlStateNormal];
        _cancelBouncyBallButton.hidden = YES;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             @"Bouncy Ball", @"selection",
                             nil];
        [appDelegate sendToRobotWS:msg];
        [_bouncyBallStatus setText:@""];
    }
}

- (IBAction)cancelBouncyBallTouch:(id)sender {
    [_orderBouncyBallButton setTitle:@"Order Bouncy Ball" forState:UIControlStateNormal];
    _cancelBouncyBallButton.hidden = YES;
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"Bouncy Ball", @"selection",
                         nil];
    [appDelegate sendToRobotWS:msg];
    [_bouncyBallStatus setText:@"Cancelled Bouncy Ball order"];
}

@end

