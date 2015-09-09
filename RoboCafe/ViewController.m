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
    if ([_orderTwixButton.currentTitle isEqual: @"Order candy"]) {
        [_orderTwixButton setTitle:@"Got candy" forState:UIControlStateNormal];
        _cancelTwixButton.hidden = NO;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"Twix", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        
        [_twixStatus setText:@"Ordered candy"];
    } else {
        [_orderTwixButton setTitle:@"Order candy" forState:UIControlStateNormal];
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
    [_orderTwixButton setTitle:@"Order candy" forState:UIControlStateNormal];
    _cancelTwixButton.hidden = YES;
    
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"Twix", @"selection",
                         nil];
    [appDelegate sendToCafeOrderWS:msg];
    
    [_twixStatus setText:@"Cancelled candy order"];
}
- (IBAction)orderSquirtGunTouch:(id)sender {
    if ([_orderSquirtGunButton.currentTitle isEqual: @"Order mints"]) {
        [_orderSquirtGunButton setTitle:@"Got mints" forState:UIControlStateNormal];
        _cancelSquirtGunButton.hidden = NO;
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"SquirtGun", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        
        [_squirtGunStatus setText:@"Ordered mints"];
    } else {
        [_orderSquirtGunButton setTitle:@"Order mints" forState:UIControlStateNormal];
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
    [_orderSquirtGunButton setTitle:@"Order mints" forState:UIControlStateNormal];
    _cancelSquirtGunButton.hidden = YES;
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"SquirtGun", @"selection",
                         nil];
    [appDelegate sendToCafeOrderWS:msg];
    [_squirtGunStatus setText:@"Cancelled mints order"];
}
- (IBAction)orderBouncyBallTouch:(id)sender {
    if ([_orderBouncyBallButton.currentTitle isEqual: @"Order granola"]) {
        [_orderBouncyBallButton setTitle:@"Got granola" forState:UIControlStateNormal];
        _cancelBouncyBallButton.hidden = NO;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             @"BouncyBalls", @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
        
        [_bouncyBallStatus setText:@"Ordered granola"];
    } else {
        [_orderBouncyBallButton setTitle:@"Order granola" forState:UIControlStateNormal];
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
    [_orderBouncyBallButton setTitle:@"Order granola" forState:UIControlStateNormal];
    _cancelBouncyBallButton.hidden = YES;
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         @"BouncyBalls", @"selection",
                         nil];
    [appDelegate sendToCafeOrderWS:msg];
    [_bouncyBallStatus setText:@"Cancelled granola order"];
}

- (IBAction)goToTop:(id)sender {
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"id",
                         @"ALPS", @"type",
                         [NSNumber numberWithFloat:2.0], @"X",
                         [NSNumber numberWithFloat:8.0], @"Y",
                         [NSNumber numberWithFloat: 0.0], @"Z",
                         nil];
    
    [appDelegate.locationResendTimer invalidate];
    [appDelegate sendToLocationAnnounceWS:msg];
}

- (IBAction)goToLeft:(id)sender {
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"id",
                         @"ALPS", @"type",
                         [NSNumber numberWithFloat:1.0], @"X",
                         [NSNumber numberWithFloat:3.0], @"Y",
                         [NSNumber numberWithFloat: 0.0], @"Z",
                         nil];
    
    [appDelegate.locationResendTimer invalidate];
    [appDelegate sendToLocationAnnounceWS:msg];
}

- (IBAction)goToBottom:(id)sender {
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"id",
                         @"ALPS", @"type",
                         [NSNumber numberWithFloat:3.0], @"X",
                         [NSNumber numberWithFloat:2.0], @"Y",
                         [NSNumber numberWithFloat: 0.0], @"Z",
                         nil];
    
    [appDelegate.locationResendTimer invalidate];
    [appDelegate sendToLocationAnnounceWS:msg];
}

- (IBAction)goToRight:(id)sender {
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"id",
                         @"ALPS", @"type",
                         [NSNumber numberWithFloat:11.0], @"X",
                         [NSNumber numberWithFloat:3.5], @"Y",
                         [NSNumber numberWithFloat: 0.0], @"Z",
                         nil];
    
    [appDelegate.locationResendTimer invalidate];
    [appDelegate sendToLocationAnnounceWS:msg];
}

@end

