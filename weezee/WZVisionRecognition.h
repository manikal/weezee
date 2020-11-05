//
//  WZVisionRecognition.h
//  weezee
//
//  Created by Mijo Kaliger on 05/11/2020.
//

@import AVFoundation;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WZVisionRecognition : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (assign, nonatomic) CGRect regionOfInterest;

@end

NS_ASSUME_NONNULL_END
