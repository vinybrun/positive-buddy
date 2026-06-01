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

// home_widget 0.9.2 stops applying the Kotlin Gradle plugin on AGP 9+
// (expecting AGP's built-in Kotlin), but its `src/main/kotlin` layout isn't
// picked up that way, so the module compiles zero classes and the plugin is
// dead at both compile and runtime. Re-apply kotlin-android to just that
// module — the listener fires the moment it applies com.android.library,
// before its own `android {}` block is evaluated. Remove once the plugin
// ships an AGP-9-compatible release.
subprojects {
    if (name == "home_widget") {
        plugins.withId("com.android.library") {
            pluginManager.apply("org.jetbrains.kotlin.android")
            // The module pins Java to 1.8; match Kotlin to it so the JVM
            // targets stay consistent.
            extensions.configure<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension>(
                "kotlin",
            ) {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
