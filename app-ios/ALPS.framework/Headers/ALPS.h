/******************************************************************************
 *  ALPS, The Acoustic Location Processing System.
 *  ALPS.h
 *  Copyright (C) 2015, WiSE Lab, Carnegie Mellon University
 *  All rights reserved.
 *
 *  This software is the property of Carnegie Mellon University. Source may
 *  be modified, but this license does not allow distribution.  Binaries built
 *  for research purposes may be freely distributed, but must acknowledge
 *  Carnegie Mellon University.  No other use or distribution can be made
 *  without the written permission of the authors and Carnegie Mellon
 *  University.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  Contributing Author(s):
 *  Patrick Lazik
 *
 *******************************************************************************/

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//! Project version number for ALPS.
FOUNDATION_EXPORT double ALPSVersionNumber;

//! Project version string for ALPS.
FOUNDATION_EXPORT const unsigned char ALPSVersionString[];

#define ALPS_OK 0
#define ALPS_ERROR -1

@protocol ALPSDelegate <NSObject>
- (void)ALPSDidReceiveData:(NSArray*) toa :(NSArray*) rssi;
@end

@interface ALPS : NSObject

@property(readonly) BOOL running;
@property(nonatomic) float thresholdDivisor;
@property(nonatomic) float thresholdMultiplier;
@property (nonatomic, weak) id <ALPSDelegate> delegate;

- (id) initWithOptions:(UInt32) bufferLength :(UInt32) slots;
- (void) checkStatus:(OSStatus)status :(NSString*)errMsg;
- (int) start;
- (int) stop;
- (int) writeWav:(NSString*) wavName;
- (NSData*) toaAndRSSIToJSON:(NSArray*) toaData :(NSArray*) rssiData;
- (NSString*) toaToTDOAString:(NSArray*) toaData;
- (NSDictionary*) jsonPositionToDictionary:(NSString*) position;
@end




