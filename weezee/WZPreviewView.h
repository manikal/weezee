//
//  WeeZeePreviewView.h
//  weezee
//
//  Created by Mijo Kaliger on 31/10/2020.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;
@class AVCaptureVideoPreviewLayer;

NS_ASSUME_NONNULL_BEGIN

@interface WZPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) AVCaptureSession *session;

@end

NS_ASSUME_NONNULL_END
