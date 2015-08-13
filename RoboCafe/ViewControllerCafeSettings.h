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

@property (weak, nonatomic) IBOutlet UILabel *cafeStatusLabel;

@property (weak, nonatomic) IBOutlet UITextField *cafeWSEntry;
- (IBAction)cafeWSChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *cafeWSConnectButton;
- (IBAction)cafeWSConnectClick:(id)sender;

@end
