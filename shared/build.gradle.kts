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

    compilerOptions {
        freeCompilerArgs.add("-Xexpect-actual-classes")
    }

    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach {
        it.binaries.framework {
            baseName = "shared"
            isStatic = true
        }
        it.compilations.getByName("main") {
            compileTaskProvider.configure {
                compilerOptions {
                    freeCompilerArgs.add("-Xbinary=bundleId=com.krutsche.xcamp.shared")
                }
            }
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
            implementation(libs.firebase.config)

            // Multiplatform Settings
            implementation(libs.multiplatform.settings)

            // Image Loading
            implementation(libs.kamel.image)

            // Dependency Injection
            implementation(libs.koin.core)

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

// VS Code SourceKit-LSP support: Create version-independent symlink to framework
tasks.register("createVsCodeFrameworkSymlink") {
    group = "ide"
    description = "Create symlink for VS Code SourceKit-LSP (points to current framework version)"

    doLast {
        val frameworkBaseDir = layout.buildDirectory.dir("xcode-frameworks/Debug").get().asFile
        val linkDir = layout.buildDirectory.dir("xcode-frameworks").get().asFile

        // Skip if the directory doesn't exist (e.g., when building from command line)
        if (!frameworkBaseDir.exists()) {
            println("Skipping VS Code symlink creation: $frameworkBaseDir does not exist")
            return@doLast
        }

        // Find the simulator framework directory (e.g., iphonesimulator26.2)
        val simulatorDir = frameworkBaseDir.listFiles()?.firstOrNull {
            it.name.startsWith("iphonesimulator")
        }

        if (simulatorDir == null) {
            println("Skipping VS Code symlink creation: no simulator framework directory found in $frameworkBaseDir")
            return@doLast
        }

        // Create symlink using ln -sf (relative path from xcode-frameworks to Debug/iphonesimulator26.2)
        exec {
            commandLine("ln", "-sf", "Debug/${simulatorDir.name}", "${linkDir.absolutePath}/vscode-current")
        }

        println("Created VS Code framework symlink: vscode-current -> ${simulatorDir.name}")
    }
}

// Automatically run symlink task after simulator framework builds
tasks.named("linkDebugFrameworkIosSimulatorArm64") {
    finalizedBy("createVsCodeFrameworkSymlink")
}