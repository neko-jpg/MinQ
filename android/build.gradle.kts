import com.android.build.gradle.LibraryExtension
import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val externalBuildDir = System.getenv("MINQ_ANDROID_BUILD_DIR")?.takeIf { it.isNotBlank() }?.let(::File)
val defaultBuildBase = File("C:/minq_android_build")
val resolvedBuildRoot = (externalBuildDir ?: defaultBuildBase.resolve(rootProject.name)).canonicalFile
resolvedBuildRoot.mkdirs()

rootProject.layout.buildDirectory.set(resolvedBuildRoot)

subprojects {
    val subprojectDir = resolvedBuildRoot.resolve(name)
    layout.buildDirectory.set(subprojectDir)

    plugins.withId("com.android.library") {
        extensions.configure(LibraryExtension::class.java) {
            if (name == "isar_flutter_libs") {
                namespace = "dev.isar.isar_flutter_libs"
                compileSdk = 34
                defaultConfig {
                    minSdk = maxOf(minSdk ?: 16, 21)
                }
            }
        }
    }

    plugins.withId("com.android.application") {
        if (name == "app") {
            afterEvaluate {
                tasks.named("packageDebug").configure {
                    doLast {
                        val outputsDir = layout.buildDirectory.dir("outputs").get().asFile
                        val targetDir = rootProject.projectDir.parentFile.resolve("build/app/outputs")
                        if (targetDir.exists()) {
                            targetDir.deleteRecursively()
                        }
                        targetDir.mkdirs()
                        project.copy {
                            from(outputsDir)
                            into(targetDir)
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(resolvedBuildRoot)
}

