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
    
    self.cafeStatusLabel.textAlignment = NSTextAlignmentRight;
    [appDelegate addObserver:self forKeyPath:@"cafeOrderWSState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    self.locationStatusLabel.textAlignment = NSTextAlignmentRight;
    [appDelegate addObserver:self forKeyPath:@"locationAnnounceWSState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    self.vendorIDLabel.textAlignment = NSTextAlignmentCenter;
    self.vendorIDLabel.text = [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"cafeOrderWSState"]) {
        [self updateCafeOrderWSText];
    } else if ([keyPath isEqualToString:@"locationAnnounceWSState"]) {
        [self updateLocationAnnounceWSText];
    }
}

- (void)updateCafeOrderWSText {
    NSString* urlString;
    if (
        (appDelegate.cafeOrderWSState == WebsocketStateConnected) ||
        (appDelegate.cafeOrderWSState == WebsocketStateConnecting)
       ) {
        NSLog(@"cafeOrderWSState: %ld", (long)appDelegate.cafeOrderWSState);
        urlString = [appDelegate.cafeOrderWS.url absoluteString];
    } else {
        NSLog(@"No worries, not connected bro");
        urlString = appDelegate.cafeOrderWSAddress;
    }
    
    //[_cafeWSEntry setText:urlString];
    NSLog(@"Setting to: %@", urlString);
    _cafeWSEntry.text = urlString;

    if (appDelegate.cafeOrderWSState == WebsocketStateConnected) {
        [_cafeStatusLabel setText:@"Connected"];
        [_cafeStatusLabel setTextColor:[UIColor greenColor]];
    } else if (appDelegate.cafeOrderWSState == WebsocketStateConnecting) {
        [_cafeStatusLabel setText:@"Connected"];
        [_cafeStatusLabel setTextColor:[UIColor yellowColor]];
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
        [self.locationStatusLabel setTextColor:[UIColor yellowColor]];
    } else {
        urlString = appDelegate.locationAnnounceWSAddress;
        
        [_locationStatusLabel setText:@"Disconnected"];
        [_locationStatusLabel setTextColor:[UIColor redColor]];
    }
    
    _locationWSEntry.text = urlString;
}

- (IBAction)cafeWSChanged:(id)sender {
    if (appDelegate.cafeOrderWSState != WebsocketStateDisconnected) {
        [appDelegate.cafeOrderWS close];
    }
    appDelegate.cafeOrderWSAddress = self.cafeWSEntry.text;
    [appDelegate cafeOrderWSConnect];
}
- (IBAction)cafeWSConnectClick:(id)sender {
    if (appDelegate.cafeOrderWSState != WebsocketStateDisconnected) {
        [appDelegate.cafeOrderWS close];
    }
    [appDelegate cafeOrderWSConnect];
}

- (IBAction)locationWSChanged:(id)sender {
    if (appDelegate.locationAnnounceWSState != WebsocketStateDisconnected) {
        [appDelegate.locationAnnounceWS close];
    }
    appDelegate.locationAnnounceWSAddress = self.locationWSEntry.text;
    [appDelegate locationAnnounceWSConnect];
}
- (IBAction)locationWSConnectClick:(id)sender {
    if (appDelegate.locationAnnounceWSState != WebsocketStateDisconnected) {
        [appDelegate.locationAnnounceWS close];
    }
    [appDelegate locationAnnounceWSConnect];
}

@end
