# flutter_webrtc (used by livekit_client for live classes) reaches these
# classes over JNI; R8 would otherwise strip them in release builds.
-keep class org.webrtc.** { *; }
-keep class com.cloudwebrtc.webrtc.** { *; }
