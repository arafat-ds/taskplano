<div align="center">

# TaskPlano

**A production-ready Flutter task management application built with Clean Architecture**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

*Plan smarter. Do more.*

</div>

---

## Overview

TaskPlano is a cross-platform Flutter productivity application that lets users capture, organise, and track their tasks from anywhere. It solves the problem of scattered to-do lists by providing a single, cloud-synced workspace backed by Supabase — so tasks persist across devices and app restarts without any manual sync step.

The codebase is written to production standards: Clean Architecture keeps each layer independently testable, Cubit provides predictable state management, and optimistic UI updates ensure the interface feels instant even on slow connections.

---

## Features

### Authentication
- **Sign Up** — create an account with email and password; supports Supabase's email confirmation flow with a dedicated "check your inbox" screen
- **Login** — sign in with email and password via Supabase Auth
- **Logout** — signs out from Supabase, clears the local session cache, and redirects to login with a snackbar confirmation
- **Session persistence** — Supabase JWT is restored on cold start so users are not asked to sign in again on every launch
- **Real-time auth stream** — `AuthCubit` subscribes to Supabase's `onAuthStateChange` stream; token refreshes and external sign-outs are handled automatically
- **Route protection** — GoRouter's `refreshListenable` re-evaluates the redirect guard on every auth state change, preventing unauthenticated access to protected routes

### Task Management
- **Create task** — title (required, max 200 chars), optional description, and optional due date via a glassmorphism bottom sheet
- **Read tasks** — fetches all tasks for the authenticated user from Supabase with RLS enforcement
- **Update task** — edit title, description, completion status
- **Delete task** — swipe-to-delete on the list or from the detail screen app bar with a confirmation dialog
- **Toggle completion** — animated checkbox on each card instantly flips the task between active and completed

### Optimistic Updates & Rollback
- Toggle, edit, and delete operations apply changes to the local list **before** the Supabase call returns, giving instant visual feedback
- A subtle `LinearProgressIndicator` shows while a write is in-flight (`isSyncing` flag)
- On API failure the previous `TaskLoaded` state is restored (rollback) and an error snackbar is shown — the UI is never left in an inconsistent state

### Task Filtering & Stats
- Three filter tabs: **All**, **Active**, **Done** — filter is preserved across state emissions without hitting the network
- Live stats bar shows total, active, and completed counts with animated number transitions
- Staggered slide-in animation for each task card on load

### Task Detail
- Full detail view with status badge (Pending / Completed / Overdue), title, description, creation date, and due date
- Relative due date labels: "Today", "Tomorrow", "Yesterday", or a formatted date
- Overdue detection with red styling when a task's due date has passed
- Mark as Complete / Mark as Pending toggle button

### Share Feature
- Any task can be shared via the native share sheet (WhatsApp, Messenger, Email, etc.)
- Share button on each task card and in the detail screen app bar
- Formatted share text:
  ```
  📋 Task: <title>
  📝 <description>
  📅 Due: <due date>
  ✅ Status: Active / Completed

  Shared from TaskPlano 🚀
  ```

### Onboarding
- Three-slide animated onboarding flow shown once on first launch
- Completion state persisted in Hive; returning users skip directly to login
- Skip button available on every slide
- Per-slide gradient colour scheme and icon

### Theme
- Full **dark mode** and **light mode** support via `ThemeCubit`
- Toggle cycles: System → Light → Dark → Light (loop)
- Theme toggle accessible from both the task list app bar and the profile settings card
- Material 3 design system with deep indigo seed colour (`#4F46E5`)
- Animated gradient background with decorative blur orbs on every screen
- Glassmorphism (`BackdropFilter`) surfaces throughout

### Profile
- Displays authenticated user's name (derived from email) and email address
- Theme toggle switch
- App version display
- Logout button with loading state and snackbar confirmation

---

## Architecture

TaskPlano follows **Clean Architecture** with a strict three-layer separation. Dependencies always point inward — the domain layer has zero framework dependencies.

```
┌──────────────────────────────────────────────────┐
│                 Presentation Layer                │
│  Cubit · State · Pages · Widgets · GoRouter      │
├──────────────────────────────────────────────────┤
│                   Domain Layer                   │
│  Entities · Repository Interfaces · Use Cases   │
├──────────────────────────────────────────────────┤
│                    Data Layer                    │
│  Models · Remote Datasource · Local Datasource  │
│  Repository Implementations                     │
└──────────────────────────────────────────────────┘
```

