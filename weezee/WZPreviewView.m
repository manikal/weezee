//
//  WeeZeePreviewView.m
//  weezee
//
//  Created by Mijo Kaliger on 31/10/2020.
//

@import AVFoundation;

#import "WZPreviewView.h"

@implementation WZPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer*)videoPreviewLayer
{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (AVCaptureSession*)session
{
    return self.videoPreviewLayer.session;
}

- (void)setSession:(AVCaptureSession*)session
{
    self.videoPreviewLayer.session = session;
}

@end
