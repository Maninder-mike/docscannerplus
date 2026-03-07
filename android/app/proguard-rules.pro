# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google ML Kit - Text Recognition
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# ML Kit Text Recognition - All scripts
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# ML Kit Document Scanner
-keep class com.google.mlkit.vision.documentscanner.** { *; }

# Suppress warnings for missing classes
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Play Core (for deferred components - not used but referenced by Flutter)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication


# Google APIs (Drive, Sign-In)
-keep class com.google.api.services.drive.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.auth.** { *; }
-keep class com.google.crypto.** { *; }
-keep class com.google.instrumentation.** { *; }
-keep class com.google.j2objc.** { *; }
-keep class com.google.protobuf.** { *; }
-keep class com.google.thirdparty.** { *; }

# Prevent obfuscation of generic types in Google APIs
-keepattributes Signature
-keepattributes *Annotation*
