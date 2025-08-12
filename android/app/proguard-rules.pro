# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Fix for emulator 5544 errors
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Fix for notification permissions
-keep class androidx.work.** { *; }
-keep class com.google.firebase.** { *; }

# Fix for database operations
-keep class com.example.bloodbank.** { *; }
-keep class * extends androidx.sqlite.db.SupportSQLiteOpenHelper { *; }

# Fix for shared preferences
-keep class androidx.preference.** { *; }

# Fix for material design
-keep class com.google.android.material.** { *; }

# Fix for AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Fix for Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Fix for emulator compatibility
-dontwarn android.arch.**
-dontwarn android.lifecycle.**
-dontwarn android.support.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Fix for reflection
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes Exceptions

# Fix for native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Fix for enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Fix for Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Fix for Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Fix for R classes
-keep class **.R$* {
    public static <fields>;
}

# Fix for emulator 5544 errors - keep all classes
-keep class * { *; }
