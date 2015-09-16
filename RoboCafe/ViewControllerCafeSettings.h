//
//  ViewControllerCafeSettings.h
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/12/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface ViewControllerCafeSettings : UIViewController <UITextFieldDelegate> {
    AppDelegate *appDelegate;
}

- (void)updateCafeOrderWSText;
- (void)updateLocationAnnounceWSText;


@property (weak, nonatomic) IBOutlet UILabel *cafeStatusLabel;
@property (weak, nonatomic) IBOutlet UITextField *cafeWSEntry;
- (IBAction)cafeWSClear:(id)sender;
- (IBAction)cafeWSEditingEnd:(id)sender;


- (IBAction)cafeWSConnectClick:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *locationStatusLabel;

@property (weak, nonatomic) IBOutlet UITextField *locationWSEntry;
- (IBAction)locationWSClear:(id)sender;
- (IBAction)locationWSEditingEnd:(id)sender;

- (IBAction)locationWSConnectClick:(id)sender;

/*** DEBUGGING FEATURES *************************************************/

@property (weak, nonatomic) IBOutlet UISwitch *enableAllButtonsSwitch;
- (IBAction)enableAllButtonsSwitchValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *postLocationXTextField;
- (IBAction)postLocationXEditingEnd:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *postLocationYTextField;
- (IBAction)postLocationYEditingEnd:(id)sender;
- (IBAction)postLocationButtonTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *vendorIDLabel;

@end
