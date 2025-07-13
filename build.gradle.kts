import io.gitlab.arturbosch.detekt.Detekt

plugins {
    alias(libs.plugins.kotlin.jvm) apply false
    alias(libs.plugins.kotlin.serialization) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.kotlin.parcelize) apply false
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.android.lint) apply false
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.detekt)
}

val clean by tasks.registering(Delete::class) {
    delete(rootProject.layout.buildDirectory.asFile)
}

allprojects {
    group = "com.rmusic"
    version = "0.1.0"

    apply(plugin = "io.gitlab.arturbosch.detekt")

    detekt {
        buildUponDefaultConfig = true
        allRules = false
        config.setFrom("$rootDir/detekt.yml")
        ignoreFailures = true
    }

    tasks.withType<Detekt>().configureEach {
        jvmTarget = "22"
        reports {
            html.required = true
        }
    }
}
