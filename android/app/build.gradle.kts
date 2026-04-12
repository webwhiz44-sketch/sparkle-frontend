plugins {
    id("com.android.application")
    id("kotlin-android")
    id("org.jetbrains.kotlin.plugin.compose")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.sparkle.sparkle_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildFeatures {
        compose = true
    }

    defaultConfig {
        applicationId = "com.sparkle.sparkle_app"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// Force all Amplify Android modules to the same version so smithy-kotlin
// transitive dependencies resolve consistently and don't get downgraded.
configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.amplifyframework" && requested.version != null) {
            useVersion("2.22.0")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // AWS Amplify Auth (Cognito Identity Pool credentials for FaceLivenessDetector)
    implementation("com.amplifyframework:aws-auth-cognito:2.22.0")

    // AWS Predictions — contains LivenessWebSocket and its smithy-kotlin deps
    implementation("com.amplifyframework:aws-predictions:2.22.0")

    // AWS Amplify UI Face Liveness (FaceLivenessDetector composable)
    implementation("com.amplifyframework.ui:liveness:1.2.0")

    // Compose (required by LivenessActivity)
    implementation(platform("androidx.compose:compose-bom:2024.12.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.activity:activity-compose:1.9.3")
}
