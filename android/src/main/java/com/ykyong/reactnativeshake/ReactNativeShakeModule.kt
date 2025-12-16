package com.ykyong.reactnativeshake

import android.hardware.Sensor
import android.hardware.SensorManager
import android.content.Context
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = ReactNativeShakeModule.NAME)
class ReactNativeShakeModule(reactContext: ReactApplicationContext) :
  NativeReactNativeShakeSpec(reactContext) {

  private var sensorManager: SensorManager? = null
  private var accelerometer: Sensor? = null
  private var shakeDetector: ShakeDetector? = null
  private var isListening = false

  init {
    sensorManager = reactContext.getSystemService(Context.SENSOR_SERVICE) as? SensorManager
    accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
  }

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  override fun startShakeDetection() {
    if (isListening) {
      return
    }

    shakeDetector = ShakeDetector {
      sendShakeEvent()
    }

    accelerometer?.let {
      sensorManager?.registerListener(
        shakeDetector,
        it,
        SensorManager.SENSOR_DELAY_UI
      )
      isListening = true
    }
  }

  @ReactMethod
  override fun stopShakeDetection() {
    if (!isListening) {
      return
    }

    shakeDetector?.let {
      sensorManager?.unregisterListener(it)
    }
    shakeDetector = null
    isListening = false
  }

  @ReactMethod
  override fun addListener(eventType: String) {
    // Required for event emitter - no-op implementation
  }

  @ReactMethod
  override fun removeListeners(count: Double) {
    // Required for event emitter - no-op implementation
  }

  private fun sendShakeEvent() {
    reactApplicationContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      ?.emit("ShakeEvent", null)
  }

  override fun onCatalystInstanceDestroy() {
    super.onCatalystInstanceDestroy()
    stopShakeDetection()
  }

  companion object {
    const val NAME = "ReactNativeShake"
  }
}
