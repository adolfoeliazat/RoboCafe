//
//  ViewControllerSettings.m
//  RoboCafe
//
//  Created by Patrick Lazik on 8/11/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "ViewControllerSettings.h"
#import "AppDelegate.h"
#import <ALPS/ALPS.h>

@interface ViewControllerSettings ()

@end

@implementation ViewControllerSettings

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setVCSettings:self];
    alps = [appDelegate ALPS];
    
    _alpsWSEntry.text = DEFAULT_ALPS_WEBSOCKET;
    
    _thresholdDivisorSlider.minimumValue = 1;
    _thresholdDivisorSlider.maximumValue = 10;
    _thresholdDivisorSlider.continuous = NO;
    _thresholdDivisorSlider.value = [alps thresholdDivisor];
    _thresholdDivisorLabel.text = [[NSNumber numberWithFloat:[alps thresholdDivisor]] stringValue];
    
    _thresholdMultiplierSlider.minimumValue = 1;
    _thresholdMultiplierSlider.maximumValue = 100;
    _thresholdMultiplierSlider.continuous = NO;
    _thresholdMultiplierSlider.value = [alps thresholdMultiplier];
    _thresholdMultiplierLabel.text = [[NSNumber numberWithFloat:[alps thresholdMultiplier]] stringValue];
    
    if (appDelegate.alpsWSState == WebsocketStateConnected){
        [_solverConnectionStatusLabel setText:@"Connected"];
        [_solverConnectionStatusLabel setTextColor:[UIColor greenColor]];
    } else if (appDelegate.alpsWSState == WebsocketStateConnecting) {
        [_solverConnectionStatusLabel setText:@"Connecting..."];
        [_solverConnectionStatusLabel setTextColor:[UIColor orangeColor]];
    } else {
        [_solverConnectionStatusLabel setText:@"Disconnected"];
        [_solverConnectionStatusLabel setTextColor:[UIColor redColor]];
    }
    
    if([appDelegate position] != nil){
        float x = [[[appDelegate position] objectForKey:@"x"] floatValue];
        float y = [[[appDelegate position] objectForKey:@"y"] floatValue];
        [_positionField setText:[NSString stringWithFormat:@"X: %.2f, Y: %.2f", x, y]];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)thresholdDivisorAction:(id)sender {
    [alps setThresholdDivisor:_thresholdDivisorSlider.value];
    _thresholdDivisorLabel.text = [[NSNumber numberWithFloat:_thresholdDivisorSlider.value] stringValue];
}

- (IBAction)thresholdMultiplierAction:(id)sender {
    [alps setThresholdMultiplier:_thresholdMultiplierSlider.value];
    _thresholdMultiplierLabel.text = [[NSNumber numberWithFloat:_thresholdMultiplierSlider.value] stringValue];
}

- (IBAction)alpsWSChanged:(id)sender {
    if (appDelegate.alpsWSState != WebsocketStateDisconnected) {
        [appDelegate.alpsWS close];
    }
    appDelegate.alpsWSAddress = self.alpsWSEntry.text;
    [appDelegate alpsWSConnect];
}

- (IBAction)alpsWSReconnect:(id)sender {
    if (appDelegate.alpsWSState != WebsocketStateDisconnected) {
        [appDelegate.alpsWS close];
    }
    [appDelegate alpsWSConnect];
}


@end
