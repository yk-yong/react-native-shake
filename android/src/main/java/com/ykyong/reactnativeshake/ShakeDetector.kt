package com.ykyong.reactnativeshake

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import kotlin.math.sqrt

class ShakeDetector(private val onShake: () -> Unit) : SensorEventListener {
    private var lastTime: Long = 0
    private var lastX = 0f
    private var lastY = 0f
    private var lastZ = 0f

    companion object {
        private const val SHAKE_THRESHOLD = 800
        private const val TIME_THRESHOLD = 100
    }

    override fun onSensorChanged(event: SensorEvent) {
        val currentTime = System.currentTimeMillis()

        if ((currentTime - lastTime) > TIME_THRESHOLD) {
            val diffTime = currentTime - lastTime
            lastTime = currentTime

            val x = event.values[0]
            val y = event.values[1]
            val z = event.values[2]

            val speed = sqrt(
                ((x - lastX) * (x - lastX) +
                (y - lastY) * (y - lastY) +
                (z - lastZ) * (z - lastZ)).toDouble()
            ) / diffTime * 10000

            if (speed > SHAKE_THRESHOLD) {
                onShake()
            }

            lastX = x
            lastY = y
            lastZ = z
        }
    }

    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
        // Not used
    }
}

