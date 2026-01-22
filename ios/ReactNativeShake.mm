#import "ReactNativeShake.h"
#import <React/RCTBridge.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static __weak ReactNativeShake *gShakeModule = nil;

@interface UIWindow (ReactNativeShake)
@end

@implementation UIWindow (ReactNativeShake)

- (void)rns_motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  [self rns_motionEnded:motion withEvent:event];

  ReactNativeShake *module = gShakeModule;
  if (motion == UIEventSubtypeMotionShake && module && module.isListening) {
    [module sendShakeEvent];
  }
}

@end

static void rns_swizzleMotionEndedIfNeeded(void) {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = [UIWindow class];
    SEL originalSelector = @selector(motionEnded:withEvent:);
    SEL swizzledSelector = @selector(rns_motionEnded:withEvent:);

    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    if (!originalMethod || !swizzledMethod) {
      return;
    }

    method_exchangeImplementations(originalMethod, swizzledMethod);
  });
}

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
    rns_swizzleMotionEndedIfNeeded();
    gShakeModule = self;
    NSLog(@"[ReactNativeShake] Shake detection started");
  });
}

- (void)stopShakeDetection {
  if (!_isListening) {
    return;
  }

  _isListening = NO;

  dispatch_async(dispatch_get_main_queue(), ^{
    if (gShakeModule == self) {
      gShakeModule = nil;
    }
    NSLog(@"[ReactNativeShake] Shake detection stopped");
  });
}

- (void)sendShakeEvent {
  if (_hasListeners) {
    [self sendEventWithName:@"ShakeEvent" body:@{}];
  }
}

- (void)addListener:(NSString *)eventType {
  [super addListener:eventType];
}

- (void)removeListeners:(double)count {
  [super removeListeners:count];
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
