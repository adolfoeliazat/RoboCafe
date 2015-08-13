//
//  ViewControllerCafeSettings.h
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/12/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface ViewControllerCafeSettings : UIViewController {
    AppDelegate *appDelegate;
}

- (void)updateWSText;
- (void)updateLocationAnnounceWSText;

@property (weak, nonatomic) IBOutlet UILabel *cafeStatusLabel;

@property (weak, nonatomic) IBOutlet UITextField *cafeWSEntry;
- (IBAction)cafeWSChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *cafeWSConnectButton;
- (IBAction)cafeWSConnectClick:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *locationStatusLabel;

@property (weak, nonatomic) IBOutlet UITextField *locationWSEntry;
- (IBAction)locationWSChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *locationWSConnectButton;
- (IBAction)locationWSConnectClick:(id)sender;


@end
