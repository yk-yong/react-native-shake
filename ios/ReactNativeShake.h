#import <ReactNativeShakeSpec/ReactNativeShakeSpec.h>
#import <React/RCTEventEmitter.h>

@interface ReactNativeShake : RCTEventEmitter <NativeReactNativeShakeSpec>

@property (nonatomic, assign) BOOL isListening;
@property (nonatomic, assign) BOOL hasListeners;

@end
