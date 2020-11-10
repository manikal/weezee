//
//  WeeZeeViewController.h
//  weezee
//
//  Created by Mijo Kaliger on 31/10/2020.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WZCameraViewController;

@protocol WZCameraViewControllerDelegate <NSObject>

@optional
- (void)cameraViewController:(WZCameraViewController *)cameraViewController recognizedString:(NSString *)recognizedString;

@end

@interface WZCameraViewController : UIViewController

@property(nullable,nonatomic,weak) id <WZCameraViewControllerDelegate> delegate;
@property(nullable, nonatomic,strong) UIView *cameraOverlayView;

@end

NS_ASSUME_NONNULL_END
