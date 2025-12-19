#import <React/RCTEventEmitter.h>
#import <ReactNativeShakeSpec/ReactNativeShakeSpec.h>

@interface ReactNativeShake : RCTEventEmitter <NativeReactNativeShakeSpec>

@property(nonatomic, assign) BOOL isListening;
@property(nonatomic, assign) BOOL hasListeners;

- (void)sendShakeEvent;

@end
