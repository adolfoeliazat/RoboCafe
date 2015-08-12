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
@end

