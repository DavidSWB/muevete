# Release builds are shrunk by R8 in full mode. The Flutter Gradle plugin adds
# this file to the release configuration automatically when it exists.

## Gson rules for flutter_local_notifications
# The plugin persists scheduled notifications with Gson and reads them back
# with `new TypeToken<ArrayList<NotificationDetails>>() {}`. Without these
# rules R8 strips the generic signature and every cancel/schedule call fails
# with "Missing type parameter". Source:
# https://github.com/google/gson/blob/main/examples/android-proguard-example/proguard.cfg
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken and its subclasses (R8 3.0+).
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Gson serializes the plugin's models by field name. Keep those names stable
# so reminders saved by one release can still be read (for example by the
# boot receiver) after the app is updated.
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
