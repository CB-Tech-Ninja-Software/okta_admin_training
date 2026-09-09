# Directory Dash — Project Context for Claude Code

Offline-first Android study app (APK) to prep for the **Okta Certified Consultant Hands-On Configuration Exam (OKCON1)**.
Built by one person, no accounts, no backend, no cloud sync, sideload APK target.

Dart package name: `directory_dash`.
Stack: Flutter 3.47+ / Dart 3.13+, SQLite via `sqflite` / `sqflite_common_ffi`.

For the design rationale and lessons learned behind architectural choices (sqflite vs drift, Leitner box, mock exam locking, domain weighting), see `docs/lessons-learned.md`.

---

## 1. Exam Structure & Ground Truth

### Part I — DOMC Multiple Choice (47 Q / 75 min practice budget)
Modeled as single-best-answer multiple choice across 8 official domains (sums to 100%):
- **Implementing Advanced Sourcing (8%)** — Attribute-level sourcing, profile source priority, HR-as-a-Source, profile mappings, attribute transformations.
- **Implementing Advanced SSO Strategies (15%)** — Advanced SAML, Advanced Server Access, Okta Access Gateway (OAG), OIDC & OAuth 2.0, RADIUS Agent, SSO troubleshooting.
- **Implementing Custom Configuration Options with Okta (19%)** — Okta Provisioning Platform (OPP), Custom Email Domain, Authentication API, Custom URL Domain, MFA as a Service, Inline & Event Hooks, SCIM App Wizard.
- **Implementing Directory Solutions (13%)** — Active Directory Integration (multi-domain/multi-forest), Agentless DSSO, LDAP Integration & Agent, LDAP Interface.
- **Implementing Inbound Federation with Okta (13%)** — IdP Discovery & routing rules, Okta as SP with 3rd-party IdP, Social IdPs, account linking, Org2Org.
- **Implementing Okta Policies (15%)** — Okta FastPass, Global Session Policy with Behavioral Detection, Authentication Policies, Pre-Auth Sign-On Evaluation, ThreatInsight.
- **Working with Okta APIs (6%)** — API Code Collection, scripted API calls, OAuth / API Access Management best practices.
- **Working with API Access Management (11%)** — Custom authorization servers, Claims & Scopes, Access Management policies, OAuth grant types, Okta SDKs.

### Part II — Hands-On Use Cases (4 use cases / 25% each)
- **App Integrations (25%)** — OIN app integrations and custom app integrations.
- **Creating a Custom Admin (25%)** — Custom administrator roles, app assignments to users and groups.
- **Configuring Policies (25%)** — Authentication policies and rule evaluation.
- **Creating Routing Rules (25%)** — Identity Provider routing rules and assignment criteria.

*Integrity note:* No leaked exam dumps. Content generates textbook-style original questions against official topics from `reference/okta-consultant-exam-study-guide.md`.

---

## 2. Architecture & Directory Layout

```
directory-dash/
  assets/
    data/
      questions.json      # Multiple-choice question bank
      flashcards.json     # Term/concept flashcards deck
      scenarios.json      # Part II decision & sequence scenarios
      reference_notes.json # Browsable summary study notes
  docs/
    lessons-learned.md   # Architectural decisions & post-mortems
  lib/
    core/
      constants/
        exam_constants.dart          # Domain weights, times, thresholds, XP rewards
      database/
        app_database.dart            # SQLite schema, tables, queries & transactions
        seed_importer.dart           # Loads assets/data/*.json into SQLite on first run
      models/
        question.dart                # Question entity & JSON/Map serialization
        flashcard.dart               # Flashcard entity & Leitner progression
        scenario.dart                # Scenario walkthrough entity
        reference_note.dart          # Browsable summary note entity & bookmarking
        question_attempt.dart        # Attempt history & accuracy tracker
        mock_exam.dart               # Mock exam session & domain score breakdown
        user_profile.dart            # Gamification, XP, level & streak state
        badge.dart                   # Unlockable badges & criteria
      services/
        question_engine.dart         # Domain-weighted question picker (8 Part I / 4 Part II domains)
        spaced_repetition_engine.dart # Leitner 3-box flashcard scheduler
        mock_exam_engine.dart        # 47-Q / 75-min countdown / hard sequential lock
        gamification_service.dart    # XP rewards, streak tracking, level & badge evaluator
    main.dart                        # App entry point & scaffold
  reference/
    okta-consultant-exam-study-guide.md # Canonical study guide & topic deep dive (OKCON1)
    okta-admin-exam-study-guide.md      # Prior study guide (OKADM2, passed)
    project-brief.md                    # Project brief & requirements
  test/
    app_database_test.dart
    models_test.dart
    question_engine_test.dart
    spaced_repetition_engine_test.dart
    mock_exam_engine_test.dart
    gamification_service_test.dart
    widget_test.dart
```

---

## 3. Core Engine Mechanics

1. **Domain-Weighted Question Picker (`QuestionEngine`):**
   - Allocates target questions by exact domain percentage across all 8 Part I domains (or 4 Part II use cases).
   - Samples randomly without replacement within domain buckets.
   - Evaluates answers, records attempts in SQLite, and triggers XP rewards.

2. **Spaced Repetition Flashcards (`SpacedRepetitionEngine`):**
   - Leitner 3-box system: Box 1 = "Still Shaky" (weight 0.60), Box 2 = "Reviewing" (weight 0.30), Box 3 = "Mastered" (weight 0.10).
   - Correct self-rating ("Got It") advances card bucket (`min(bucket + 1, 3)`).
   - Incorrect self-rating ("Still Shaky") drops card back to Box 1 immediately.

3. **Mock Exam Engine (`MockExamEngine`):**
   - Generates exact 47-question Part I set matching domain weights (roughly 4/7/9/6/6/7/3/5 across the 8 domains).
   - 75-minute hard countdown (4500 seconds).
   - Strict no-going-back rule: submitting an answer locks it and immediately advances.
   - Calculates domain score breakdown and pass/fail (threshold >= 65%).
   - Awards +100 XP completion bonus and +50 XP pass bonus.

4. **Gamification & Streak (`GamificationService`):**
   - Level = 1 + floor(XP / 100).
   - Streak tracking based on consecutive calendar days (`YYYY-MM-DD`).
   - Badges: `domain_master`, `mock_champion`, `streak_warrior`, `directory_legend`, `flashcard_fiend`.

5. **Seed Importer (`SeedImporter`):**
   - On first launch, reads `assets/data/questions.json`, `flashcards.json`, `scenarios.json`, and `reference_notes.json` and inserts into SQLite in a batch transaction.

---

## 4. House Rules & Guardrails

1. **Offline-first:** Zero external network calls. All state, attempts, and progress live in local SQLite.
2. **Deterministic & safe database queries:** Always enforce constraints and use batch transactions for seeding.
3. **Step dates by calendar days:** Calculate streak dates with `DateTime(y, m, d + n)`, never `Duration(days: n)` across DST transitions.
4. **No async in `setState`:** Always await asynchronous service calls first before setting state.

