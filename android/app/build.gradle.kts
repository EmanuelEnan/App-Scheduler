plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_scheduler"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required for java.time.ZonedDateTime used in SchedulerPlugin & BootReceiver
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.app_scheduler"
        // minSdk 26 required for java.time.* APIs (ZonedDateTime, DateTimeFormatter)
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // java.time.* desugaring — needed for ZonedDateTime on older APIs
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // WorkManager — androidx.work.* used in SchedulerPlugin, AppLaunchWorker, BootReceiver
    implementation("androidx.work:work-runtime-ktx:2.9.0")

    // Kotlin coroutines — required by CoroutineWorker in AppLaunchWorker
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // App Startup — InitializationProvider referenced in AndroidManifest.xml
    implementation("androidx.startup:startup-runtime:1.1.1")
}