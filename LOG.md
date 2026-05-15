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

## 2026-05-14 — Day 2

### Built
- Connected Flutter project to Firebase via FlutterFire CLI
- Added firebase_core and firebase_auth packages
- Firebase initialized in main.dart on app startup
- Confirmed app still launches cleanly with Firebase init in place

### Infrastructure  
- Installed Firebase CLI (v13.23.1) and FlutterFire CLI (v1.3.2)
- Ran `flutterfire configure` — selected web platform, FacultyHub Dev project
- Generated lib/firebase_options.dart (gitignored for safety until Firestore rules are tightened)
- Added firebase_options.dart, firebase.json, .firebaserc to .gitignore

### Learned
- FlutterFire CLI sits on top of Firebase CLI; both are needed
- The firebase_options.dart file is auto-generated and can be regenerated anytime
- Firebase must be initialized in main() before runApp(), with WidgetsFlutterBinding.ensureInitialized() first
- Web app registration from yesterday was reused — Firebase didn't create a duplicate

### Not yet done
- Send OTP button still uses simulated 1-second delay
- No actual auth flow tested end-to-end

### Next session
- Wire the Send OTP button to Firebase sendSignInLinkToEmail()
- Configure Action URL settings in Firebase Console for email link auth
- Build a "check your email" intermediate screen
- Test end-to-end: type email, receive magic link, click it, log in

## 2026-05-15 — Day 3

### Built
- Created AuthService wrapper class for Firebase Auth operations
- Wired Send sign-in link button to real Firebase sendSignInLinkToEmail() call
- Added Firebase-specific error handling with humanized error messages
- Set up fixed dev port (localhost:5000) via run_web.sh script

### Tested
- Sent real magic-link email to pravinkum10@gmail.com via Firebase Auth
- Email arrived in Gmail inbox within 1 minute (not Spam)
- Subject: "Sign in to facultyhub-dev requested at..."
- Sender: noreply@facultyhub-dev.firebaseapp.com
- Link visible and properly formatted (NOT YET CLICKED - awaiting callback handler)

### Learned
- Firebase Auth sendSignInLinkToEmail works out of the box once authorized domains include localhost
- Flutter's random web port is a real problem for auth — fixed via --web-port=5000
- Magic links are single-use; testing must wait until callback handler is built
- Email-link auth requires both handleCodeInApp=true and a valid ActionCodeSettings

### Next session
- Build CheckEmailScreen — intermediate screen shown after sending the link
- Detect incoming magic link when user clicks it and Chrome redirects to localhost:5000
- Call signInWithEmailLink() to complete authentication
- Build basic HomeScreen placeholder for "you're logged in" state
- Test end-to-end: click link → see HomeScreen → confirm currentUser is set

### Known issues to address before pilot
- Firebase auth emails currently land in Gmail Spam (new sender, no reputation)
- Need to add Spam folder hint on CheckEmailScreen
- Long-term: set up custom domain with SPF/DKIM for production