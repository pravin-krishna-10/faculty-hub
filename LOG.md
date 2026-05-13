# FacultyHub Build Log

## 2026-05-13 — Day 1

### Built
- Flutter project initialised as faculty_hub
- Login screen UI matching mockup (logo, title, tagline, email field, Send OTP button, footer)
- Input validation with regex
- Dev mode toggle (currently ON — accepts any valid email; will switch OFF for pilot)
- Loading spinner and error states on Send OTP button
- Theme file (lib/utils/theme.dart) with all mockup colors

### Infrastructure
- Pushed initial commit to GitHub (private repo: pravin-krishna-10/faculty-hub)
- Created Firebase project "FacultyHub Dev" on Spark plan
- Enabled Email/Password + Email link (passwordless sign-in)
- Firestore database created in test mode
- Registered Web app, config saved to ~/Documents/Flutter/firebase-config-dev.txt

### Learned
- Flutter runs in Chrome for fast dev iteration; Android setup deferred
- Firebase web config can be shared publicly once Firestore rules are tight, but for now I'll keep it out of git
- Hot reload (r) and full restart (R) work cleanly in Chrome

### Next session
- Install FlutterFire CLI
- Run `flutterfire configure` to auto-wire Firebase to Flutter
- Connect Send OTP button to real Firebase Auth (email link / magic link flow)
- Build a basic "check your email" confirmation screen