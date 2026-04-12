package com.sparkle.sparkle_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.amplifyframework.ui.liveness.model.FaceLivenessDetectionException
import com.amplifyframework.ui.liveness.ui.FaceLivenessDetector

class LivenessActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sessionId = intent.getStringExtra(EXTRA_SESSION_ID)
        val region = intent.getStringExtra(EXTRA_REGION) ?: "us-east-1"

        if (sessionId == null) {
            sendError("Missing session ID")
            return
        }

        // Camera permission is already granted by Flutter before launching this activity
        setContent {
            FaceLivenessDetector(
                sessionId = sessionId,
                region = region,
                onComplete = {
                    Log.i("LivenessActivity", "Liveness check passed")
                    setResult(Activity.RESULT_OK)
                    finish()
                },
                onError = { error: FaceLivenessDetectionException ->
                    Log.e("LivenessActivity", "Liveness check failed: ${error.message}")
                    sendError(error.message ?: "Liveness check failed")
                }
            )
        }
    }

    private fun sendError(message: String) {
        setResult(Activity.RESULT_CANCELED, Intent().putExtra(EXTRA_ERROR, message))
        finish()
    }

    companion object {
        const val EXTRA_SESSION_ID = "sessionId"
        const val EXTRA_REGION = "region"
        const val EXTRA_ERROR = "error"
    }
}
