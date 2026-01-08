plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.techgigs.policydukaan"
    compileSdk = 36 // Updated for Android 15
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.techgigs.policydukaan"
        minSdk = flutter.minSdkVersion
        targetSdk = 35 // Updated for Android 15
        versionCode = 1
        versionName = "1.0.0"

        // Tells the NDK to support 16kb alignment during compilation
        externalNativeBuild {
            cmake {
                arguments("-DANDROID_EXT_COMP_16K=ON")
            }
        }
    }

    packaging {
        jniLibs {
            // CRITICAL: This allows the OS to load native libraries
            // directly from the APK with 16 KB page alignment.
            useLegacyPackaging = true
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            // Ensures the linker uses 16kb page size for release builds
            externalNativeBuild {
                cmake {
                    cppFlags("-Wl,-z,max-page-size=16384")
                }
            }
        }
    }
}

flutter {
    source = "../.."
}