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


@end

