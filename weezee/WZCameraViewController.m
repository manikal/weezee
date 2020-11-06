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
@property (weak, nonatomic) IBOutlet UIView *cutoutView;
@property (strong, nonatomic) CAShapeLayer *maskLayer;
@property (assign, nonatomic) CGAffineTransform bottomToTopTransform;
@property (assign, nonatomic) CGRect regionOfInterest;

@end

@implementation WZCameraViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.mijokaliger.weezee"];
    NSURL *resourceURL = [frameworkBundle URLForResource:@"WeeZeeResources" withExtension:@"bundle"];
    NSBundle *bundleResources = [NSBundle bundleWithURL:resourceURL];
    
    self = [super initWithNibName:@"WZCameraViewController" bundle:bundleResources];
    
    self.visionRecognition = [WZVisionRecognition new];
    

    
    self.bottomToTopTransform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, -1);
    
    __typeof(self) __weak weakSelf = self;
    self.capture = [[WZCapture alloc] initWithSampleBufferDelegate:self.visionRecognition completion:^(NSError * _Nullable error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                strongSelf.previewView.session = strongSelf.capture.captureSession;
                self.regionOfInterest = [self calculateRegionOfInterest];
                strongSelf.visionRecognition.regionOfInterest = self.regionOfInterest;
                
                [strongSelf updateCutout];
            });
        } else {
            NSLog(@"Error setting up capture: %@", [error description]);
        }
    }];
    
    return self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maskLayer = [CAShapeLayer new];
    self.cutoutView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.cutoutView.layer.mask = self.maskLayer;
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

- (void)updateCutout {
    CGAffineTransform portaitUpTransform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, 1), -M_PI_2);

    // Figure out where the cutout ends up in layer coordinates.
    CGAffineTransform roiRectTransform = CGAffineTransformConcat(self.bottomToTopTransform, portaitUpTransform);
    
    CGRect cutoutRect = [self.previewView.videoPreviewLayer rectForMetadataOutputRectOfInterest:CGRectApplyAffineTransform(self.regionOfInterest, roiRectTransform)];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.cutoutView.frame];
    [path appendPath:[UIBezierPath bezierPathWithRect:cutoutRect]];
    self.maskLayer.path = path.CGPath;
}



@end
