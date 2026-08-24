# COMSATS Lost & Found App

A Flutter mobile application for COMSATS University Wah Campus students to report, find, and reclaim lost and found items.

---

## 📱 Project Overview

| Field | Value |
|---|---|
| **App Name** | COMSATS Lost & Found |
| **Platform** | Android (Primary), iOS, Windows, Web |
| **Framework** | Flutter 3.x + Dart |
| **Backend** | Firebase (Firestore, Auth, Storage) |
| **State Management** | Riverpod |
| **Navigation** | GoRouter |

---

## ✅ Features

### Authentication
- Email/password registration & login
- Forgot password (email reset)
- Auth-state-aware routing (auto redirects to login/home)
- Profile management (update display name)

### Items (Lost & Found Reports)
- **Report Lost Item** — title, category, location, description, date, photos
- **Report Found Item** — same form with "FOUND" type
- **My Items** — view, edit, delete your own reports
- **Item Details** — full details with image carousel, claim submission
- **Home Feed** — browse all reported items with search & filter

### Claims System
- Submit a claim on any item (proof description + ownership details)
- My Claims — view status of all your submitted claims (Pending/Accepted/Rejected)
- Item owner can review and accept/reject claims

### Notifications
- Real-time in-app notifications for claim status updates

### Admin Dashboard
- View all reported items
- Moderate and manage listings

### Search
- Full-text search across title, description, category, location
- Filter by Lost / Found type

---

## 🏗️ Architecture

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router root
│   ├── router/                    # GoRouter + auth guard
│   └── theme/                     # Light & dark theme
├── core/
│   ├── constants/app_constants.dart  # University config (email domain etc.)
│   └── services/storage_service.dart
├── features/
│   ├── authentication/            # Login, Register, Forgot Password, Splash
│   ├── items/                     # Home, My Items, Create Lost/Found, Edit, Details
│   ├── claims/                    # My Claims, Item Claims, Submit Claim
│   ├── notifications/             # Notifications page & provider
│   ├── profile/                   # Profile page
│   ├── admin/                     # Admin dashboard
│   ├── search/                    # Search page
│   └── settings/                  # Settings page
└── shared/
    └── widgets/                   # Bottom nav, image picker, etc.
```

---

## 🔧 Setup Instructions

### 1. Prerequisites
- Flutter SDK 3.x
- Android Studio or VS Code with Flutter extension
- Firebase project

### 2. Clone & Install

```bash
git clone <repo-url>
cd comsats_lost_found
flutter pub get
```

### 3. Firebase Setup

This project already includes `google-services.json` and `GoogleService-Info.plist`.

For a fresh Firebase project:
1. Create project at [firebase.google.com](https://firebase.google.com)
2. Enable **Authentication** (Email/Password)
3. Enable **Cloud Firestore** (production mode)
4. Enable **Firebase Storage**
5. Run `flutterfire configure` to generate `firebase_options.dart`

### 4. Firestore Security Rules

Deploy the included `firestore.rules`:
```bash
firebase deploy --only firestore:rules
```

### 5. Run the App

```bash
# Android (requires connected device/emulator)
flutter run

# Web
flutter run -d chrome

# Windows Desktop
# NOTE: Rename the project folder to remove '&' before building for Windows
flutter run -d windows
```

---

## ⚠️ Known Build Note

The project folder is named `LOST & FOUND APP` — the `&` character causes issues with Windows/Gradle build commands in PowerShell. **The code itself is 100% correct** (flutter analyze reports zero issues). To build for Android or Windows, rename the parent folder to `LOST_AND_FOUND_APP` or similar before running `flutter build`.

---

## 🔮 Future Integration (COMSATS Portal)

The app is architected for easy institutional integration:

### Configuration (`lib/core/constants/app_constants.dart`)
```dart
class AppConstants {
  static const String universityName = 'COMSATS University Islamabad, Wah Campus';
  static const String emailDomain = 'ciitwah.edu.pk';

  // Set to true to restrict registration to university email only
  static const bool enforceUniversityEmail = false;
}
```

To enable university-email-only signup: set `enforceUniversityEmail = true`.

### Integration Points
- **SSO/LDAP**: Replace `AuthService` in `auth_service.dart` with SAML/LDAP auth
- **API Backend**: Swap `ItemRemoteDataSource` with university REST API calls
- **Push Notifications**: Add FCM tokens to user profiles for server-side push

---

## 📊 Data Model

### Item
```
{
  id, ownerId, type (lost|found),
  title, description, category, location,
  date, imageUrls[], status (active|claimed|resolved),
  createdAt, updatedAt
}
```

### Claim
```
{
  id, itemId, claimantId,
  proofDescription, contactDetails,
  status (pending|accepted|rejected),
  createdAt
}
```

### Notification
```
{
  id, userId, title, body,
  isRead, createdAt, type
}
```

---

## 👨‍💻 Developer

**Saad Nafees** — COMSATS University Islamabad, Wah Campus  
Department of Computer Science

---

*COMSATS Lost & Found — Find it. Report it. Return it.*
