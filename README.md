# TAP2TALK Flutter Starter

This is an initial starter project, not a production-ready application/APK.

## Included
- Firebase initialization
- Anonymous Firebase sign-in
- Animated circular logo splash-like request screen
- WhatsApp-number membership approval request submission
- Premium black/red/yellow UI scaffold
- Firebase config file (if the uploaded file was present)

## Android setup
1. Install Flutter SDK and Android SDK.
2. Register Android app with package `com.dpz.tap2talk` in Firebase.
3. Place `google-services.json` at `android/app/google-services.json`.
4. Run `flutter create --platforms=android --org com.dpz --project-name tap2talk .`
5. Move JSON into `android/app/` if needed.
6. Add Google Services Gradle plugin per FlutterFire/Firebase Android instructions.
7. Run `flutter pub get` then `flutter run`.

## Important security
Firestore rules are deny-all starter rules. Do not loosen to public access.
Before production, define two admin UIDs and implement server-enforced admin/member status checks.
Anonymous login does not verify the WhatsApp number. Admin approval is only a workflow, not proof of number ownership.
WhatsApp auto-messaging and OTP are not included; personal WhatsApp payment contact is a manual external flow.
