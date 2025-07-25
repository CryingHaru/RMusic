plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "com.rmusic.compose.persist"
    compileSdk = 36

    defaultConfig {
        minSdk = 24
    }

    sourceSets.all {
        kotlin.srcDir("src/$name/kotlin")
    }
}

kotlin {
    jvmToolchain(libs.versions.jvm.get().toInt())
}

dependencies {
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.foundation)

    implementation(libs.kotlin.immutable)

    detektPlugins(libs.detekt.compose)
    detektPlugins(libs.detekt.formatting)
}
