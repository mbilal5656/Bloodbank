# Comprehensive NDK Fix
Write-Host "🔧 Comprehensive NDK Fix..." -ForegroundColor Green

# 1. Fix android/app/build.gradle.kts
$appBuildGradle = @"
android {
    namespace = "com.example.bloodbank"
    compileSdk = 30
    
    // Completely disable NDK and native code
    buildFeatures {
        buildConfig = true
    }
    
    // Disable all native code features
    packagingOptions {
        jniLibs {
            useLegacyPackaging = false
        }
        pickFirsts += "**/libc++_shared.so"
        pickFirsts += "**/libjsc.so"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.bloodbank"
        minSdk = 21
        targetSdk = 30
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
"@

Set-Content "android\app\build.gradle.kts" $appBuildGradle
Write-Host "✅ Updated android/app/build.gradle.kts" -ForegroundColor Green

# 2. Fix android/gradle.properties
$gradleProps = @"
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
android.defaults.buildfeatures.buildconfig=true
android.nonTransitiveRClass=false
android.nonFinalResIds=false
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.java.home=C\:\\Program Files\\Java\\jdk-21
android.javaCompile.suppressSourceTargetDeprecationWarning=true
android.buildFeatures.buildConfig=true
# Completely disable NDK and native code
android.bundle.enableUncompressedNativeLibs=false
android.enableR8.fullMode=false
"@

Set-Content "android\gradle.properties" $gradleProps
Write-Host "✅ Updated android/gradle.properties" -ForegroundColor Green

# 3. Clean everything
Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n🎯 NDK Fix Complete!" -ForegroundColor Green
Write-Host "Try running: flutter run" -ForegroundColor Cyan
Write-Host "Or use web: flutter run -d web-server" -ForegroundColor Cyan 