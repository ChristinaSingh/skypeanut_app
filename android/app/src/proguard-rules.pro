# ──────────────────────────────────────────────────────
# Flutter specific ProGuard rules
# ──────────────────────────────────────────────────────
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings

# ──────────────────────────────────────────────────────
# Stripe SDK rules (especially Push Provisioning module)
# ──────────────────────────────────────────────────────

# Keep all classes in Stripe pushProvisioning
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# React Native Stripe SDK (if applicable in native module)
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }
-dontwarn com.reactnativestripesdk.pushprovisioning.**

# ──────────────────────────────────────────────────────
# Optional: Logging and Kotlin metadata (safe to keep)
# ──────────────────────────────────────────────────────
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# ──────────────────────────────────────────────────────
# R8 troubleshooting support (optional)
# ──────────────────────────────────────────────────────
#-printmapping build/outputs/mapping/release/mapping.txt
#-printusage build/outputs/mapping/release/usage.txt
