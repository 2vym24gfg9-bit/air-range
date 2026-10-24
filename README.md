# Aim Range — iPhone / iPad FPS Aim Trainer (v1 prototype)

A native SwiftUI + SceneKit shooting-range prototype with touch look, tap-to-fire, moving 3D targets, hit/miss feedback, score/accuracy, adjustable touch sensitivity, optional gyroscope aim, gyroscope sensitivity, and three difficulty levels.

## Build
1. On a Mac with Xcode 16 or newer, create an iOS App project named `AimRange` (SwiftUI, Swift) or add the included Swift files to an iOS App target.
2. Add `AimRangeApp.swift` and `ContentView.swift` to the target. Set `Info.plist` to the included plist (or copy `NSMotionUsageDescription` and supported orientations into the generated plist).
3. Set deployment target to iOS 17.0 or newer. No third-party dependencies.
4. In Signing & Capabilities, select your Apple Developer team and change bundle identifier from `com.example.AimRange` to a unique identifier you control.
5. Run on iPhone/iPad simulator, then test on a physical device (especially gyroscope).

## TestFlight release checklist
- Requires an active Apple Developer Program membership and App Store Connect access.
- Create the app record in App Store Connect using the same unique bundle ID.
- Configure signing team, certificates/profiles (Xcode automatic signing is recommended), app name, category, privacy details, age rating, screenshots, and export-compliance answers.
- Archive a device build in Xcode; validate and upload to App Store Connect.
- Wait for processing, complete TestFlight compliance fields, add internal testers or submit for Beta App Review for external testers, then invite testers through TestFlight.

## Prototype limitations
- This is a source-code starter, not a compiled `.ipa` and has not been built or device-tested in this environment.
- SceneKit is used for a lightweight 3D range; it is not a full competitive FPS engine. Touch drag uses incremental deltas; verify sensitivity and gesture behavior during device QA.
- App identifier is a placeholder. No Apple credentials, signing certificates, App Store Connect app record, or TestFlight upload are included.
