plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
}

android {
    namespace = "com.rmusic.download"
    compileSdk = 36

    defaultConfig {
        minSdk = 21
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_23
        targetCompatibility = JavaVersion.VERSION_23
    }
    kotlinOptions {
        jvmTarget = "23"
        freeCompilerArgs += "-Xcontext-receivers"
    }
}

dependencies {
    implementation(projects.core.data)
    implementation(projects.providers.common)
    
    implementation(libs.kotlin.coroutines)
    implementation(libs.kotlin.serialization.json)
    implementation(libs.ktor.client.core)
    implementation(libs.annotation)
    
    implementation(libs.workmanager.ktx)
    implementation(libs.room)
    ksp(libs.room.compiler)
    
    // For downloading files
    implementation(libs.ktor.client.okhttp)
    implementation(libs.okhttp)
}
