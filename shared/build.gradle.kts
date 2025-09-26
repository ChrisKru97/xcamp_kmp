import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    alias(libs.plugins.kotlinSerialization)
    alias(libs.plugins.sqlDelight)
}

kotlin {
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }

    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "shared"
            isStatic = true
        }
    }

    sourceSets {
        commonMain.dependencies {
            // Coroutines
            implementation(libs.kotlinx.coroutines.core)

            // Serialization
            implementation(libs.kotlinx.serialization.json)

            // DateTime
            implementation(libs.kotlinx.datetime)

            // Ktor Client
            implementation(libs.ktor.client.core)

            // SQLDelight
            implementation(libs.sqldelight.runtime)
            implementation(libs.sqldelight.coroutines)

            // Firebase GitLive SDK
            implementation(libs.firebase.app)
            implementation(libs.firebase.auth)
            implementation(libs.firebase.firestore)
            implementation(libs.firebase.storage)
            implementation(libs.firebase.analytics)
            implementation(libs.firebase.crashlytics)
            implementation(libs.firebase.messaging)
            implementation(libs.firebase.config)

            // Multiplatform Settings
            implementation(libs.multiplatform.settings)

            // Image Loading
            implementation(libs.kamel.image)

            // Permissions
            implementation(libs.moko.permissions)

            // Dependency Injection
            implementation(libs.koin.core)

            // Logging
            implementation(libs.napier)

            // UUID
            implementation(libs.kotlin.uuid)

            // Notifications
            implementation(libs.kmpnotifier)
        }

        androidMain.dependencies {
            implementation(libs.kotlinx.coroutines.android)
            implementation(libs.ktor.client.okhttp)
            implementation(libs.sqldelight.android.driver)
            implementation(libs.koin.android)
        }

        iosMain.dependencies {
            implementation(libs.ktor.client.darwin)
            implementation(libs.sqldelight.native.driver)
        }

        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "cz.krutsche.xcamp.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

sqldelight {
    databases {
        create("XcampDatabase") {
            packageName.set("cz.krutsche.xcamp.shared.db")
        }
    }
}