### Presentation Layer
Widgets and pages contain only UI logic. They read state from Cubits via `BlocBuilder` / `BlocConsumer` and dispatch methods to Cubits — never to repositories directly.

### Domain Layer
Pure Dart. No Flutter, no Supabase, no Hive. Entities define the shape of data; use cases encapsulate a single business operation; repository interfaces define the contract the data layer must fulfil.

### Data Layer
Implements repository interfaces. `AuthRemoteDatasource` and `TaskRemoteDatasource` handle all Supabase calls. `AuthLocalDatasource` (Hive) caches the user session for offline-friendly cold starts. Exceptions thrown here are caught by repository implementations and converted to typed `Failure` objects before being returned as `Either<Failure, T>`.

### State Management
`flutter_bloc` Cubits are used throughout. Each feature has its own Cubit:

| Cubit | Responsibility |
|---|---|
| `AuthCubit` | Session check, sign-up, login, logout, Supabase auth stream |
| `TaskCubit` | CRUD operations, optimistic updates, filtering, sharing |
| `ProfileCubit` | Loads user data from `AuthCubit` state |
| `OnboardingCubit` | Slide navigation, completion persistence |
| `ThemeCubit` | App-wide theme mode toggling |

### Dependency Injection
`GetIt` service locator. All dependencies are wired in a single `injection_container.dart`. Auth and routing singletons share the same instance; feature cubits are registered as factories (fresh instance per provider).

### Error Handling
`dartz` `Either<Failure, T>` is used at every repository boundary. The UI uses `.fold()` to handle success and failure branches. No unhandled exceptions reach the UI layer.

---

## Tech Stack

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Cross-platform UI framework |
| `flutter_bloc` | ^9.1.1 | Cubit state management |
| `go_router` | ^14.8.1 | Declarative navigation with redirect guards |
| `supabase_flutter` | ^2.8.4 | Auth, database (PostgREST), session management |
| `dartz` | ^0.10.1 | Functional `Either` for error handling |
| `get_it` | ^8.0.3 | Dependency injection / service locator |
| `equatable` | ^2.0.7 | Value equality for entities and states |
| `hive` | ^2.2.3 | Local key-value store (auth session cache, onboarding) |
| `hive_flutter` | ^1.1.0 | Flutter Hive initialisation helpers |
| `share_plus` | ^10.1.4 | Native share sheet for task sharing |
| `build_runner` | ^2.4.13 | Code generation for Hive adapters |
| `hive_generator` | ^2.0.1 | Generates `TypeAdapter` from `@HiveType` annotations |
| `flutter_lints` | ^5.0.0 | Official Flutter lint rules |

---

## Project Structure

