# Flutter Local Notifications plugin rules for Release builds
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# AndroidX Core & NotificationCompat
-keep class androidx.core.app.NotificationCompat** { *; }
-dontwarn androidx.core.app.NotificationCompat**

# Keep serialization annotations and Gson models used by flutter_local_notifications
# when serializing/deserializing scheduled alarms across device reboots and app restarts
-keepattributes *Annotation*,Signature,EnclosingMethod,InnerClasses
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class com.google.gson.** { *; }
