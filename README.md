<p align="center"><img src="app/src/main/res/drawable-xxxhdpi/banner.png" width="480" alt="VancedYT-TV"></p>

# VancedYT-TV

An ad-free YouTube player for Android TV boxes, made for weak hardware. It opens YouTube's own TV
interface full screen, blocks the ads with Brave's ad-block engine, and adds voice search on the
remote's mic button.

Made for the Airtel Xstream Smart Box (Android TV 9, 32-bit ARM). It should run on any Android TV 8.0+
box with an `armeabi-v7a` CPU.

[![Build APK](../../actions/workflows/build.yml/badge.svg)](../../actions/workflows/build.yml)

> Not affiliated with YouTube, Google, Brave or the former YouTube Vanced project. "YouTube" is a
> trademark of Google LLC. This app shows YouTube's own website inside an Android WebView.

## Screenshots

<!-- SCREENSHOTS -->
_Screenshots from the TV will be added here._

## Features

| | |
|---|---|
| **Fast playback** | Videos start in about 2 seconds. The app identifies itself to YouTube as a smart TV that gets plain (non-DRM) video streams. |
| **No ads** | [adblock-rust](https://github.com/brave/adblock-rust), Brave's engine, runs natively with uBlock Origin's scriptlets, which strip ad slots out of the player before YouTube's code runs. Network ads and trackers are blocked with EasyList, EasyPrivacy, Peter Lowe's list and the uBlock Origin lists. |
| **Voice search** | Press the remote's mic button and say what you want to watch. Android's speech recognition turns it into a YouTube search. In every other app the mic button still opens Google Assistant. |
| **TV remote keys** | OK, Back (with YouTube's own "Exit?" screen), Channel ± to page through lists, and media keys. |
| **Small and light** | No Google Play Services needed, a single 32-bit native library, and the filter lists come pre-compiled, so start-up on a slow CPU takes about a second. |

## Install

1. Download the APK from the [latest release](../../releases/latest) (or from the newest green run under
   [Actions](../../actions/workflows/build.yml)).
2. Install it on the box with ADB over the network (Developer options → Network debugging):

   ```sh
   adb connect <box ip>
   adb install -r VancedYT-TV-<version>.apk
   adb shell pm grant com.myyt.tv android.permission.RECORD_AUDIO
   ```

   Without ADB, any "send files to TV" app plus a file manager works too. The app asks for the
   microphone the first time it opens.

3. **Turn on the mic button.** Android 9 sends the remote's mic key to Google Assistant before any app sees
   it. A small accessibility service, **"VancedYT-TV mic button"**, takes that key back, only while
   VancedYT-TV is on screen. It reads no screen content. Turn it on in
   *Settings → Device Preferences → Accessibility*, or over ADB:

   ```sh
   adb shell settings put secure enabled_accessibility_services com.myyt.tv/.MicKeyService
   adb shell settings put secure accessibility_enabled 1
   ```

   If another accessibility service is already listed, keep it: join both with a `:`.

> The package name is still `com.myyt.tv`, so an update over an older build keeps your YouTube sign-in.

### Voice search needs these system apps

On the Airtel box, the remote's mic needs `com.google.android.tv.remote.service`,
`com.google.android.speech.pumpkin`, `com.google.android.katniss` and `com.uei.uas.airtel`. Don't disable
them when cleaning up the box.

## Build

GitHub Actions builds every push ([workflow](.github/workflows/build.yml)): first the Rust engine with
`cargo-ndk`, then the APK. Tagging `v*` publishes a release.

To build locally you need JDK 17, Android SDK 34 with the NDK, Rust, and `cargo install cargo-ndk`:

```sh
rustup target add armv7-linux-androideabi
cd engine && cargo ndk -t armeabi-v7a --platform 26 -o ../app/src/main/jniLibs build --release --lib && cd ..
./gradlew assembleRelease
```

### Updating the filter lists

The lists are compiled on a computer into `app/src/main/assets/engine.dat`; the TV only loads the
finished file.

```sh
# scriptlet resources from uBlock Origin's scriptlets (engine/ubo) and Brave's resources.json
python -I engine/build_resources.py engine/ubo engine/resources.json app/src/main/assets/resources.json
# compile (an example list set; lists marked trusted: may use trusted scriptlets, as in Brave)
cd engine && cargo run --release --bin compile -- ../app/src/main/assets/engine.dat \
  ../app/src/main/assets/resources.json \
  trusted:../lists/ubo-filters.txt trusted:../lists/ubo-privacy.txt trusted:../lists/ubo-unbreak.txt \
  trusted:../lists/ubo-quick-fixes.txt trusted:../lists/brave-unbreak.txt trusted:../lists/brave-specific.txt \
  ../lists/easylist.txt ../lists/easyprivacy.txt ../lists/peterlowe.txt
```

Fresh lists can be downloaded from their projects (links below). `compile` loads the result back and checks
that a known ad URL is blocked.

## How it works

- `MainActivity`: a full-screen WebView on `youtube.com/tv` with a smart-TV user agent, remote key mapping and
  full-screen video.
- `AdBlock` + `engine/`: the JNI bridge to adblock-rust. Network requests are checked in
  `shouldInterceptRequest`, cosmetic rules are added as CSS, and the YouTube scriptlets run as a
  document-start script.
- `Voice`: Android `SpeechRecognizer`. The result opens `#/search?q=…` in YouTube's TV app. It also provides
  the Web Speech API inside the page.
- `MicKeyService`: takes the remote's mic key (`KEYCODE_ASSIST`) while the app is in front.

## Licence and credits

GPL-3.0 (see [LICENSE](LICENSE)), because the app ships uBlock Origin's scriptlets.

- [uBlock Origin](https://github.com/gorhill/uBlock) scriptlets and filter lists, © Raymond Hill and
  contributors, GPL-3.0 (`engine/ubo`, `lists/ubo-*`)
- [adblock-rust](https://github.com/brave/adblock-rust) and Brave's lists and resources, © Brave Software, MPL-2.0
- [EasyList / EasyPrivacy](https://easylist.to), GPL-3.0 / CC BY-SA 3.0
- [Peter Lowe's list](https://pgl.yoyo.org/adservers/)
- Icon and banner are original artwork made for this project.