```
lib/
├── main.dart                        # Entry point: Supabase init, DI, auth check
├── injection_container.dart         # GetIt wiring for all dependencies
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart       # App-wide strings, type IDs, spacing
│   │   └── supabase_constants.dart  # Supabase URL, anon key, table names
│   ├── errors/
│   │   ├── exceptions.dart          # Data-layer exception types
│   │   └── failures.dart            # Domain-layer failure types
│   ├── router/
│   │   └── app_router.dart          # GoRouter config + auth redirect guard
│   ├── services/
│   │   ├── hive_service.dart        # Hive initialisation + adapter registration
│   │   └── supabase_service.dart    # Supabase initialisation singleton
│   ├── theme/
│   │   ├── app_theme.dart           # Material 3 light/dark ThemeData
│   │   ├── theme_cubit.dart         # Theme toggle logic
│   │   └── theme_state.dart         # ThemeMode state
│   ├── utils/
│   │   ├── date_utils.dart          # Date formatting + overdue detection
│   │   └── validators.dart          # Form field validators
│   └── widgets/
│       ├── glass_container.dart     # Reusable glassmorphism surface
│       └── gradient_scaffold.dart  # Scaffold with animated gradient background
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart   # Hive session cache
│   │   │   │   └── auth_remote_datasource.dart  # Supabase Auth calls
│   │   │   ├── models/
│   │   │   │   ├── user_model.dart              # Hive-annotated user model
│   │   │   │   └── user_model.g.dart            # Generated Hive adapter
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart    # Remote + local strategy
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart             # Pure domain user
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart         # Auth contract
│   │   │   └── usecases/
│   │   │       ├── login_user.dart
│   │   │       ├── logout_user.dart
│   │   │       └── signup_user.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart              # Auth state machine + stream
│   │       │   └── auth_state.dart              # AuthInitial/Loading/Authenticated/…
│   │       └── pages/
│   │           ├── login_page.dart
│   │           └── signup_page.dart
│   │
│   ├── onboarding/
│   │   ├── domain/entities/
│   │   │   └── onboarding_entity.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── onboarding_cubit.dart        # Slide nav + Hive persistence
│   │       │   └── onboarding_state.dart
│   │       └── pages/
│   │           └── onboarding_page.dart         # 3-slide animated flow
│   │
│   ├── profile/
│   │   ├── domain/entities/
│   │   │   └── profile_entity.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── profile_cubit.dart           # Reads from AuthCubit state
│   │       │   └── profile_state.dart
│   │       └── pages/
│   │           └── profile_page.dart
│   │
│   └── task/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── task_remote_datasource.dart  # Supabase PostgREST calls
│       │   ├── models/
│       │   │   └── task_model.dart              # JSON serialisation for Supabase
│       │   └── repositories/
│       │       └── task_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── task_entity.dart             # Pure domain task
│       │   ├── repositories/
│       │   │   └── task_repository.dart         # Task contract
│       │   └── usecases/
│       │       ├── create_task.dart
│       │       ├── delete_task.dart
│       │       ├── get_all_tasks.dart
│       │       └── update_task.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── task_cubit.dart              # CRUD + optimistic updates + share
│           │   └── task_state.dart              # TaskLoaded/Loading/Error/ActionSuccess
│           ├── pages/
│           │   ├── task_detail_page.dart
│           │   └── task_list_page.dart
│           └── widgets/
│               ├── add_task_bottom_sheet.dart   # Glassmorphism create form
│               ├── task_card.dart               # Swipeable animated card
│               └── task_empty_widget.dart       # Animated empty state
│
└── shared/
    └── models/
        └── result.dart                          # Either<Failure, T> type alias
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3.0
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.3.0
- A [Supabase](https://supabase.com) project (free tier works)
- Android Studio / Xcode for device/emulator targets

### 1. Clone the repository

```bash
git clone https://github.com/your-username/taskplano.git
cd taskplano
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

Open `lib/core/constants/supabase_constants.dart` and replace the placeholder values with your project credentials:

```dart
class SupabaseConstants {
  static const String supabaseUrl   = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  static const String tasksTable    = 'tasks';
  static const String profilesTable = 'profiles';
}
```

Your **Project URL** and **anon key** are found in the Supabase dashboard under **Project Settings → API**.

### 4. Set up the Supabase database

Run the following SQL in your Supabase **SQL Editor**:

```sql
-- Tasks table
create table public.tasks (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users(id) on delete cascade,
  title        text not null,
  description  text not null default '',
  is_completed boolean not null default false,
  created_at   timestamptz not null default now(),
  due_date     timestamptz
);

-- Row Level Security: users can only access their own tasks
alter table public.tasks enable row level security;

create policy "Users can manage their own tasks"
  on public.tasks
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);
```

### 5. Configure Supabase Authentication

In the Supabase dashboard:

1. Go to **Authentication → Providers**
2. Ensure **Email** provider is enabled
3. To allow immediate login without email confirmation, go to **Authentication → Email Templates** and disable "Confirm email" — or leave it enabled to use the app's built-in confirmation flow

### 6. Run the app

```bash
# Debug on a connected device or emulator
flutter run

# Release build
flutter run --release
```

### 7. Regenerate Hive adapters (if you modify UserModel)

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Supabase Setup Reference

### Authentication

| Setting | Value |
|---|---|
| Provider | Email / Password |
| Email confirmation | Optional (app handles both flows) |
| JWT expiry | Default (3600s) |

### Tasks Table Schema

| Column | Type | Constraints |
|---|---|---|
| `id` | `uuid` | Primary key, default `gen_random_uuid()` |
| `user_id` | `uuid` | FK → `auth.users(id)`, NOT NULL, cascade delete |
| `title` | `text` | NOT NULL |
| `description` | `text` | NOT NULL, default `''` |
| `is_completed` | `boolean` | NOT NULL, default `false` |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |
| `due_date` | `timestamptz` | nullable |

