package com.sparkle.sparkle_app

import android.app.Application
import android.util.Log
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin
import com.amplifyframework.core.Amplify

class SparkleApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        try {
            Amplify.addPlugin(AWSCognitoAuthPlugin())
            Amplify.configure(applicationContext)
            Log.i("SparkleApp", "Amplify configured successfully")
        } catch (e: Exception) {
            Log.e("SparkleApp", "Amplify configuration failed", e)
        }
    }
}
