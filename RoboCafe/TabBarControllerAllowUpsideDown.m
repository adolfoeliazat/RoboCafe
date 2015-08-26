//
//  TabBarControllerAllowUpsideDown.m
//  RoboCafe
//
//  Created by Patrick Pannuto on 8/25/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

#import "TabBarControllerAllowUpsideDown.h"

@implementation TabBarControllerAllowUpsideDown

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
