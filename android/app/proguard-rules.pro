# Flutter specific rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.android.** { *; }

# ML Kit Vision & Play Core rules
# Keep the classes that are actually used.
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.android.odml.image.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_common.** { *; }
-keep class com.google.android.play.core.** { *; }

# Suppress warnings about missing optional dependency classes.
-dontwarn com.google.mlkit.vision.**
-dontwarn com.google.android.play.core.**
