import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import javax.inject.Inject
import org.gradle.api.tasks.TaskAction
import org.gradle.api.file.DirectoryProperty
import org.gradle.process.ExecOperations
import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Internal

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

            // SQLDelight
            implementation(libs.sqldelight.runtime)
            implementation(libs.sqldelight.coroutines)

            // Firebase GitLive SDK
            implementation(libs.firebase.app)
            implementation(libs.firebase.auth)
            implementation(libs.firebase.firestore)
            implementation(libs.firebase.storage)
            implementation(libs.firebase.config)
            implementation(libs.firebase.messaging)
        }

        androidMain.dependencies {
            implementation(libs.kotlinx.coroutines.android)
            implementation(libs.sqldelight.android.driver)
        }

        iosMain.dependencies {
            implementation(libs.sqldelight.native.driver)
        }
    }
}

android {
    namespace = "cz.krutsche.xcamp.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    ndkVersion = "26.1.10909125"
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
abstract class CreateVsCodeFrameworkSymlinkTask : DefaultTask() {
    @get:Inject
    abstract val execOperations: ExecOperations

    @get:Internal
    abstract val buildDir: DirectoryProperty

    @TaskAction
    fun createSymlink() {
        val frameworkBaseDir = buildDir.get().asFile.resolve("xcode-frameworks/Debug")
        val linkDir = buildDir.get().asFile.resolve("xcode-frameworks")

        if (!frameworkBaseDir.exists()) {
            println("Skipping VS Code symlink creation: $frameworkBaseDir does not exist")
            return
        }

        val simulatorDir = frameworkBaseDir.listFiles()?.firstOrNull {
            it.name.startsWith("iphonesimulator")
        }

        if (simulatorDir == null) {
            println("Skipping VS Code symlink creation: no simulator framework directory found in $frameworkBaseDir")
            return
        }

        execOperations.exec {
            commandLine("ln", "-sf", "Debug/${simulatorDir.name}", "${linkDir.absolutePath}/vscode-current")
        }

        println("Created VS Code framework symlink: vscode-current -> ${simulatorDir.name}")
    }
}

tasks.register<CreateVsCodeFrameworkSymlinkTask>("createVsCodeFrameworkSymlink") {
    group = "ide"
    description = "Create symlink for VS Code SourceKit-LSP (points to current framework version)"
    buildDir.set(layout.buildDirectory)
}

// Automatically run symlink task after simulator framework builds
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinNativeLink>().configureEach {
    if (name.startsWith("linkDebugFramework") && name.contains("ios")) {
        finalizedBy("createVsCodeFrameworkSymlink")
    }
}
