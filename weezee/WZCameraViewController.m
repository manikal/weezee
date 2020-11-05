//
//  WeeZeeViewController.m
//  weezee
//
//  Created by Mijo Kaliger on 31/10/2020.
//

#import "WZCameraViewController.h"
#import "WZPreviewView.h"
#import "WZCapture.h"
#import "WZVisionRecognition.h"

@interface WZCameraViewController ()

@property (weak, nonatomic) IBOutlet WZPreviewView *previewView;
@property (strong, nonatomic) WZCapture *capture;
@property (strong, nonatomic) WZVisionRecognition *visionRecognition;

@end

@implementation WZCameraViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    NSURL *resourceURL = [frameworkBundle URLForResource:@"WeeZeeResources" withExtension:@"bundle"];
    NSBundle *bundleResources = [NSBundle bundleWithURL:resourceURL];
    
    self = [super initWithNibName:@"WZCameraViewController" bundle:bundleResources];
    
    self.visionRecognition = [WZVisionRecognition new];
    
    __typeof(self) __weak weakSelf = self;
    self.capture = [[WZCapture alloc] initWithSampleBufferDelegate:self.visionRecognition completion:^(NSError * _Nullable error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                strongSelf.previewView.session = strongSelf.capture.captureSession;
                strongSelf.visionRecognition.regionOfInterest = [self calculateRegionOfInterest];
            });
        } else {
            NSLog(@"Error setting up capture: %@", [error description]);
        }
    }];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (CGRect)calculateRegionOfInterest {
    CGRect regionOfInterest = CGRectMake(0, 0, 1, 1);
    
    double desiredHeightRatio = 0.15;
    double desiredWidthRatio = 0.6;
    double maxPortraitWidth = 0.8;
    
    CGSize size = CGSizeMake(MIN(desiredWidthRatio * self.capture.bufferAspectRatio, maxPortraitWidth), desiredHeightRatio / self.capture.bufferAspectRatio);
   
    // Make it centered.
    regionOfInterest.origin = CGPointMake((1-size.width) / 2, (1-size.height) / 2);
    regionOfInterest.size = size;
    
    return regionOfInterest;
}

@end
