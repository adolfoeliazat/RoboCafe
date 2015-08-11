//
//  ViewControllerSettings.h
//  RoboCafe
//
//  Created by Patrick Lazik on 8/11/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, ALPSCore;

@interface ViewControllerSettings : UIViewController{
    AppDelegate *appDelegate;
    ALPSCore *alps;
}

@property (weak, nonatomic) IBOutlet UILabel *solverConnectionStatusLabel;
@property (weak, nonatomic) IBOutlet UISlider *thresholdDivisorSlider;
@property (weak, nonatomic) IBOutlet UISlider *thresholdMultiplierSlider;
@property (weak, nonatomic) IBOutlet UILabel *thresholdDivisorLabel;
@property (weak, nonatomic) IBOutlet UILabel *thresholdMultiplierLabel;


@property (weak, nonatomic) IBOutlet UITextView *tdoaDataField;
- (IBAction)thresholdDivisorAction:(id)sender;
- (IBAction)thresholdMultiplierAction:(id)sender;


@end
