# Squad - Group Hangout Planner

A Flutter + Firebase mobile app for planning group hangoups, managing polls, and splitting bills.

## Project Overview

Squad is an MVP (Minimum Viable Product) application built according to the PRD specifications found in `squad_prd.md`. The app is designed for Indian college students and friend groups who need a dedicated tool for coordinating group outings.

### Key Features

- **Phone OTP Authentication** - Firebase Auth with phone number verification
- **Plan Creation** - Create group plans with multiple date options
- **Availability Polling** - Members vote on preferred dates
- **Bill Splitting** - Automatic equal split with UPI payment deep links
- **Push Notifications** - Real-time updates on plan changes
- **Pro Membership** - Unlock premium features (?299 one-time)
- **Squad Pack** - Gift Pro to 5 friends (?799 one-time)

## Architecture

### Tech Stack

- **Frontend**: Flutter 3.35.7 with Material 3
- **State Management**: Riverpod 2.x
- **Navigation**: GoRouter 13.x
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Code Generation**: Freezed, JSON Serializable, Build Runner
- **UI/Design**: Custom theme with Sora, DM Sans, JetBrains Mono fonts

### Folder Structure

```
squad/
+-- lib/
¦   +-- main.dart                    # App entry point
¦   +-- firebase_options.dart        # Firebase configuration
¦   +-- app/
¦   ¦   +-- app.dart                # Root MaterialApp widget
¦   ¦   +-- router.dart             # GoRouter config with all routes
¦   +-- core/
¦   ¦   +-- models/                 # Freezed data models
¦   ¦   +-- services/               # Firebase service classes
¦   ¦   +-- theme/                  # Theme & colors
¦   ¦   +-- utils/                  # Helpers (UPI, validators, dates)
¦   +-- features/
¦       +-- auth/                   # Authentication (phone OTP)
¦       +-- home/                   # Home feed with plan list
¦       +-- plan/                   # Plan creation and details
¦       +-- poll/                   # Date voting
¦       +-- expenses/               # Bill splitting
¦       +-- profile/                # User profile and upgrades
¦       +-- invite/                 # Invite link handling (web fallback)
+-- pubspec.yaml                    # Flutter dependencies
```

### State Management Pattern (Riverpod)

All screens use Riverpod for state management:
- **StateNotifier + StateNotifierProvider** for mutable state (loading, errors)
- **StreamProvider** for real-time Firestore data
- **FamilyProvider** for parameterized providers (e.g., plan by ID)

Example:
```dart
final updatePlanProvider = StateNotifierProvider<UpdatePlanNotifier, UpdatePlanState>(...);
final planDetailProvider = StreamProvider.family<PlanModel?, String>(...);
```

## Core Models

All models use Freezed for immutability and code generation:

- **UserModel** - User account with Pro status
- **PlanModel** - Group plan with status (draft/polling/confirmed/completed)
- **PollOptionModel** - Date option with vote count
- **ExpenseModel** - Bill split among members

## Firebase Services

### Authentication Service
- Phone OTP verification
- Firebase Auth integration
- Sign out capability

### Firestore Service
- CRUD operations for plans, users, expenses, polls
- Real-time streams for live updates
- Security rules (users read own docs, members read plans)

### Notification Service
- Firebase Cloud Messaging (FCM)
- Topic subscriptions
- Local push notification handling

## Key Routes

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | HomeScreen | Main feed with user's plans |
| `/auth/phone` | PhoneAuthScreen | Phone number entry |
| `/auth/otp` | OtpAuthScreen | 6-digit OTP verification |
| `/plan/create` | CreatePlanScreen | New plan creation |
| `/plan/:id` | PlanDetailScreen | Full plan view |
| `/plan/:id/poll` | PollScreen | Date voting |
| `/plan/:id/expense/add` | AddExpenseScreen | Add expense |
| `/plan/:id/expense/:eid` | ExpenseDetailScreen | Bill split details |
| `/profile` | ProfileScreen | User profile |
| `/upgrade` | UpgradeScreen | Pro membership |

## Setup & Build

