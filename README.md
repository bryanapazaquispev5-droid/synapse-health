# Synapse Health 🩺

> A modern, minimalist health sciences study companion app built with Flutter.

---

## 📌 Features & Architecture

This project follows the **Feature-First (Modular) Architecture** ensuring complete separation of concerns and seamless teamwork:

* **`lib/core/`**: Shared design tokens (minimalist 3-color palette), custom One UI floating bottom pill, and shared services.
* **`lib/features/`**: Completely decoupled feature modules:
  * **`onboarding_permissions/`**: Permission requests and first-run experience.
  * **`auth_login/`**: Authentication, guest mode, and registration.
  * **`cheatsheets/`**: Medical high-yield study cards and reader view.
  * **`quizzes/`**: Clinical case questions with immediate explanatory feedback.
  * **`progress_metrics/`**: Monthly accuracy charts, streaks, and weak-subject alerts.
  * **`user_profile/`**: Student profile and degree track.
  * **`settings/`**: App settings (top corner).

---

## 🔒 Security Best Practices

* **No Secrets Committed**: API keys, credentials, and service accounts (`google-services.json`, `.env`) are strictly ignored via `.gitignore`.
* To configure your local environment, copy `.env.example` to `.env` and add your development credentials.

---

## 📋 Git Commit Guidelines

All commits must follow **Conventional Commits** in English:

```text
<type>(<scope>): <short imperative summary>

- <detailed bullet point 1 explaining what was implemented>
- <detailed bullet point 2 explaining what was changed or fixed>
```

**Allowed Types:** `feat`, `fix`, `refactor`, `style`, `docs`, `chore`.  
**Allowed Scopes:** `core`, `auth`, `cheatsheets`, `quizzes`, `progress`, `permissions`, `settings`.

---

## 🚀 Getting Started

1. Ensure Flutter 3.13+ is installed.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run tests:
   ```bash
   flutter test
   ```
4. Launch the app:
   ```bash
   flutter run
   ```