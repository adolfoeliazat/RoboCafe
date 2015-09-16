//
//  ViewControllerCafeSettings.m
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/12/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "ViewControllerCafeSettings.h"
#import "AppDelegate.h"


@implementation ViewControllerCafeSettings

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setVCCafeSettings:self];
    
    self.cafeWSEntry.delegate = self;
    self.locationWSEntry.delegate = self;
    
    self.cafeStatusLabel.textAlignment = NSTextAlignmentRight;
    [appDelegate addObserver:self forKeyPath:@"cafeOrderWSState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    self.locationStatusLabel.textAlignment = NSTextAlignmentRight;
    [appDelegate addObserver:self forKeyPath:@"locationAnnounceWSState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    // Debugging UI stuff below here
    self.postLocationXTextField.delegate = self;
    self.postLocationXTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"debug_post_location_x"];
    
    self.postLocationYTextField.delegate = self;
    self.postLocationYTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"debug_post_location_y"];
    
    self.vendorIDLabel.text = [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"cafeOrderWSState"]) {
        [self updateCafeOrderWSText];
    } else if ([keyPath isEqualToString:@"locationAnnounceWSState"]) {
        [self updateLocationAnnounceWSText];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        // textField is postLocationXTextField
        UIResponder* nextResponser = [textField.superview viewWithTag:2]; // Tag 2 is postLocationYTextField
        [nextResponser becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)updateCafeOrderWSText {
    NSString* urlString;
    if (
        (appDelegate.cafeOrderWSState == WebsocketStateConnected) ||
        (appDelegate.cafeOrderWSState == WebsocketStateConnecting)
       ) {
        urlString = [appDelegate.cafeOrderWS.url absoluteString];
    } else {
        urlString = appDelegate.cafeOrderWSAddress;
    }
    
    _cafeWSEntry.text = urlString;

    if (appDelegate.cafeOrderWSState == WebsocketStateConnected) {
        [_cafeStatusLabel setText:@"Connected"];
        [_cafeStatusLabel setTextColor:[UIColor greenColor]];
    } else if (appDelegate.cafeOrderWSState == WebsocketStateConnecting) {
        [_cafeStatusLabel setText:@"Connected"];
        [_cafeStatusLabel setTextColor:[UIColor orangeColor]];
    } else {
        [_cafeStatusLabel setText:@"Disconnected"];
        [_cafeStatusLabel setTextColor:[UIColor redColor]];
    }
}

- (void)updateLocationAnnounceWSText {
    if (appDelegate == nil) return;
    
    NSString* urlString;
    if (appDelegate.locationAnnounceWSState == WebsocketStateConnected) {
        urlString = [appDelegate.locationAnnounceWS.url absoluteString];
        
        [_locationStatusLabel setText:@"Connected"];
        [_locationStatusLabel setTextColor:[UIColor greenColor]];
    } else if (appDelegate.locationAnnounceWSState == WebsocketStateConnecting) {
        urlString = [appDelegate.locationAnnounceWS.url absoluteString];
        
        [self.locationStatusLabel setText:@"Connecting"];
        [self.locationStatusLabel setTextColor:[UIColor orangeColor]];
    } else {
        urlString = appDelegate.locationAnnounceWSAddress;
        
        [_locationStatusLabel setText:@"Disconnected"];
        [_locationStatusLabel setTextColor:[UIColor redColor]];
    }
    
    _locationWSEntry.text = urlString;
}

- (IBAction)cafeWSEditingEnd:(id)sender {
    if (appDelegate.cafeOrderWSState != WebsocketStateDisconnected) {
        [appDelegate.cafeOrderWS close];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.cafeWSEntry.text forKey:@"cafe_ws_address"];
    appDelegate.cafeOrderWSAddress = self.cafeWSEntry.text;
    [appDelegate cafeOrderWSConnect];
}

- (IBAction)cafeWSClear:(id)sender {
    self.cafeWSEntry.text = DEFAULT_CAFE_WEBSOCKET;
    [self cafeWSEditingEnd:self];
}


- (IBAction)cafeWSConnectClick:(id)sender {
    if (appDelegate.cafeOrderWSState != WebsocketStateDisconnected) {
        [appDelegate.cafeOrderWS close];
    }
    [appDelegate cafeOrderWSConnect];
}

- (IBAction)locationWSEditingEnd:(id)sender {
    if (appDelegate.locationAnnounceWSState != WebsocketStateDisconnected) {
        [appDelegate.locationAnnounceWS close];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.locationWSEntry.text forKey:@"loc_announce_ws_address"];
    appDelegate.locationAnnounceWSAddress = self.locationWSEntry.text;
    [appDelegate locationAnnounceWSConnect];
}

- (IBAction)locationWSClear:(id)sender {
    self.locationWSEntry.text = DEFAULT_LOC_ANNOUNCE_WEBSOCKET;
    [self locationWSEditingEnd:self];
}

- (IBAction)locationWSConnectClick:(id)sender {
    if (appDelegate.locationAnnounceWSState != WebsocketStateDisconnected) {
        [appDelegate.locationAnnounceWS close];
    }
    [appDelegate locationAnnounceWSConnect];
}


/*** DEBUGGING SUPPORT *******************************************************/

- (IBAction)enableAllButtonsSwitchValueChanged:(id)sender {
    appDelegate.debugForceEnableAllButtons = [[NSNumber alloc] initWithBool:self.enableAllButtonsSwitch.on];
}

- (IBAction)postLocationXEditingEnd:(id)sender {
    NSNumber *coerce = [NSNumber numberWithFloat:[self.postLocationXTextField.text floatValue]];
    self.postLocationXTextField.text = [coerce stringValue];
    [[NSUserDefaults standardUserDefaults] setObject:self.postLocationXTextField.text forKey:@"debug_post_location_x"];
}

- (IBAction)postLocationYEditingEnd:(id)sender {
    NSNumber *coerce = [NSNumber numberWithFloat:[self.postLocationYTextField.text floatValue]];
    self.postLocationYTextField.text = [coerce stringValue];
    [[NSUserDefaults standardUserDefaults] setObject:self.postLocationYTextField.text forKey:@"debug_post_location_y"];
}

- (IBAction)postLocationButtonTouched:(id)sender {
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[UIDevice currentDevice] identifierForVendor].UUIDString, @"id",
                         @"ALPS", @"type",
                         [NSNumber numberWithFloat:[self.postLocationXTextField.text floatValue]], @"X",
                         [NSNumber numberWithFloat:[self.postLocationYTextField.text floatValue]], @"Y",
                         [NSNumber numberWithFloat:0.0], @"Z",
                         nil];
    
    [appDelegate.locationResendTimer invalidate];
    [appDelegate sendToLocationAnnounceWS:msg];
}
@end