### Prerequisites
- Flutter 3.35.7 (install via https://flutter.dev)
- Firebase project (create at firebase.google.com)
- Android SDK / Xcode for native builds

### Installation

1. **Clone and navigate to the project:**
   ```bash
   cd c:\Users\udayk\Desktop\square_manager\squad
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (freezed models, JSON serialization):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase:**
   - Update `lib/firebase_options.dart` with your Firebase project credentials
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place in respective platform-specific directories

5. **Run the app:**
   ```bash
   flutter run                    # Run on connected device
   flutter run -d chrome          # Run on web
   flutter build apk              # Build Android APK
   flutter build ios              # Build iOS app
   ```

## File-by-File Walkthrough

### Core Files

- **main.dart** - Initializes Firebase, wraps app in ProviderScope
- **firebase_options.dart** - Platform-specific Firebase configuration
- **app/app.dart** - Root MaterialApp with theme and router
- **app/router.dart** - GoRouter with 11 routes + deep link handling

### Theme

- **core/theme/app_colors.dart** - 10 semantic colors (brand, text, semantic)
- **core/theme/app_text_styles.dart** - Google Fonts typography (Sora, DM Sans, JetBrains Mono)
- **core/theme/app_theme.dart** - Material 3 ThemeData with custom components

### Models (Auto-Generated)

- **core/models/user_model.dart** ? user_model.freezed.dart, user_model.g.dart
- **core/models/plan_model.dart** ? auto-generated freezed + JSON files
- **core/models/expense_model.dart** ? auto-generated files
- **core/models/poll_option_model.dart** ? auto-generated files

### Services

- **core/services/auth_service.dart** - Firebase Auth wrapper (phone OTP)
- **core/services/firestore_service.dart** - Firestore CRUD operations
- **core/services/notification_service.dart** - Firebase Cloud Messaging handler

### Utilities

- **core/utils/upi_utils.dart** - Build UPI payment deep links
- **core/utils/validators.dart** - Form field validation (phone, OTP, amounts)
- **core/utils/date_helpers.dart** - Date formatting and manipulation

## Implementation Status

### ? Completed

- Project structure and dependency setup
- All core models with Freezed code generation
- Theme system with Material 3
- Firebase service classes
- Screen UI layouts (all 9 major screens)
- Router configuration with 11 routes
- Riverpod state management setup
- Build runner code generation (6 outputs generated)

### ?? In Progress / TODO

- Wire up actual Firebase authentication to screens
- Implement data binding in ListViews (plans, expenses)
- Upload image handling for avatars
- In-app purchase integration for Pro upgrades
- Cloud Functions for server-side logic (expense calculations, notifications)
- Web fallback page (Firebase Hosting)
- Deep link handling via Firebase Dynamic Links
- Android/iOS specific configuration
- App signing and Play Store/App Store submission

## Known Issues & Workarounds

1. **Firebase Options** - Placeholder values in firebase_options.dart; need real credentials
2. **Cloud Functions** - Not yet deployed; bill calculations currently client-side only
3. **Web Fallback** - HTML file for non-app users not yet created
4. **In-App Purchase** - Package added but not integrated into upgrade screens

## Testing Checklist

- [ ] Phone authentication flow (phone entry ? OTP ? home)
- [ ] Plan creation with multiple date options
- [ ] Voting on dates as invitee
- [ ] Plan confirmation as organizer
- [ ] Adding expenses and splitting bills
- [ ] UPI deep links open default payment app
- [ ] Push notifications triggered on plan updates
- [ ] Pro upgrade purchase flow
- [ ] Dark theme renders correctly
- [ ] Navigation between all screens works

## Performance Optimization Notes

- Firestore queries use `.orderBy()` with limits to reduce document reads
- Images cached via `cached_network_image` package
- Riverpod providers auto-dispose unused streams
- Freezed models provide value equality for efficient rebuilds

## Security Considerations

- Firebase Auth via phone OTP (no password complexity)
- Firestore security rules: users read own docs, members read plans
- Sensitive data (UPI IDs, payment amounts) handled via HTTPS only
- No credentials or API keys stored in code (use Firebase Options)

## Next Steps for Production

1. **Backend**
   - Deploy Cloud Functions for expense calculations
   - Setup Cloud Messaging notification triggers
   - Implement Dynamic Links for invite sharing

2. **Frontend**
   - Complete all provider ? screen data bindings
   - Add error handling and loading states
   - Implement image uploads to Firebase Storage
   - Battery and network optimization

3. **Launch**
   - Complete Firebase project setup
   - TestFlight / Play internal testing
   - App Store / Play Store submission
   - Analytics integration (Firebase Analytics)

## Support & Documentation

- **PRD** - See `squad_prd.md` for full product requirements and design specs
- **Flutter Docs** - https://flutter.dev/docs
- **Firebase Docs** - https://firebase.google.com/docs
- **Riverpod Docs** - https://riverpod.dev

---

**Last Updated:** March 2026  
**Flutter Version:** 3.35.7  
**Status:** MVP Phase 1 Complete - Ready for Integration Testing
