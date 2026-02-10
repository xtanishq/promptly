import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.stonekross.promptly"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.stonekross.promptly"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // 2. Logic: Try local file first, then try GitHub Environment variables
            keyAlias = (keystoreProperties["keyAlias"] as String?)
                ?: System.getenv("KEY_ALIAS")

            keyPassword = (keystoreProperties["keyPassword"] as String?)
                ?: System.getenv("KEY_PASSWORD")

            storePassword = (keystoreProperties["storePassword"] as String?)
                ?: System.getenv("KEYSTORE_PASSWORD")

            // 3. Handle the Keystore file path correctly for both environments
            val stFile = keystoreProperties["storeFile"] as String?
            if (stFile != null) {
                // Local MacBook path (points to what's inside key.properties)
                storeFile = file(stFile)
            } else {
                // GitHub Actions path (where the .yml script places the file)
                storeFile = file("../upload-keystore.jks")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Debug key hatakar asli release key use hogi
            signingConfig = signingConfigs.getByName("release")

            // Play Store ke liye optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}