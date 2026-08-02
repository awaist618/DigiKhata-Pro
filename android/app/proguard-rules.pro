# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent shrinking of Supabase/Postgrest classes if needed
-keep class io.supabase.** { *; }

# Keep models to prevent issues with JSON serialization
-keep class com.example.khataplus.features.**.data.models.** { *; }
