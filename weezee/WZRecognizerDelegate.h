//
//  WZRecognizerDelegate.h
//  weezee
//
//  Created by Mijo Kaliger on 07/11/2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WZRecognizerDelegate;

@protocol WZRecognizer <NSObject>

@property(nullable,nonatomic,weak) id <WZRecognizerDelegate>recognitionDelegate;

@end

@protocol WZRecognizerDelegate <NSObject>
@optional
-(void)recognizer:(id<WZRecognizer>)recognizer recognizedString:(NSString *)recognizedString;

@end

NS_ASSUME_NONNULL_END
