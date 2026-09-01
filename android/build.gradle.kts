import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// ffmpeg_kit_flutter_min 4.5.1 predates AGP 8's required namespace property.
// Keep the dependency and its public Dart/Android API intact, but provide the
// namespace from the package's existing Java package in a repository-controlled
// place. This is limited to that dependency and survives clean CI checkouts.
subprojects {
    plugins.withId("com.android.library") {
        if (project.name == "ffmpeg_kit_flutter_min") {
            project.extensions.configure<LibraryExtension> {
                namespace = "com.arthenica.ffmpegkit.flutter"
            }
            project.configurations.configureEach {
                resolutionStrategy.dependencySubstitution {
                    substitute(module("com.arthenica:ffmpeg-kit-min:4.5.1-1"))
                        .using(module("dev.ffmpegkit-maintained:ffmpeg-kit-min:8.1.7"))
                        .because("The retired upstream FFmpegKit Maven artifact is no longer available")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
