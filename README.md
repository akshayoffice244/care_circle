# Care Circle 💙

A cross-platform mobile application built with Flutter designed to help families coordinate and manage care-related responsibilities for loved ones. Care Circle brings medication schedules, doctor appointments, daily care tasks, and family updates together in a shared, real-time environment.

---

## Features

### 💊 Medication Management
- **Detailed Tracking**: Add medications with names, dosage details (e.g., 500mg, 1 tablet), and meal instructions.
- **Custom Schedules**: Set multiple daily doses and reminder timings (Morning, Afternoon, Evening, Night).
- **Scheduled Alarms**: Exact alarms and vibration notifications powered by `flutter_local_notifications` that ring even when the app is closed.
- **Daily Checklist**: Quickly mark doses as **Taken** or **Skipped** to keep everyone updated.
- **Adherence History**: Keep a full log of taken and skipped doses with timestamps and member attribution.

### 🩺 Doctor Appointments
- **Appointment Scheduling**: Store doctor names, specialties, clinic/hospital locations, and clinical notes.
- **Appointment Alarms**: Scheduled reminders notify you on the day of the consultation.
- **Follow-Up Reminders**: Schedule follow-up checkup dates with automated reminder alerts.
- **Upcoming Booking Banners**: Clear visual banners remind the family when future consultations need to be booked.
- **Upcoming & Past Views**: Separate sections for upcoming visits and historical appointments.

### ✅ Daily Care Tasks
- **Task Scheduling**: Add daily care tasks such as vitals checks (blood pressure, glucose), physical therapy, or meals.
- **Member Delegation**: Assign tasks to specific family members in the care circle.
- **Task Filtering**: Switch between **All Tasks** and **Assigned to Me**.
- **Interactive Nudge**: Tap the megaphone icon on any pending task to send a circle-wide reminder alert across all family devices.
- **Completion Tracking**: Check off completed tasks with timestamps and member names.

### 👨‍👩‍👧‍👦 Family Updates & Shared Dashboard
- **Care Circle Groups**: Create or join a family circle using a secure 6-character invite code.
- **Daily Care Overview**: High-level dashboard metrics showing today's medications taken, pending tasks, and upcoming visits.
- **Live Activity Feed**: Automatically updates when medications are taken, tasks are completed, or visits are booked.
- **Family Notes**: Share informal updates and notes directly to the circle's activity feed.
- **Role-Based Access**: Support for Primary Caregiver and Family Member roles.

---
a
## Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **Architecture**: Feature-First Clean Architecture (Domain, Data, Presentation)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) with [equatable](https://pub.dev/packages/equatable)
- **Authentication**: Firebase Authentication (Email & Password)
- **Database**: Cloud Firestore (Real-time synchronization & offline persistence)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) with exact Android AlarmManager scheduling
- **Design**: Material 3 Design System

---

## Project Structure

```text
lib/
├── core/                                 # Global configurations
│   ├── constants/app_colors.dart         # Color palette
│   ├── errors/failures.dart              # Error and failure definitions
│   ├── services/notification_service.dart# Local notification & alarm service
│   └── theme/app_theme.dart              # Material 3 theme data
│
├── features/                             # Modular feature folders
│   ├── appointment/                      # Doctor visits and follow-ups
│   │   ├── data/                         # Models & repository implementations
│   │   ├── domain/                       # Entities, contracts & use cases
│   │   └── presentation/                 # AppointmentBloc & screens
│   ├── auth/                             # User authentication
│   │   ├── data/                         # User model & auth repository
│   │   ├── domain/                       # User entity & auth use cases
│   │   └── presentation/                 # AuthBloc, Login & Register screens
│   ├── circle/                           # Care circle & member management
│   │   ├── data/                         # Circle model & repository
│   │   ├── domain/                       # Circle entity & use cases
│   │   └── presentation/                 # CircleBloc, setup & members screens
│   ├── dashboard/                        # Shared family dashboard & activity feed
│   │   ├── data/                         # Activity feed models
│   │   ├── domain/                       # Activity feed entities & use cases
│   │   └── presentation/                 # DashboardBloc & dashboard screen
│   ├── medication/                       # Medication tracking & adherence history
│   │   ├── data/                         # Medication models & repository
│   │   ├── domain/                       # Medication entities & use cases
│   │   └── presentation/                 # MedicationBloc, list & history screens
│   └── task/                             # Daily care tasks & assignments
│       ├── data/                         # Task models & repository
│       ├── domain/                       # Task entities & use cases
│       └── presentation/                 # TaskBloc & task list screen
│
├── presentation/                         # Navigation & entry widgets
│   ├── app_root.dart                     # Auth and circle navigation router
│   └── main_navigation_screen.dart       # Bottom navigation bar shell
│
└── main.dart                             # Application entrypoint & dependency injection
```

---

## Getting Started

### Prerequisites

- Flutter SDK (v3.19 or later)
- Android Studio or VS Code with Flutter extension
- An Android device or emulator (Android 10+ recommended)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/care_circle.git
   cd care_circle
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   Set up your Firebase project with **Authentication** and **Cloud Firestore** enabled, then configure the app:
   ```bash
   flutterfire configure
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## Permissions & Background Alarms (Android)

Care Circle uses exact alarms to ensure critical medicine and appointment alerts trigger reliably on schedule.

The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `android.permission.RECEIVE_BOOT_COMPLETED` (Restores alarms after device reboot)
- `android.permission.VIBRATE` (Provides haptic feedback for alarms)
- `android.permission.WAKE_LOCK` (Prevents CPU from sleeping)
- `android.permission.POST_NOTIFICATIONS` (Notification display on Android 13+)
- `android.permission.SCHEDULE_EXACT_ALARM` (Exact timing for medication schedules)

For release builds, ProGuard rules in `android/app/proguard-rules.pro` ensure notification receivers are preserved during R8 code shrinking.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
