allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// The Start.io plugin (startapp_sdk) declares compileSdk 34, but its AAR
// dependency com.startapp:inapp-sdk (5.4.0) requires compileSdk 36. Bump the
// compileSdk of every Android library subproject to satisfy that constraint.
fun Project.configureStartAppCompileSdk() {
    if (plugins.hasPlugin("com.android.library")) {
        extensions.configure<com.android.build.api.dsl.LibraryExtension>("android") {
            val sdk = compileSdk
            if (sdk != null && sdk < 36) {
                compileSdk = 36
            }
        }
    }
}

subprojects {
    if (state.executed) {
        configureStartAppCompileSdk()
    } else {
        afterEvaluate {
            configureStartAppCompileSdk()
        }
    }
}
