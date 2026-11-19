# The Rust library looks these up by name.
-keepclasseswithmembernames class com.myyt.tv.AdBlock {
    native <methods>;
}

# Voice search: the page calls these through the MyYtVoice bridge.
-keepclassmembers class com.myyt.tv.Voice {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
