//
//  ALPSCore.h
//
//
//  Created by Patrick Lazik on 8/8/15.
//
//

#import <AVFoundation/AVFoundation.h>

#define SAMPLE_RATE 48000
#define INPUT_GAIN 1.0
#define kOutputBus 0
#define kInputBus 1
#define ALPS_OK 0
#define ALPS_ERROR -1
#define MAX_CYLCES_PER_BUFFER 4

@class iBeaconManager;

@protocol ALPSDelegate <NSObject>
- (void)ALPSDidReceiveData:(NSArray*) toa :(NSArray*) rssi;
@end

@interface ALPSCore : NSObject{
    AVAudioSession              *session;
    dispatch_queue_t            ALPSQueue;
    
    UInt32                      bufferSize;
    AudioStreamBasicDescription audioFormat;
    AudioUnit                   audioUnit;
    Float32                     *audioBuffer;
    UInt32                      audioBufferCurrentIndex;
    
    UInt32                      tdmaSlots;
    
    UInt32                      buffCnt;
    double                      t0Buf;
    
    iBeaconManager              *beaconManager;
    
    NSMutableArray              *toa;
    NSMutableArray              *rssi;
}

@property(readonly) BOOL running;
@property(readonly) BOOL processing;
@property(readonly) BOOL needsAudioData;
@property(readonly) BOOL hasAudioData;
@property(nonatomic) float thresholdDivisor;
@property(nonatomic) float thresholdMultiplier;
@property NSMutableArray *t0iBeacon;
@property (nonatomic, weak) id <ALPSDelegate> delegate;


- (id)initWithOptions:(UInt32) bufferLength :(UInt32) slots;
- (void)checkStatus:(OSStatus)status :(NSString*)errMsg;
- (int)start;
- (int)stop;
- (int) writeWav:(NSString*) wavName;
- (NSData*)toaAndRSSIToJSON:(NSArray*) toaData :(NSArray*) rssiData;
- (NSString*)toaToTDOAString:(NSArray*) toaData;
- (NSDictionary*)jsonPositionToDictionary:(NSString*) position;
@end
