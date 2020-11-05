//
//  WZVisionRecognition.m
//  weezee
//
//  Created by Mijo Kaliger on 05/11/2020.
//

@import Vision;

#import "WZVisionRecognition.h"

@interface WZVisionRecognition ()

@property (strong, nonatomic) VNRecognizeTextRequest *request;
@property (copy, nonatomic) VNRequestCompletionHandler recognizeTextHandler;

@end

@implementation WZVisionRecognition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:self.recognizeTextHandler];
        
        self.request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
        self.request.usesLanguageCorrection = NO;
    }
    return self;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    if (imageBuffer) {
        VNImageRequestHandler *imageRequestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:imageBuffer orientation:kCGImagePropertyOrientationRight options:@{}];
    
        NSError *error;
        [imageRequestHandler performRequests:@[self.request] error:&error];
        
        if (error) {
            NSLog(@"Request failed: %@", error);
        }
    }
}

- (VNRequestCompletionHandler)recognizeTextHandler {
    
    VNRequestCompletionHandler handler = ^(VNRequest *request, NSError * _Nullable error) {
        if (!error) {
            for (VNRecognizedTextObservation *result in request.results) {
                VNRecognizedText *recognizedText = [result topCandidates:1].firstObject;
                
                NSLog(@"%@", recognizedText.string);
                
            }
        } else {
            NSLog(@"%@", [error description]);
        }
    };
    
    return handler;
}

- (void)setRegionOfInterest:(CGRect)regionOfInterest {
    self.request.regionOfInterest = regionOfInterest;
}

@end
