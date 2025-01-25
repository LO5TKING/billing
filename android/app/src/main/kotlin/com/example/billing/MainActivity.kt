package com.example.billing

import android.os.Build
import android.view.MotionEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
//    private val CHANNEL = "palm_rejection"

//    private var isPalmRejectionEnabled = true

//    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
//        if (ev != null) {
//            for (i in 0 until ev.pointerCount) {
//                val toolType = ev.getToolType(i)
//                print("event tool type is $toolType")
//
//                // Check for palm rejection on Android 13 and above (API level 33+)
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
//                    // Android 13+ uses ACTION_CANCEL for palm rejection
//                    if (ev.action == MotionEvent.FLAG_CANCELED) {
//                        // Reject the palm touch
//                        return true // Consume the event to reject palm touches
//                    }
//                } else {
//                    // Older Android versions: Reject palm touches by checking for TOOL_TYPE_FINGER
//                    if (toolType == MotionEvent.TOOL_TYPE_FINGER) {
//                        // Reject palm touches on previous versions by simply ignoring the event
//                        return true // Consume the event to reject palm touches
//                    }
//                }
//            }
//        }
//        return super.dispatchTouchEvent(ev)
//    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//            .setMethodCallHandler { call, result ->
//                when (call.method) {
//                    "setPalmRejection" -> {
//                        val enabled = call.argument<Boolean>("enabled") ?: false
//                        isPalmRejectionEnabled = enabled
//                        result.success(null)
//                    }
//                    else -> result.notImplemented()
//                }
//            }
    }
}

