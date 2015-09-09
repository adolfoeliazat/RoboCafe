//
//  ViewController.h
//  RoboCafe
//
//  Created by Patrick Lazik on 8/9/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textField;

- (IBAction)orderTwixTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelTwixButton;
@property (weak, nonatomic) IBOutlet UIButton *orderTwixButton;
- (IBAction)cancelTwixTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *twixStatus;

@property (strong, nonatomic) IBOutlet UIButton *orderSquirtGunButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelSquirtGunButton;
@property (strong, nonatomic) IBOutlet UILabel *squirtGunStatus;
- (IBAction)orderSquirtGunTouch:(id)sender;
- (IBAction)cancelSquirtGunTouch:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *orderBouncyBallButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelBouncyBallButton;
@property (strong, nonatomic) IBOutlet UILabel *bouncyBallStatus;
- (IBAction)orderBouncyBallTouch:(id)sender;
- (IBAction)cancelBouncyBallTouch:(id)sender;

- (IBAction)goToTop:(id)sender;
- (IBAction)goToLeft:(id)sender;
- (IBAction)goToBottom:(id)sender;
- (IBAction)goToRight:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *roboCafeStatusLabel;

@end