### Row Level Security

All four operations (`SELECT`, `INSERT`, `UPDATE`, `DELETE`) are gated by a single policy that enforces `auth.uid() = user_id`. Users can never read or modify another user's tasks.

---

## Screenshots

| Login | Sign Up | Task List |
|---|---|---|
| ![Login Screen](screenshots/login.png) | ![Sign Up Screen](screenshots/signup.png) | ![Task List](screenshots/task_list.png) |

| Task Detail | Profile |
|---|---|
| ![Task Detail](screenshots/task_detail.png) | ![Profile](screenshots/profile.png) |

> Screenshots coming soon. Run the app locally to see the full UI.

---

## Development Notes

### Optimistic Updates

Toggle, edit, and delete operations follow this sequence:

1. Snapshot the current `TaskLoaded` state
2. Apply the change locally and emit immediately → UI updates in `<16ms`
3. Call the Supabase use case asynchronously
4. **Success** → `_reloadSilently()` fetches the server-confirmed list
5. **Failure** → restore the snapshot, emit `TaskError` → snackbar shown, UI rolled back

Create operations add a temporary placeholder task (with a local timestamp ID) then reload after Supabase confirms the insert to replace the placeholder with the server-assigned UUID.

### Repository Pattern

Every feature has an abstract repository interface in the domain layer. The data layer provides the concrete implementation. This means:
- The domain layer has zero framework dependencies
- Swapping Supabase for a different backend only requires changing the datasource and repository implementation — use cases and cubits are untouched
- Unit testing use cases requires only a mock of the abstract interface

### Session Restoration

On cold start, `main()` calls `AuthCubit.checkAuthStatus()` before `runApp()`. This reads the persisted Supabase JWT (stored by the SDK) via `authRepository.getCurrentUser()` and emits `AuthAuthenticated` or `AuthUnauthenticated` before the first frame is drawn. GoRouter's initial redirect then sends the user directly to `/tasks` or `/login` with no intermediate flash.

### Auth Stream Subscription

After the initial check, `AuthCubit` subscribes to `supabaseClient.auth.onAuthStateChange`. This handles:
- Token refresh (silent, no state change visible to user)
- Sign-out from another device (immediate redirect to login)
- Email confirmation deep-link (emits `AuthAuthenticated` when confirmed)

### Error Handling Strategy

```
Data Layer        → throws typed Exception (AuthException, ServerException, …)
Repository        → catches Exception, returns Left(Failure)
Use Case          → passes Result<T> through unchanged
Cubit             → .fold() dispatches Left to error state, Right to success state
UI                → BlocConsumer listener shows snackbar for errors
```

Nothing leaks across layer boundaries. Supabase-specific types never appear above the data layer.

### Dark Mode Implementation

`ThemeCubit` wraps `ThemeMode` in an `Equatable` state. `MaterialApp.router` at the root rebuilds via `BlocBuilder<ThemeCubit, ThemeState>` when the mode changes. `GradientScaffold` and all glass containers read `Theme.of(context).brightness` to switch between light and dark palettes. The gradient background uses `AnimatedContainer` so theme transitions are smooth.

---

## Future Improvements

- **Push Notifications** — task reminders via Supabase Edge Functions + FCM
- **Offline Support** — Hive-backed task persistence with background sync when connectivity is restored
- **Task Categories & Labels** — colour-coded grouping with filter by category
- **Due Date Reminders** — local notifications via `flutter_local_notifications`
- **Task Priority Levels** — High / Medium / Low with visual indicators and sort order
- **Team Collaboration** — share tasks with other users; real-time updates via Supabase Realtime
- **Recurring Tasks** — daily / weekly / monthly recurrence rules
- **Analytics Dashboard** — completion rate chart, productivity streaks, task velocity
- **Search** — full-text search across task titles and descriptions
- **Theme Persistence** — save the selected `ThemeMode` to Hive so it survives app restarts
- **Export** — export tasks as CSV or PDF

---

## License

```
MIT License

Copyright (c) 2026 Md. Rabbi Hasan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Author

**Md. Rabbi Hasan**

Built with Flutter, powered by Supabase, architected for production.

---

<div align="center">

*If this project helped you, consider giving it a ⭐ on GitHub.*

</div>
