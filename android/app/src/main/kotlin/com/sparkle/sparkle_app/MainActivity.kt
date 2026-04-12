package com.sparkle.sparkle_app

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.sparkle.sparkle_app/liveness"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startLiveness" -> {
                        val sessionId = call.argument<String>("sessionId")
                        if (sessionId == null) {
                            result.error("INVALID_ARGS", "sessionId is required", null)
                            return@setMethodCallHandler
                        }
                        pendingResult = result
                        val intent = Intent(this, LivenessActivity::class.java).apply {
                            putExtra(LivenessActivity.EXTRA_SESSION_ID, sessionId)
                            putExtra(
                                LivenessActivity.EXTRA_REGION,
                                call.argument<String>("region") ?: "us-east-1"
                            )
                        }
                        @Suppress("DEPRECATION")
                        startActivityForResult(intent, LIVENESS_REQUEST_CODE)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == LIVENESS_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                pendingResult?.success(null)
            } else {
                val error = data?.getStringExtra(LivenessActivity.EXTRA_ERROR) ?: "Liveness check failed"
                pendingResult?.error("LIVENESS_FAILED", error, null)
            }
            pendingResult = null
        }
    }

    companion object {
        private const val LIVENESS_REQUEST_CODE = 1001
    }
}
