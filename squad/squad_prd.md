# Squad — Product Requirements Document
# Squad
## Group Hangout Planner

**MVP v1.0 · Flutter + Firebase · India-first**

---

## Table of contents

1. [Product overview](#1-product-overview)
2. [Goals & success metrics](#2-goals--success-metrics)
3. [User personas](#3-user-personas)
4. [MVP scope](#4-mvp-scope)
5. [Firebase architecture](#5-firebase-architecture)
6. [Flutter app architecture](#6-flutter-app-architecture)
7. [Screens & UX flows](#7-screens--ux-flows)
8. [Visual design & theme](#8-visual-design--theme)
9. [Monetisation](#9-monetisation)
10. [Push notification specs](#10-push-notification-specs)
11. [Web fallback](#11-web-fallback-firebase-hosting)
12. [MVP build timeline](#12-mvp-build-timeline)
13. [Risks & mitigations](#13-risks--mitigations)

---

## 1. Product overview

Squad is a mobile-first group hangout planning app for Indian friend circles. It takes a group from "kaha jaaye?" to a confirmed plan — with polls, itinerary building, and bill splitting — without leaving the app.

**The core insight:** WhatsApp handles communication but not planning. Groups of friends spend 2–3 days in chaotic message threads trying to align on a plan. Squad is the dedicated tool that closes that loop.

| Field | Value |
|---|---|
| Product name | Squad |
| Version | MVP v1.0 |
| Platform | Flutter (iOS + Android) + Firebase Web fallback |
| Target market | India-first (Tier 1 & 2 college students, 18–26) |
| Monetisation | Freemium + one-time Pro purchase (₹299) |
| Stack | Flutter 3.x, Firebase (Auth, Firestore, Storage, Functions, FCM) |

### 1.1 Problem statement

- Friend groups spend 2–3 days in WhatsApp threads trying to finalise a single outing
- No single tool covers availability polling + itinerary + cost splitting in one place
- Existing tools (Doodle, Splitwise, Google Trips) are foreign-built, subscription-heavy, and not social
- Indians don't click invite links — they forward screenshots — so the sharing mechanic must be WhatsApp-native

### 1.2 Vision

For every Indian friend group, Squad is the default answer to "let's plan something" — the app you open before WhatsApp, not after.

---

## 2. Goals & success metrics

| Metric | Target (3 months post-launch) |
|---|---|
| MAU | 10,000 active users |
| Plans created | 50,000 plans in 90 days |
| Invite link CTR | > 40% (WhatsApp share → app open) |
| Pro conversion | > 8% of MAU |
| D7 retention | > 35% |
| Squad pack purchases | > 20% of Pro revenue |

---

## 3. User personas

### 3.1 The Organiser (primary)

- Age 19–24, college student or early-career professional
- Always the one who "makes things happen" in the group
- Frustrated by chasing replies across WhatsApp threads
- Wants a tool that makes them look organised, not bossy

### 3.2 The Invitee (secondary)

- Receives the invite link via WhatsApp
- Has not installed Squad — must be able to vote and RSVP on web without app install
- Low friction is non-negotiable: one tap to open, one tap to respond

### 3.3 The Payer

- Someone in the group who paid upfront (Ola cab, restaurant bill, entry tickets)
- Wants a clean split with UPI deep links, not spreadsheets

---

## 4. MVP scope

### 4.1 In scope (ship on day 1)

| Feature | Description | Priority | Firebase service |
|---|---|---|---|
| Phone auth | OTP login via Firebase Auth (no email/password) | P0 | Firebase Auth |
| Create plan | Name, date/time, location, description | P0 | Firestore |
| Invite via link | Shareable WhatsApp-optimised link; web fallback for non-app users | P0 | Dynamic Links |
| Availability poll | Organiser sets 3–5 date options; invitees vote | P0 | Firestore |
| Confirm plan | Organiser locks in final date/venue; push notification to all | P0 | FCM |
| Bill split | Add expenses, auto-split equally; UPI deep link to pay | P0 | Firestore |
| Plan feed | List of active & past plans for the user | P1 | Firestore |
| Plan detail | Full view: itinerary, attendees, expenses, status | P1 | Firestore |
| Push notifications | Invite received, plan confirmed, someone paid | P1 | FCM |
| Memory feed | Post-plan photo dump with captions | P2 | Storage |

### 4.2 Out of scope for MVP

- In-app chat (WhatsApp already exists)
- Event discovery / recommendations
- Social feed / followers
- Location sharing / live tracking
- Recurring plans

---

## 5. Firebase architecture

### 5.1 Services used

| Service | Purpose |
|---|---|
| Firebase Auth | Phone OTP authentication for all users |
| Firestore | Primary database — plans, users, polls, expenses |
| Firebase Storage | Profile photos, memory feed images (v2) |
| Cloud Functions | Plan confirmation logic, notification triggers, UPI split calc |
| FCM | Push notifications for invites, confirmations, payments |
| Dynamic Links | Shareable plan invite links with web fallback |
| Firebase Hosting | Web fallback UI for invitees without the app |

### 5.2 Firestore data model

#### `users`

Collection path: `/users/{userId}`

| Field | Type / Notes |
|---|---|
| `uid` | `string` — Firebase Auth UID |
| `phone` | `string` — E.164 format |
| `displayName` | `string` |
| `avatarUrl` | `string \| null` |
| `isPro` | `bool` — unlocked via one-time purchase |
| `proUnlockedAt` | `timestamp \| null` |
| `createdAt` | `timestamp` |
| `fcmToken` | `string` — updated on each app open |

#### `plans`

Collection path: `/plans/{planId}`

| Field | Type / Notes |
|---|---|
| `planId` | `string` — auto ID |
| `title` | `string` |
| `description` | `string \| null` |
| `createdBy` | `string` — userId |
| `status` | `enum: draft \| polling \| confirmed \| completed` |
| `location` | `string \| null` |
| `confirmedDate` | `timestamp \| null` |
| `confirmedVenue` | `string \| null` |
| `inviteLink` | `string` — Dynamic Link URL |
| `memberIds` | `string[]` — array of userIds |
| `createdAt` | `timestamp` |
| `updatedAt` | `timestamp` |

#### `plans/{planId}/pollOptions`

Subcollection path: `/plans/{planId}/pollOptions/{optionId}`

| Field | Type / Notes |
|---|---|
| `optionId` | `string` |
| `dateTime` | `timestamp` |
| `voteCount` | `int` — denormalised for fast reads |
| `voterIds` | `string[]` |

#### `plans/{planId}/expenses`

Subcollection path: `/plans/{planId}/expenses/{expenseId}`

| Field | Type / Notes |
|---|---|
| `expenseId` | `string` |
| `title` | `string` — e.g. "Cab to Banjara Hills" |
| `amount` | `number` — in INR |
| `paidBy` | `string` — userId |
| `splitAmong` | `string[]` — userIds |
| `perPersonAmount` | `number` — computed in Cloud Function |
| `settledBy` | `string[]` — userIds who have paid back |
| `createdAt` | `timestamp` |

### 5.3 Firestore security rules (key rules)

```
// Users can only read/write their own user document
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Plans: read if member, write only for organiser
match /plans/{planId} {
  allow read: if request.auth.uid in resource.data.memberIds;
  allow create: if request.auth.uid == request.resource.data.createdBy;
  allow update: if request.auth.uid == resource.data.createdBy;

  // Poll options: any member can vote, only organiser can delete
  match /pollOptions/{optionId} {
    allow read: if request.auth.uid in get(/databases/$(database)/documents/plans/$(planId)).data.memberIds;
    allow create, update: if request.auth.uid in get(/databases/$(database)/documents/plans/$(planId)).data.memberIds;
    allow delete: if request.auth.uid == get(/databases/$(database)/documents/plans/$(planId)).data.createdBy;
  }

  // Expenses: any member can create, only creator can edit/delete
  match /expenses/{expenseId} {
    allow read: if request.auth.uid in get(/databases/$(database)/documents/plans/$(planId)).data.memberIds;
    allow create: if request.auth.uid in get(/databases/$(database)/documents/plans/$(planId)).data.memberIds;
    allow update, delete: if request.auth.uid == resource.data.paidBy;
  }
}
```

---

## 6. Flutter app architecture

### 6.1 Package dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialisation |
| `firebase_auth` | Phone OTP auth |
| `cloud_firestore` | Firestore reads/writes |
| `firebase_storage` | Image upload (memory feed, avatars) |
| `firebase_messaging` | FCM push notifications |
| `firebase_dynamic_links` | Handle incoming invite links |
| `flutter_riverpod` | State management |
| `go_router` | Navigation + deep link routing |
| `get_it` | Service locator / DI |
| `dio` | HTTP client (for Cloud Functions calls) |
| `freezed` | Immutable models |
| `json_serializable` | JSON serialisation |
| `build_runner` | Code generation |
| `share_plus` | Native share sheet for invite links |
| `url_launcher` | UPI deep links |
| `cached_network_image` | Efficient image loading |
| `intl` | Date formatting, INR currency |
| `google_fonts` | Sora, DM Sans, JetBrains Mono |
| `in_app_purchase` | One-time Pro purchase |
| `confetti` | Confetti animation on plan confirm |

### 6.2 Folder structure

```
lib/
├── main.dart                    # App entry, Firebase.initializeApp, ProviderScope
├── app/
│   ├── app.dart                 # Root widget
│   ├── router.dart              # go_router config + deep link handlers
│   └── theme.dart               # AppTheme
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── phone_screen.dart
│   │   │   └── otp_screen.dart
│   │   └── providers/
│   │       └── auth_provider.dart
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── providers/
│   │       └── plans_provider.dart
│   ├── plan/
│   │   ├── screens/
│   │   │   ├── create_plan_screen.dart
│   │   │   ├── plan_detail_screen.dart
│   │   │   └── confirm_plan_screen.dart
│   │   └── providers/
│   │       └── plan_provider.dart
│   ├── poll/
│   │   ├── screens/
│   │   │   └── poll_screen.dart
│   │   └── providers/
│   │       └── poll_provider.dart
│   ├── expenses/
│   │   ├── screens/
│   │   │   ├── add_expense_screen.dart
│   │   │   └── expense_detail_screen.dart
│   │   └── providers/
│   │       └── expense_provider.dart
│   ├── invite/
│   │   └── invite_service.dart
│   └── profile/
│       ├── screens/
│       │   ├── profile_screen.dart
│       │   └── upgrade_screen.dart
│       └── providers/
│           └── profile_provider.dart
└── core/
    ├── services/
    │   ├── firestore_service.dart
    │   ├── auth_service.dart
    │   └── notification_service.dart
    ├── models/
    │   ├── user_model.dart          # freezed
    │   ├── plan_model.dart          # freezed
    │   ├── poll_option_model.dart   # freezed
    │   └── expense_model.dart       # freezed
    ├── theme/
    │   ├── app_colors.dart
    │   ├── app_text_styles.dart
    │   └── app_theme.dart
    └── utils/
        ├── upi_utils.dart
        ├── date_helpers.dart
        └── validators.dart
```

### 6.3 State management pattern (Riverpod)

- Each feature has its own `providers/` file
- Use `AsyncNotifierProvider` for all async data (plans list, plan detail)
- Use `StateNotifierProvider` for local UI state (form fields, loading states)
- Auth state: `StreamProvider` wrapping `FirebaseAuth.authStateChanges()`
- Never access Firestore directly from widgets — always go through a provider

### 6.4 Key model — `PlanModel` (freezed)

```dart
@freezed
class PlanModel with _$PlanModel {
  const factory PlanModel({
    required String planId,
    required String title,
    String? description,
    required String createdBy,
    required PlanStatus status,
    String? location,
    DateTime? confirmedDate,
    String? confirmedVenue,
    required String inviteLink,
    required List<String> memberIds,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PlanModel;

  factory PlanModel.fromJson(Map<String, dynamic> json) =>
      _$PlanModelFromJson(json);
}

enum PlanStatus { draft, polling, confirmed, completed }
```

### 6.5 Key model — `ExpenseModel` (freezed)

```dart
@freezed
class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String expenseId,
    required String title,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required double perPersonAmount,
    required List<String> settledBy,
    required DateTime createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);
}
```

---

## 7. Screens & UX flows

### 7.1 Screen inventory

| Screen | Route | Description |
|---|---|---|
| Splash | `/` | Logo, Firebase init, redirect to auth or home |
| Phone entry | `/auth/phone` | Enter mobile number, request OTP |
| OTP verify | `/auth/otp` | 6-digit OTP input, auto-submit on fill |
| Home feed | `/home` | List of active plans, FAB to create |
| Create plan | `/plan/create` | Title, date options, location, invite |
| Plan detail | `/plan/:id` | Full plan: poll, attendees, itinerary, expenses |
| Vote / poll | `/plan/:id/poll` | Date options with live vote counts |
| Confirm plan | `/plan/:id/confirm` | Organiser locks date + venue |
| Add expense | `/plan/:id/expense/add` | Title, amount, paid by, split among |
| Expense detail | `/plan/:id/expense/:eid` | Who owes whom, UPI links |
| Invite web view | Firebase Hosting | Web page for non-app invitees to RSVP |
| Profile | `/profile` | Name, avatar, Pro badge, upgrade CTA |
| Pro upgrade | `/upgrade` | One-time ₹299 purchase, Squad Pack ₹799 |

### 7.2 Key user flows

#### Flow A — Create & invite (organiser)

1. Open app → Home feed
2. FAB (+) → Create Plan screen
3. Enter title, add 3 date options, optional location
4. Tap "Generate invite link" → Firebase Dynamic Link created
5. Native share sheet opens with pre-filled WhatsApp message
6. Redirect to Plan Detail (status: `polling`)

#### Flow B — Accept invite (no app installed)

1. Friend taps link in WhatsApp → Firebase Dynamic Link resolves
2. If app installed → deep link opens Plan Detail directly
3. If app not installed → Firebase Hosting web fallback page loads
4. Web page shows plan info + date voting UI
5. On vote → prompt to install app for full experience

#### Flow C — Confirm plan (organiser)

1. Poll closes (manual or auto after 48h)
2. Organiser taps "Confirm plan"
3. Select winning date + enter final venue
4. Cloud Function triggers FCM push to all members
5. Plan status updates to `confirmed`
6. Confetti animation fires on organiser's screen

#### Flow D — Bill split

1. Any member taps "Add expense" on Plan Detail
2. Enter amount, select who paid, select who to split among
3. Cloud Function computes per-person amounts
4. Expense detail shows each person's balance
5. Tap "Pay via UPI" → `url_launcher` opens `upi://pay?pa=...&am=...`
6. Payer marks as settled manually

### 7.3 UPI deep link format

```
upi://pay?pa={upi_id}&pn={payee_name}&am={amount}&cu=INR&tn={plan_title}
```

Build this in `lib/core/utils/upi_utils.dart`:

```dart
String buildUpiLink({
  required String upiId,
  required String payeeName,
  required double amount,
  required String note,
}) {
  final encoded = Uri.encodeComponent(note);
  return 'upi://pay?pa=$upiId&pn=$payeeName&am=${amount.toStringAsFixed(2)}&cu=INR&tn=$encoded';
}
```

---

## 8. Visual design & theme

### 8.1 Design philosophy

Bold, confident, and Indian. Dark accents, energetic type, social warmth. Not a WhatsApp clone, not a foreign app with a Hindi translation — Squad should feel like it was designed in Hyderabad for Hyderabad.

Dark theme is the default. A light theme can be offered as a Pro feature in v2.

### 8.2 Color tokens (`app_colors.dart`)

```dart
class AppColors {
  // Brand
  static const primary     = Color(0xFF1A1A2E); // deep navy
  static const accent      = Color(0xFFE94560); // vibrant red-pink
  static const surface     = Color(0xFF16213E); // card backgrounds
  static const background  = Color(0xFF0F3460); // page background

  // Text
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA8A8B3);

  // Semantic
  static const success = Color(0xFF00B894); // confirmed, paid
  static const warning = Color(0xFFFDCB6E); // polling, pending
  static const error   = Color(0xFFD63031); // destructive actions

  // Neutral
  static const divider = Color(0xFF2D2D4E);
}
```

### 8.3 Typography (`app_text_styles.dart`)

Google Fonts packages: `sora`, `dm_sans`, `jetbrains_mono`

```dart
class AppTextStyles {
  static final display = GoogleFonts.sora(
    fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static final h1 = GoogleFonts.sora(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  static final h2 = GoogleFonts.sora(
    fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  static final body = GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.6);

  static final label = GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, letterSpacing: 0.5);

  static final button = GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.0);

  static final mono = GoogleFonts.jetBrainsMono(
    fontSize: 14, color: AppColors.textPrimary); // UPI IDs, amounts
}
```

### 8.4 Component specs

| Component | Spec |
|---|---|
| Primary button | height 52px, borderRadius 14px, accent fill |
| Secondary button | height 52px, borderRadius 14px, transparent + accent border 1.5px |
| Input field | height 56px, borderRadius 12px, surface fill, accent focused border |
| Plan card | borderRadius 16px, surface fill, accent left border 3px, elevation 0 |
| Avatar | 40px circle, gradient fallback (accent → primary), white initials |
| Poll option chip | borderRadius 24px, height 44px, surface → accent fill on selected |
| Expense row | height 48px, left icon, right amount in JetBrains Mono |
| Bottom nav | surface background, accent selected icon, icon-only (no labels) |
| FAB | 56px, accent fill, white icon, borderRadius 18px |

### 8.5 `ThemeData` setup

```dart
ThemeData buildTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.accent,
    surface: AppColors.surface,
    background: AppColors.background,
    onPrimary: Colors.white,
  ),
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: AppTextStyles.button,
    ),
  ),
);
```

### 8.6 Motion & micro-interactions

| Interaction | Spec |
|---|---|
| Page transition | Shared-axis horizontal slide, 300ms, easeInOutCubic |
| Plan card entry | Staggered FadeInUp, 50ms delay per card |
| Poll vote | Scale + color transition on chip, 150ms |
| Plan confirmed | `confetti` package fires on status change |
| OTP input | Auto-advance focus; shake animation on wrong OTP |
| FAB press | Scale to 0.95, spring back on release |

---

## 9. Monetisation

### 9.1 Free tier

- Up to 3 active plans at a time
- Basic bill split (equal split only)
- Shareable links (with "Made with Squad" watermark on web fallback)
- Up to 8 members per plan

### 9.2 Pro — ₹299 one-time

- Unlimited active plans
- Custom split (unequal amounts per person)
- Memory feed (photo dump after plan completes)
- Plan templates (trip, dinner, trek, movie night)
- No Squad branding on shared invite pages
- Up to 20 members per plan

### 9.3 Squad Pack — ₹799 one-time

- Pro for 5 friends in one purchase
- Organiser buys once, enters 4 phone numbers, all get Pro unlocked
- This is the viral mechanic — gifting = word of mouth

### 9.4 Payment implementation

- Use `in_app_purchase` Flutter package for Play Store / App Store billing
- On successful purchase → Cloud Function verifies receipt → sets `isPro: true` in Firestore
- Squad Pack → Cloud Function sends invite SMS to 4 numbers with Pro unlock token
- Product IDs: `squad_pro_onetime`, `squad_pack_5`

---

## 10. Push notification specs

| Trigger | Title | Body |
|---|---|---|
| Invited to plan | "New plan from {name}" | "{organiserName} wants to plan {planTitle}. Vote now!" |
| Plan confirmed | "It's happening! 🎉" | "{planTitle} is confirmed for {date}. See you there!" |
| New expense added | "New expense" | "{addedBy} added ₹{amount} for {planTitle}" |
| Someone paid back | "Paid! ✅" | "{name} paid ₹{amount} back" |
| Poll reminder (24h) | "Haven't voted yet?" | "Poll for {planTitle} closes tomorrow" |

All notifications deep-link into the relevant plan screen via Dynamic Links.

---

## 11. Web fallback (Firebase Hosting)

Non-app users who receive an invite link must be able to RSVP and vote without installing Squad. This is critical for adoption — the invite experience cannot require the app.

### 11.1 Pages

- **Plan landing** — plan title, organiser name, date options, location
- **Vote** — tap a date to vote (Firestore write via Firebase JS SDK)
- **Confirmation** — "Your vote is in! Install Squad for the full experience" + store links

### 11.2 Implementation

- Single HTML file + vanilla JS + Firebase JS SDK v9
- Deployed to Firebase Hosting at `squad.app/invite/:planId`
- OG meta tags for WhatsApp link preview (`og:title`, `og:description`, `og:image`)
- Mobile-responsive, dark theme matching the native app
- Firestore REST write on vote (no auth required for this action — security rule allows unauthenticated writes to `pollOptions` given a valid planId)

### 11.3 WhatsApp share message template

```
Hey! Let's plan {planTitle} 🎉

{organiserName} has set up a plan on Squad.
Vote for your preferred date here 👇

{inviteLink}

(Tap the link to vote — no app needed!)
```

---

## 12. MVP build timeline

| Week | Deliverable |
|---|---|
| Week 1 | Firebase project setup, Firestore schema, Auth flow (phone OTP), routing scaffold |
| Week 2 | Create plan + invite link flow, Firestore CRUD, Dynamic Links |
| Week 3 | Poll/voting UI, plan detail screen, confirm plan + FCM notifications |
| Week 4 | Bill split, expense model, UPI deep links, Cloud Functions |
| Week 5 | Web fallback (Firebase Hosting), Pro upgrade screen, `in_app_purchase` |
| Week 6 | Polish, bug fixes, theme refinement, TestFlight + Play internal testing |

### 12.1 Launch distribution strategy

- Seed at IIIT Vadodara — personal network, 1 batch = ~50 organic users
- Every shared plan link is a branded invite — built-in acquisition loop
- Twitter/X launch thread: "Built this because WhatsApp planning is chaos"
- ProductHunt launch in week 7 for global dev/tech audience
- Mid-tier travel/college Instagram creators (50k–200k) in week 8

---

## 13. Risks & mitigations

| Risk | Mitigation |
|---|---|
| WhatsApp groups replace Squad | Web fallback makes Squad useful even for non-installers; plan recap screenshots are the hook |
| Low D7 retention | Memory feed (post-plan photo dump) is the retention loop — ship in v1.5 |
| UPI deep links fail on some Android OEMs | Fallback to copy UPI ID; test on 5 OEMs before launch |
| Firebase costs spike at scale | Firestore read limits per plan; cache plan data client-side with Riverpod |
| Play Store review delays | Submit to internal testing in week 5; production track in week 6 buffer |
| Dynamic Links deprecation (Firebase) | Monitor Firebase announcements; fallback to custom short URL redirect if needed |

---

*Squad PRD · MVP v1.0 · Last updated March 2026*
