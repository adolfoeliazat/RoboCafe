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
    
    _orderTwixButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _orderBouncyBallButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _orderSquirtGunButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    _cancelTwixButton.hidden = YES;
    _cancelBouncyBallButton.hidden = YES;
    _cancelSquirtGunButton.hidden = YES;
    
    _roboCafeStatusLabel.textAlignment = NSTextAlignmentCenter;
    UIFontDescriptor* fontItalic = [_roboCafeStatusLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    _roboCafeStatusLabel.font = [UIFont fontWithDescriptor:fontItalic size:0];
    [_roboCafeStatusLabel setTextColor:[UIColor redColor]];

    [appDelegate addObserver:self forKeyPath:@"alpsWSState" options:NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
    [appDelegate addObserver:self forKeyPath:@"cafeOrderWSState" options:NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
    [appDelegate addObserver:self forKeyPath:@"locationAnnounceWSState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (context == &_roboCafeStatusLabel) {
        [self.orderTwixButton setEnabled:NO];
        [self.orderSquirtGunButton setEnabled:NO];
        [self.orderBouncyBallButton setEnabled:NO];
        
        if (appDelegate.alpsWSState != WebsocketStateConnected) {
            [self.roboCafeStatusLabel setText:@"No connection to ALPS"];
        } else if (appDelegate.cafeOrderWSState != WebsocketStateConnected) {
            [self.roboCafeStatusLabel setText:@"No connection to RoboCafé server"];
        } else if (appDelegate.locationAnnounceWSState != WebsocketStateConnected) {
            [self.roboCafeStatusLabel setText:@"No connection to location server"];
        } else {
            [self.orderTwixButton setEnabled:YES];
            [self.orderSquirtGunButton setEnabled:YES];
            [self.orderBouncyBallButton setEnabled:YES];
            [self.roboCafeStatusLabel setText:@""];
        }
    }
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
        [appDelegate sendToCafeOrderWS:msg];
        
        [_twixStatus setText:@"Ordered Twix"];
    } else {
        [_orderTwixButton setTitle:@"Order Twix" forState:UIControlStateNormal];
        _cancelTwixButton.hidden = YES;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             @"Twix", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        
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
    [appDelegate sendToCafeOrderWS:msg];
    
    [_twixStatus setText:@"Cancelled Twix order"];
}
- (IBAction)orderSquirtGunTouch:(id)sender {
    if ([_orderSquirtGunButton.currentTitle isEqual: @"Order Squirt Gun"]) {
        [_orderSquirtGunButton setTitle:@"Got Squirt Gun" forState:UIControlStateNormal];
        _cancelSquirtGunButton.hidden = NO;
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"SquirtGun", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        
        [_squirtGunStatus setText:@"Ordered Squirt Gun"];
    } else {
        [_orderSquirtGunButton setTitle:@"Order Squirt Gun" forState:UIControlStateNormal];
        _cancelSquirtGunButton.hidden = YES;
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             @"SquirtGun", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        [_squirtGunStatus setText:@""];
    }
}

- (IBAction)cancelSquirtGunTouch:(id)sender {
    [_orderSquirtGunButton setTitle:@"Order Squirt Gun" forState:UIControlStateNormal];
    _cancelSquirtGunButton.hidden = YES;
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"SquirtGun", @"selection",
                         nil];
    [appDelegate sendToCafeOrderWS:msg];
    [_squirtGunStatus setText:@"Cancelled Squirt Gun order"];
}
- (IBAction)orderBouncyBallTouch:(id)sender {
    if ([_orderBouncyBallButton.currentTitle isEqual: @"Order Bouncy Ball"]) {
        [_orderBouncyBallButton setTitle:@"Got Bouncy Ball" forState:UIControlStateNormal];
        _cancelBouncyBallButton.hidden = NO;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"BouncyBalls", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        
        [_bouncyBallStatus setText:@"Ordered Bouncy Ball"];
    } else {
        [_orderBouncyBallButton setTitle:@"Order Bouncy Ball" forState:UIControlStateNormal];
        _cancelBouncyBallButton.hidden = YES;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             @"BouncyBalls", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        [_bouncyBallStatus setText:@""];
    }
}

- (IBAction)cancelBouncyBallTouch:(id)sender {
    [_orderBouncyBallButton setTitle:@"Order Bouncy Ball" forState:UIControlStateNormal];
    _cancelBouncyBallButton.hidden = YES;
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"BouncyBalls", @"selection",
                         nil];
    [appDelegate sendToCafeOrderWS:msg];
    [_bouncyBallStatus setText:@"Cancelled Bouncy Ball order"];
}

@end

