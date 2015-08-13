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
    
    _cafeStatusLabel.textAlignment = NSTextAlignmentRight;
    _cafeWSConnectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [appDelegate addObserver:self forKeyPath:@"reportWSConnected" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    
    _locationStatusLabel.textAlignment = NSTextAlignmentRight;
    _locationWSConnectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [appDelegate addObserver:self forKeyPath:@"locationAnnounceWSConnected" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"reportWSConnected"]) {
        [self updateWSText];
    } else if ([keyPath isEqualToString:@"locationAnnounceWSConnected"]) {
        [self updateLocationAnnounceWSText];
    }
}

- (void)updateWSText {
    // No idea if this is needed, I don't think so if I understand how things are
    // working correctly, but better safe than sorry
    if (appDelegate == nil) return;
    
    NSString* urlString;
    if ([[appDelegate valueForKey:@"reportWSConnected"] isEqualToNumber: [NSNumber numberWithBool:YES]]) {
        NSLog(@"It thinks it's connect");
        NSLog(@"%@", [appDelegate valueForKey:@"reportWSConnected"]);
        urlString = [appDelegate.reportWS.url absoluteString];
    } else {
        NSLog(@"No worries, not connected bro");
        urlString = DEFAULT_CAFE_WEBSOCKET;
    }
    
    //[_cafeWSEntry setText:urlString];
    NSLog(@"Setting to: %@", urlString);
    _cafeWSEntry.text = urlString;

    if (appDelegate.reportWSConnected) {
        [_cafeStatusLabel setText:@"Connected"];
        [_cafeStatusLabel setTextColor:[UIColor greenColor]];
        
        [_cafeWSConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    } else {
        [_cafeStatusLabel setText:@"Disconnected"];
        [_cafeStatusLabel setTextColor:[UIColor redColor]];
        
        [_cafeWSConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
    }
}

- (void)updateLocationAnnounceWSText {
    if (appDelegate == nil) return;
    
    NSString* urlString;
    if ([[appDelegate valueForKey:@"locationAnnounceWSConnected"] isEqualToNumber: [NSNumber numberWithBool:YES]]) {
        urlString = [appDelegate.locationAnnounceWS.url absoluteString];
        
        [_locationStatusLabel setText:@"Connected"];
        [_locationStatusLabel setTextColor:[UIColor greenColor]];
        
        [_locationWSConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    } else {
        urlString = DEFAULT_LOC_ANNOUNCE_WEBSOCKET;
        
        [_locationStatusLabel setText:@"Disconnected"];
        [_locationStatusLabel setTextColor:[UIColor redColor]];
        
        [_locationWSConnectButton setTitle:@"Connect" forState:UIControlStateNormal];
    }
    
    _locationWSEntry.text = urlString;
}

- (IBAction)cafeWSChanged:(id)sender {
    if (appDelegate.reportWSConnected) {
        [appDelegate.reportWS close];
    }
    appDelegate.reportWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_cafeWSEntry.text]]];
    appDelegate.reportWS.delegate = appDelegate;
    [appDelegate.reportWS open];
}

- (IBAction)cafeWSConnectClick:(id)sender {
    if (appDelegate.reportWSConnected) {
        [appDelegate.reportWS close];
    } else {
        appDelegate.reportWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_cafeWSEntry.text]]];
        appDelegate.reportWS.delegate = appDelegate;
        [appDelegate.reportWS open];
    }
}
- (IBAction)locationWSChanged:(id)sender {
    if (appDelegate.locationAnnounceWSConnected) {
        [appDelegate.locationAnnounceWS close];
    }
    appDelegate.locationAnnounceWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_locationWSEntry.text]]];
    appDelegate.locationAnnounceWS.delegate = appDelegate.locationAnnounceWSDelegate;
    [appDelegate.locationAnnounceWS open];
}
- (IBAction)locationWSConnectClick:(id)sender {
    if (appDelegate.locationAnnounceWSConnected) {
        [appDelegate.locationAnnounceWS close];
    } else {
        appDelegate.locationAnnounceWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_locationWSEntry.text]]];
        appDelegate.locationAnnounceWS.delegate = appDelegate.locationAnnounceWSDelegate;
        [appDelegate.locationAnnounceWS open];
    }
}

@end
