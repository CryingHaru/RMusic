import org.jetbrains.kotlin.compose.compiler.gradle.ComposeFeatureFlag
import org.jetbrains.kotlin.gradle.dsl.KotlinVersion

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.parcelize)
    alias(libs.plugins.ksp)
}

android {
    val appId = "${project.group}.android"

    namespace = appId
    compileSdk = 36

    defaultConfig {
        applicationId = appId

        minSdk = 24
        targetSdk = 36

        versionCode = System.getenv("ANDROID_VERSION_CODE")?.toIntOrNull() ?: 16
        versionName = project.version.toString()

        multiDexEnabled = true
    }

    splits {
        abi {
            reset()
            isUniversalApk = true
        }
    }

    signingConfigs {
        // Carga opcional de variables desde un fichero local no versionado (signing.env)
        val signingProps = java.util.Properties().apply {
            val f = rootProject.file("signing.env")
            if (f.exists()) f.inputStream().use { load(it) }
        }

        fun propOrEnv(name: String): String? =
            (signingProps.getProperty(name) ?: System.getenv(name))?.takeIf { it.isNotBlank() }

        val isReleaseTask = gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }

        create("release") {
            val keystorePath = propOrEnv("RMUSIC_KEYSTORE_PATH") ?: "rmusic-release-key.keystore"
            val releaseKeystoreFile = rootProject.file(keystorePath)

            // No establecer por defecto valores sensibles; leer de env/props y solo exigirlos en builds release
            storeFile = releaseKeystoreFile.takeIf { it.exists() }
            storePassword = propOrEnv("RMUSIC_KEYSTORE_PASSWORD")
            keyAlias = propOrEnv("RMUSIC_KEY_ALIAS")
            keyPassword = propOrEnv("RMUSIC_KEY_PASSWORD")

            if (isReleaseTask) {
                if (storeFile == null || storePassword.isNullOrBlank() || keyAlias.isNullOrBlank() || keyPassword.isNullOrBlank()) {
                    throw GradleException("Faltan credenciales de firma para 'release'. Crea 'signing.env' a partir de 'signing.env.example' o exporta variables de entorno.")
                }
            }
        }

        create("ci") {
            storeFile = System.getenv("ANDROID_NIGHTLY_KEYSTORE")?.let { file(it) }
            storePassword = System.getenv("ANDROID_NIGHTLY_KEYSTORE_PASSWORD")
            keyAlias = System.getenv("ANDROID_NIGHTLY_KEYSTORE_ALIAS")
            keyPassword = System.getenv("ANDROID_NIGHTLY_KEYSTORE_PASSWORD")
        }
    }

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
            manifestPlaceholders["appName"] = "RMusic Debug"
        }

        release {
            versionNameSuffix = "-RELEASE"
            isMinifyEnabled = true
            isShrinkResources = true
            manifestPlaceholders["appName"] = "Rmusic"
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        create("nightly") {
            initWith(getByName("release"))
            matchingFallbacks += "release"

            applicationIdSuffix = ".nightly"
            versionNameSuffix = "-NIGHTLY"
            manifestPlaceholders["appName"] = "RMusic Nightly"
            signingConfig = signingConfigs.findByName("ci")
        }
    }

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }

    packaging {
        resources.excludes.add("META-INF/**/*")
    }

    androidResources {
        @Suppress("UnstableApiUsage")
        generateLocaleConfig = true
    }
}

kotlin {
    jvmToolchain(libs.versions.jvm.get().toInt())

    compilerOptions {
        languageVersion.set(KotlinVersion.KOTLIN_2_1)

        freeCompilerArgs.addAll(
            "-Xcontext-receivers",
            "-Xnon-local-break-continue",
            "-Xconsistent-data-class-copy-visibility"
        )
    }
}

ksp {
    arg("room.schemaLocation", "$projectDir/schemas")
}

composeCompiler {
    featureFlags = setOf(
        ComposeFeatureFlag.OptimizeNonSkippingGroups
    )

    if (project.findProperty("enableComposeCompilerReports") == "true") {
        val dest = layout.buildDirectory.dir("compose_metrics")
        metricsDestination = dest
        reportsDestination = dest
    }
}

dependencies {
    coreLibraryDesugaring(libs.desugaring)

    implementation(projects.compose.persist)
    implementation(projects.compose.preferences)
    implementation(projects.compose.routing)
    implementation(projects.compose.reordering)
    implementation(projects.download)

    implementation(fileTree(projectDir.resolve("vendor")))

    implementation(platform(libs.compose.bom))
    implementation(libs.compose.activity)
    implementation(libs.compose.foundation)
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.util)
    implementation(libs.compose.shimmer)
    implementation(libs.compose.lottie)
    implementation(libs.compose.material3)

    implementation(libs.coil.compose)
    implementation(libs.coil.ktor)

    implementation(libs.palette)
    implementation(libs.monet)
    runtimeOnly(projects.core.materialCompat)

    implementation(libs.exoplayer)
    implementation(libs.exoplayer.workmanager)
    implementation(libs.media3.session)
    implementation(libs.media)

    implementation(libs.workmanager)
    implementation(libs.workmanager.ktx)

    implementation(libs.credentials)
    implementation(libs.credentials.play)

    implementation(libs.kotlin.coroutines)
    implementation(libs.kotlin.immutable)
    implementation(libs.kotlin.datetime)

    implementation(libs.room)
    ksp(libs.room.compiler)

    implementation(libs.log4j)
    implementation(libs.slf4j)
    implementation(libs.logback)

    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.okhttp)

    implementation(projects.providers.github)
    implementation(projects.providers.innertube)
    implementation(projects.providers.kugou)
    implementation(projects.providers.lrclib)
    implementation(projects.providers.piped)
    implementation(projects.providers.sponsorblock)
    implementation(projects.providers.translate)
    implementation(projects.providers.ytmusic)
    implementation(projects.download)
    implementation(projects.core.data)
    implementation(projects.core.ui)
}
