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

## 2026-05-16 — Day 4

### Built
- Added shared_preferences package for local email storage
- Updated AuthService with save/retrieve/clear pending email methods
- Built AuthGate widget in main.dart - the auth routing layer that decides on startup whether to show LoginScreen, HomeScreen, or process a magic-link callback
- Built HomeScreen placeholder - shows "You're signed in!" with user's email and a Sign out button
- Built EmailPromptScreen - fallback when localStorage doesn't contain the email (e.g. user clicked link in different browser/window than they sent from)
- StreamBuilder listens to Firebase auth state - auto-routes between login and home

### Tested end-to-end (real flow works)
- Type email → tap Send sign-in link → email arrives in Gmail
- Click link in Gmail → opens localhost:5000 with Firebase auth URL
- App detects sign-in link, completes auth
- If localStorage missing email (cross-window/device case): shows email confirmation prompt
- Lands on HomeScreen with green checkmark and user email displayed
- Sign out works - returns to LoginScreen
- AuthGate correctly routes returning signed-in user to HomeScreen

### Learned
- localStorage on web is scoped per-origin, but Chrome windows can have isolated storage in some configurations
- Firebase's recommended pattern is to gracefully handle the missing-email case by re-prompting
- "Spam folder" issue persists - new Firebase project has no email sender reputation yet
- StreamBuilder + authStateChanges is the cleanest reactive pattern for auth-aware routing
- Flutter web dev server sometimes serves stale assets after sign-out + tab close; fix is a clean restart of `./run_web.sh`. This is a dev quirk, not a production issue.

### Cycle 1 status: COMPLETE
- Login screen UI: done
- Real Firebase auth: done
- Multi-window/device fallback: done
- HomeScreen placeholder: done

### Next session — Cycle 2 begins
- Design Firestore data model for postings (position_type, employment_type, discipline, etc.)
- Build home feed UI with hardcoded sample postings
- Connect feed to Firestore (read-only first)
- Implement filter chips (discipline, position level, employment type)

## 2026-05-18 — Day 5 (Cycle 2 begins)

### Built
- Designed Firestore data model for postings (21 fields total)
- Decided on flat discipline list over hierarchical categorization
- Created lib/utils/disciplines.dart — 52 disciplines covering Engineering, Sciences, Humanities, Commerce, Professional fields, plus "Other" fallback
- Created lib/utils/posting_constants.dart — enum maps for position_type, employment_type, source, status, poster_role
- Created lib/models/posting.dart — Posting class with fromFirestore() and toFirestore() factory methods
- Added cloud_firestore package to project
- Manually seeded 6 sample postings in Firestore covering full diversity:
  1. Asst Professor in CSE at IIIT Delhi (official, permanent)
  2. JRF in Computational Biology at IIT Bombay (official, project-based, 2 years)
  3. Visiting Faculty in English at Bennett (heard, part-time, 1 semester)
  4. Summer Internship at IIIT Hyderabad NLP lab (official, 8 weeks)
  5. Asst Professor in Chemistry at IISER Pune (official, permanent)
  6. Associate Professor in Management at Bennett (heard, permanent)

### Learned
- Denormalizing poster info (name, institute) on each posting trades data freshness for read efficiency — important for feed performance at scale
- Specialization field separate from description gives candidates a quick scannable signal beyond just discipline
- Manual data entry in Firebase Console is tedious but acceptable as a one-time seeding step before the post form exists
- Two orthogonal axes (position_type × employment_type) handle 50+ combinations with only 19 enum values total

### Decisions deferred
- Whether to add a hierarchical "category" field above discipline (waited until pilot data shows need)
- Whether specialization should be free-text or tag-based (going with free-text for v0)

### Next session
- Build PostingsService — Dart wrapper around Firestore reads
- Replace HomeScreen placeholder with real feed UI (cards, filter chips, segment toggle)
- Test that the 6 sample postings appear correctly in the feed
## Pre-launch TODOs (must do before public)
- Email verification on signup — required for the "verified institute member" trust model
- Migrate institute email enforcement from dev mode (.ac.in / .edu.in only)
- Tighten Firestore security rules (currently in test mode)
- Set up custom domain with SPF/DKIM for better email deliverability