import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.multiversodigital.scannutplus"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.multiversodigital.scannutplus"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // ESTA É A FORMA CORRETA DE PASSAR A KEY:
        manifestPlaceholders["GOOGLE_API_KEY"] = "AIzaSyCfXsXV7LHEV-EEhH4lddqJ7K6-8BbdxP0"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // Mude para release depois
        }
    }
}

flutter {
    source = "../.."
}
