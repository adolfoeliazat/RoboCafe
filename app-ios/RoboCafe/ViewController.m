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

    UIFontDescriptor* fontItalic = [_roboCafeStatusLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    _roboCafeStatusLabel.font = [UIFont fontWithDescriptor:fontItalic size:0];

    [appDelegate addObserver:self forKeyPath:@"alpsPositionValid" options:NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
    [appDelegate addObserver:self forKeyPath:@"alpsWSState" options:NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
    [appDelegate addObserver:self forKeyPath:@"cafeOrderWSState" options:NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
    [appDelegate addObserver:self forKeyPath:@"locationAnnounceWSState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew context:&_roboCafeStatusLabel];
    
    [appDelegate addObserver:self forKeyPath:@"debugForceEnableAllButtons" options:NSKeyValueObservingOptionInitial context:&_roboCafeStatusLabel];
    
    [appDelegate addObserver:self forKeyPath:@"item1ordered" options:NSKeyValueObservingOptionInitial context:&_orderTwixButton];
    [appDelegate addObserver:self forKeyPath:@"item2ordered" options:NSKeyValueObservingOptionInitial context:&_orderSquirtGunButton];
    [appDelegate addObserver:self forKeyPath:@"item3ordered" options:NSKeyValueObservingOptionInitial context:&_orderBouncyBallButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BOOL canEnableButtons = [appDelegate.debugForceEnableAllButtons boolValue];
    
    if (appDelegate.alpsWSState != WebsocketStateConnected) {
        [self.roboCafeStatusLabel setText:@"No connection to ALPS"];
    } else if (appDelegate.cafeOrderWSState != WebsocketStateConnected) {
        [self.roboCafeStatusLabel setText:@"No connection to RoboCafé server"];
    } else if (appDelegate.locationAnnounceWSState != WebsocketStateConnected) {
        [self.roboCafeStatusLabel setText:@"No connection to location server"];
    } else {
        canEnableButtons = YES;
        if ([appDelegate.alpsPositionValid boolValue] == YES) {
            [self.roboCafeStatusLabel setText:@"Got your location!"];
        } else {
            [self.roboCafeStatusLabel setText:@"Your location is unknown"];
        }
    }

    if (canEnableButtons && ([appDelegate.alpsPositionValid boolValue] == YES)) {
        [_roboCafeStatusLabel setTextColor:[UIColor blackColor]];
    } else {
        [_roboCafeStatusLabel setTextColor:[UIColor redColor]];
    }

    if (context == &_roboCafeStatusLabel) {
        if (canEnableButtons) {
            self.orderTwixButton.enabled = YES;
            self.orderSquirtGunButton.enabled = YES;
            self.orderBouncyBallButton.enabled = YES;
            self.cancelTwixButton.enabled = YES;
            self.cancelSquirtGunButton.enabled = YES;
            self.cancelBouncyBallButton.enabled = YES;
        } else {
            self.orderTwixButton.enabled = NO;
            self.orderSquirtGunButton.enabled = NO;
            self.orderBouncyBallButton.enabled = NO;
            self.cancelTwixButton.enabled = NO;
            self.cancelSquirtGunButton.enabled = NO;
            self.cancelBouncyBallButton.enabled = NO;
        }
    } else if (context == &_orderTwixButton) {
        NSString* item1 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item1"];
        BOOL ordered = [appDelegate.item1ordered boolValue];
        [self genericObserveForItem:item1 isOrdered:ordered forOrderButton:self.orderTwixButton forCancelButton:self.cancelTwixButton canEnableButtons:canEnableButtons];
    } else if (context == &_orderSquirtGunButton) {
        NSString* item2 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item2"];
        BOOL ordered = [appDelegate.item2ordered boolValue];
        [self genericObserveForItem:item2 isOrdered:ordered forOrderButton:self.orderSquirtGunButton forCancelButton:self.cancelSquirtGunButton canEnableButtons:canEnableButtons];
    } else if (context == &_orderBouncyBallButton) {
        NSString* item3 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item3"];
        BOOL ordered = [appDelegate.item3ordered boolValue];
        [self genericObserveForItem:item3 isOrdered:ordered forOrderButton:self.orderBouncyBallButton forCancelButton:self.cancelBouncyBallButton canEnableButtons:canEnableButtons];
    }
}

- (void)genericObserveForItem:(NSString*)item isOrdered:(BOOL)ordered forOrderButton:(UIButton*)order forCancelButton:(UIButton*)cancel canEnableButtons:(BOOL)canEnableButtons {
    if (canEnableButtons) order.enabled = YES;
    if (ordered == YES) {
        [order setTitle:[NSString stringWithFormat:@"Got %@", item] forState:UIControlStateNormal];
        cancel.hidden = NO;
    } else {
        [order setTitle:[NSString stringWithFormat:@"Order %@", item] forState:UIControlStateNormal];
        cancel.hidden = YES;
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

- (void)genericOrderForItem:(NSString*)item isOrdered:(BOOL)ordered forOrderButton:(UIButton*)order forCancelButton:(UIButton*)cancel forPtolemySelection:(NSString*)ptolemySelection {
    BOOL canDisableButtons = ![appDelegate.debugForceEnableAllButtons boolValue];
    if (ordered == NO) {
        // Touched "Order <item>"
        [order setTitle:[NSString stringWithFormat:@"Ordering %@...", item] forState:UIControlStateNormal];
        if (canDisableButtons) order.enabled = NO;
        cancel.hidden = NO;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"selection", @"type",
                             ptolemySelection, @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
    } else {
        // Touched "Got <item>"
        [order setTitle:@"Acknowledging..." forState:UIControlStateNormal];
        if (canDisableButtons) order.enabled = NO;
        cancel.hidden = YES;
        
        NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                             [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                             @"finished", @"type",
                             ptolemySelection, @"selection",
                             nil];
        [appDelegate sendToCafeOrderWS:msg];
    }
}

- (void)genericCancelForItem:(NSString*)item forOrderButton:(UIButton*)order forCancelButton:(UIButton*)cancel forPtolemySelection:(NSString*) ptolemySelection {
    BOOL canDisableButtons = ![appDelegate.debugForceEnableAllButtons boolValue];
    [order setTitle:@"Cancelling..." forState:UIControlStateNormal];
    if (canDisableButtons) order.enabled = NO;
    cancel.hidden = YES;
    
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"phone_id",
                         @"cancelled", @"type",
                         ptolemySelection, @"selection",
                         nil];
    [appDelegate sendToCafeOrderWS:msg];
}

- (IBAction)orderTwixTouch:(id)sender {
    NSString* item1 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item1"];
    BOOL ordered = [appDelegate.item1ordered boolValue];
    [self genericOrderForItem:item1 isOrdered:ordered forOrderButton:self.orderTwixButton forCancelButton:self.cancelTwixButton forPtolemySelection:@"Twix"];
}
- (IBAction)cancelTwixTouch:(id)sender {
    NSString* item1 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item1"];
    [self genericCancelForItem:item1 forOrderButton:self.orderTwixButton forCancelButton:self.cancelTwixButton forPtolemySelection:@"Twix"];
}

- (IBAction)orderSquirtGunTouch:(id)sender {
    NSString* item2 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item2"];
    BOOL ordered = [appDelegate.item2ordered boolValue];
    [self genericOrderForItem:item2 isOrdered:ordered forOrderButton:self.orderSquirtGunButton forCancelButton:self.cancelSquirtGunButton forPtolemySelection:@"SquirtGun"];
}
- (IBAction)cancelSquirtGunTouch:(id)sender {
    NSString* item2 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item2"];
    [self genericCancelForItem:item2 forOrderButton:self.orderSquirtGunButton forCancelButton:self.cancelSquirtGunButton forPtolemySelection:@"SquirtGun"];
}

- (IBAction)orderBouncyBallTouch:(id)sender {
    NSString* item3 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item3"];
    BOOL ordered = [appDelegate.item3ordered boolValue];
    [self genericOrderForItem:item3 isOrdered:ordered forOrderButton:self.orderBouncyBallButton forCancelButton:self.cancelBouncyBallButton forPtolemySelection:@"BouncyBalls"];
}
- (IBAction)cancelBouncyBallTouch:(id)sender {
    NSString* item3 = [[NSUserDefaults standardUserDefaults] stringForKey:@"item3"];
    [self genericCancelForItem:item3 forOrderButton:self.orderBouncyBallButton forCancelButton:self.cancelBouncyBallButton forPtolemySelection:@"BouncyBalls"];
}

@end

