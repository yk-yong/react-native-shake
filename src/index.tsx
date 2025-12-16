import { NativeEventEmitter, NativeModules } from 'react-native';
import ReactNativeShake from './NativeReactNativeShake';

const eventEmitter = new NativeEventEmitter(NativeModules.ReactNativeShake);

export function startShakeDetection(): void {
  ReactNativeShake.startShakeDetection();
}

export function stopShakeDetection(): void {
  ReactNativeShake.stopShakeDetection();
}

export function addShakeListener(callback: () => void) {
  return eventEmitter.addListener('ShakeEvent', callback);
}

export { eventEmitter as shakeEventEmitter };
