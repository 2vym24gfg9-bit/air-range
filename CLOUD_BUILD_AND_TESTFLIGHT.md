# Aim Range — cloud build and TestFlight handoff

## Current project facts
- Native SwiftUI + SceneKit Xcode project; no framework migration.
- Deployment target: iOS 17.0.
- Device families: iPhone and iPad.
- Current bundle ID is the placeholder `com.example.AimRange`; replace it with a unique ID you control before signing/distribution.
- This project has not been compiled or tested on physical devices in this environment.

## Step A — validate compilation without signing
1. Create/sign in to a GitHub account if needed.
2. Create a **private** repository and upload the contents of this `AimRange` folder (including `AimRange.xcodeproj`, `AimRange/`, and `codemagic.yaml`). Do not upload Apple passwords, API private keys, certificates, or provisioning profiles to GitHub.
3. Create a Codemagic account at https://codemagic.io/ and connect the repository. Authorize GitHub only through its official authorization screen.
4. Select the `ios-simulator-check` workflow from `codemagic.yaml` and start a build. This workflow builds for the simulator without Apple signing. Review the build log and fix any compile errors before proceeding.

## Step B — enroll in Apple Developer Program
1. On iPhone/iPad, install/open the official Apple Developer app.
2. Account tab → sign in → Enroll Now; use an Apple Account with two-factor authentication, complete identity verification, and accept the terms.
3. Membership is normally USD $99/year (local price may differ). Payment and identity verification must be completed by the account holder.
4. Wait until enrollment is active; a free Apple developer account does not provide TestFlight distribution.

Official details: https://developer.apple.com/programs/ and https://developer.apple.com/help/account/membership/program-enrollment/

## Step C — prepare signing and TestFlight
1. Choose a unique reverse-DNS bundle ID (example format: `com.yourdomain.aimrange`; do not use this example unless you control it).
2. In App Store Connect, create an app record with that exact bundle ID and the app name `Aim Range`.
3. In Codemagic, configure the Apple Developer Portal / App Store Connect integration using the supported secure authorization flow. The account holder must approve access. Do not share Apple Account passwords or 2FA codes with anyone.
4. Add a signed iOS workflow using Codemagic's iOS code-signing integration (`distribution_type: app_store`) and App Store Connect publishing (`submit_to_testflight: true`) after the bundle ID and app record are set. Use the current official Codemagic native iOS documentation for the exact workflow schema: https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/ .
5. Trigger the signed build and upload. In App Store Connect → TestFlight, wait for processing and complete any compliance questions. Add yourself as an internal tester; external testers may require Beta App Review.
6. Install Apple's TestFlight app on both iPhone and iPad and accept the invitation.

## What is not done yet
- No successful build has been verified.
- No unique bundle ID has been chosen.
- No Apple Developer Program membership, App Store Connect app record, signing authorization, signed IPA, or TestFlight upload is included.
- No physical-device QA has been performed. Verify landscape layout, touch aiming, gyroscope permission/sensitivity, target hit testing, and stability on both device types.
