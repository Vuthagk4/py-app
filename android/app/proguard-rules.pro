# Ignore missing j2objc and Guava classes
-dontwarn com.google.j2objc.annotations.**
-keep class com.google.j2objc.annotations.** { *; }
-dontwarn com.google.common.**
-keep class com.py.e6.data.models.** { *; }
-keep class com.google.android.gms.maps.** { *; }
-keep class com.google.maps.android.** { *; }
-dontwarn com.google.android.gms.**