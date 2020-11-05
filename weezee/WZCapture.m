//
//  VZCapture.m
//  weezee
//
//  Created by Mijo Kaliger on 05/11/2020.
//


@import Photos;

#import "WZCapture.h"

typedef NS_ENUM(NSInteger, WZCameraSetupResult) {
    WZCameraSetupResultSuccess,
    WZCameraSetupResultCameraNotAuthorized,
    WZCameraSetupResultSessionConfigurationFailed
};

@interface WZCapture ()

@property (strong, nonatomic) AVCaptureSession* captureSession;
@property (strong, nonatomic) AVCaptureDevice* captureDevice;
@property (strong, nonatomic) dispatch_queue_t captureSessionQueue;
@property (strong, nonatomic) AVCaptureVideoDataOutput* videoDataOutput;
@property (strong, nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (assign, nonatomic) WZCameraSetupResult setupResult;
@property (assign, nonatomic) double bufferAspectRatio;
@property (strong, nonatomic) WZCaptureSetupCompletion completion;
@property (strong, nonatomic) id<AVCaptureVideoDataOutputSampleBufferDelegate> sampleBufferDelegate;

@end

@implementation WZCapture

- (instancetype)initWithSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)sampleBufferDelegate completion:(WZCaptureSetupCompletion)completion
{
    self = [super init];
    if (self) {
        self.completion = completion;
        self.captureSession = [AVCaptureSession new];
        self.captureSessionQueue = dispatch_queue_create("com.mijokaliger.weezee.CaptureSessionQueue", DISPATCH_QUEUE_SERIAL);
        self.sampleBufferDelegate = sampleBufferDelegate;
        self.videoDataOutput = [AVCaptureVideoDataOutput new];
        self.videoDataOutputQueue = dispatch_queue_create("com.mijokaliger.weezee.VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
                
        [self authCheck];
        
        dispatch_async(self.captureSessionQueue, ^{
            [self setupCamera];
        });
    }
    return self;
}


#pragma mark Private

- (void)authCheck {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
            */
            dispatch_suspend(self.captureSessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (!granted) {
                    self.setupResult = WZCameraSetupResultCameraNotAuthorized;
                }
                dispatch_resume(self.captureSessionQueue);
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            self.setupResult = WZCameraSetupResultCameraNotAuthorized;
            break;
        }
    }
}

- (void)setupCamera {
    
    NSError *error = nil;
    
    if (self.setupResult != WZCameraSetupResultSuccess) {
        [self finishWithErrorMessage:@"Please allow camera access"];
        return;
    }
    
    [self.captureSession beginConfiguration];
        
    // Choose the back dual camera if available, otherwise default to a wide angle camera.
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    if (!videoDevice) {
        // If a rear dual camera is not available, default to the rear wide angle camera.
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        
        // In the event that the rear wide angle camera isn't available, default to the front wide angle camera.
        if (!videoDevice) {
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    
    if ([videoDevice supportsAVCaptureSessionPreset:AVCaptureSessionPreset3840x2160]) {
        self.captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
        self.bufferAspectRatio = 3840.0/2160.0;
    } else {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        self.bufferAspectRatio = 1920.0/1080.0;
    }
    
    AVCaptureDeviceInput* videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (!videoDeviceInput) {
        self.setupResult = WZCameraSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        
        [self finishWithErrorMessage:@"Could not create video device input"];
        return;
    }
    
    if ([self.captureSession canAddInput:videoDeviceInput]) {
        [self.captureSession addInput:videoDeviceInput];
    } else {
        self.setupResult = WZCameraSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        
        [self finishWithErrorMessage:@"Could not add video device input to the session"];
        return;
    }
    
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoDataOutput setSampleBufferDelegate:self.sampleBufferDelegate queue:self.videoDataOutputQueue];
    self.videoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) };
    
    if ([self.captureSession canAddOutput:self.videoDataOutput]) {
        [self.captureSession addOutput:self.videoDataOutput];
    } else {
        self.setupResult = WZCameraSetupResultSessionConfigurationFailed;
        [self.captureSession commitConfiguration];
        
        [self finishWithErrorMessage:@"Could not add video device output to the session"];
        return;
    }
    
    [self.captureSession commitConfiguration];
    
    [self.captureSession startRunning];
    
    if (self.completion) {
        self.completion(nil);
    }
}

- (void)finishWithErrorMessage:(NSString *)errorMessage {
    NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:83 userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
    
    if (self.completion) {
        self.completion(error);
    }
}


@end
