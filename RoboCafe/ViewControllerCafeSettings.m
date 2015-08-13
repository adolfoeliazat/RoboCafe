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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"reportWSConnected"]) {
        NSLog(@"OBSERVED!");
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [self updateWSText];
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

- (IBAction)cafeWSChanged:(id)sender {
    if (appDelegate.reportWSConnected) {
        [appDelegate.reportWS close];
    }
    appDelegate.reportWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_cafeWSEntry.text]]];
    appDelegate.reportWS.delegate = appDelegate;
    [appDelegate.reportWS open];
}

- (IBAction)cafeWSConnectClick:(id)sender {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if (appDelegate.reportWSConnected) {
        [appDelegate.reportWS close];
    } else {
        appDelegate.reportWS = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_cafeWSEntry.text]]];
        appDelegate.reportWS.delegate = appDelegate;
        [appDelegate.reportWS open];
    }
}
@end
