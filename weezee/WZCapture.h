//
//  VZCapture.h
//  weezee
//
//  Created by Mijo Kaliger on 05/11/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^WZCaptureSetupCompletion)(NSError * _Nullable error);

@protocol AVCaptureVideoDataOutputSampleBufferDelegate;

@interface WZCapture : NSObject

-(instancetype)initWithSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate completion:(WZCaptureSetupCompletion)completion;

@property (strong, nonatomic, readonly) AVCaptureSession* captureSession;
@property (assign, nonatomic, readonly) double bufferAspectRatio;

@end

NS_ASSUME_NONNULL_END
