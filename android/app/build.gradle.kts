import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

/* 🔐 Load keystore properties */
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.techgigs.policydukan"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.techgigs.policydukan"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = 2
        versionName = "1.0.0"

        /* 16KB alignment support */
        externalNativeBuild {
            cmake {
                arguments("-DANDROID_EXT_COMP_16K=ON")
            }
        }
    }

    /* 🔐 Signing config */
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }

        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true

            /* 16KB linker page size */
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
