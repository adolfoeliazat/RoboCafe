//
//  ViewControllerSettings.h
//  RoboCafe
//
//  Created by Patrick Lazik on 8/11/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate, ALPS;

@interface ViewControllerSettings : UIViewController <UITextFieldDelegate> {
    AppDelegate *appDelegate;
    ALPS *alps;
}

@property (weak, nonatomic) IBOutlet UILabel *solverConnectionStatusLabel;


@property (weak, nonatomic) IBOutlet UITextField *alpsWSEntry;
- (IBAction)alpsWSEditingEnd:(id)sender;
- (IBAction)alpsWSReconnect:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *alpsWSClear;
@property (weak, nonatomic) IBOutlet UIImageView *thresholdDivisorClear;
@property (weak, nonatomic) IBOutlet UIImageView *thresholdMultiplierClear;

@property (weak, nonatomic) IBOutlet UISlider *thresholdDivisorSlider;
@property (weak, nonatomic) IBOutlet UISlider *thresholdMultiplierSlider;
@property (weak, nonatomic) IBOutlet UILabel *thresholdDivisorLabel;
@property (weak, nonatomic) IBOutlet UILabel *thresholdMultiplierLabel;


@property (weak, nonatomic) IBOutlet UILabel *tdoaDataField;
- (IBAction)thresholdDivisorAction:(id)sender;
- (IBAction)thresholdMultiplierAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *positionField;


@end
