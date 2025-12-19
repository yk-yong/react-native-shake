#import "ReactNativeShake.h"
#import <React/RCTBridge.h>
#import <UIKit/UIKit.h>

@interface ShakeWindow : UIWindow
@property(nonatomic, weak) ReactNativeShake *shakeModule;
@end

@implementation ShakeWindow

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (motion == UIEventSubtypeMotionShake && self.shakeModule.isListening) {
    [self.shakeModule sendShakeEvent];
  }
  [super motionEnded:motion withEvent:event];
}

@end

@implementation ReactNativeShake

RCT_EXPORT_MODULE()

- (instancetype)init {
  if (self = [super init]) {
    _isListening = NO;
    _hasListeners = NO;
  }
  return self;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[ @"ShakeEvent" ];
}

- (void)startObserving {
  _hasListeners = YES;
}

- (void)stopObserving {
  _hasListeners = NO;
}

- (void)startShakeDetection {
  if (_isListening) {
    return;
  }

  _isListening = YES;

  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window = [self getKeyWindow];
    if (window && ![window isKindOfClass:[ShakeWindow class]]) {
      ShakeWindow *shakeWindow =
          [[ShakeWindow alloc] initWithFrame:window.frame];
      shakeWindow.shakeModule = self;
      shakeWindow.rootViewController = window.rootViewController;
      shakeWindow.windowLevel = window.windowLevel;
      [shakeWindow makeKeyAndVisible];
    } else if ([window isKindOfClass:[ShakeWindow class]]) {
      ((ShakeWindow *)window).shakeModule = self;
    }
  });
}

- (void)stopShakeDetection {
  if (!_isListening) {
    return;
  }

  _isListening = NO;

  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *window = [self getKeyWindow];
    if ([window isKindOfClass:[ShakeWindow class]]) {
      ((ShakeWindow *)window).shakeModule = nil;
    }
  });
}

- (void)sendShakeEvent {
  if (_hasListeners) {
    [self sendEventWithName:@"ShakeEvent" body:@{}];
  }
}

- (UIWindow *)getKeyWindow {
  NSArray<UIWindow *> *windows = [[UIApplication sharedApplication] windows];
  for (UIWindow *window in windows) {
    if (window.isKeyWindow) {
      return window;
    }
  }
  return nil;
}

- (void)addListener:(NSString *)eventType {
  // Required for RCTEventEmitter
}

- (void)removeListeners:(double)count {
  // Required for RCTEventEmitter
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeReactNativeShakeSpecJSI>(
      params);
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

@end
