//
//  ALPS.h
//  ALPS
//
//  Created by Patrick Lazik on 8/8/15.
//  Copyright (c) 2015 Carnegie Mellon University. All rights reserved.
//

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




