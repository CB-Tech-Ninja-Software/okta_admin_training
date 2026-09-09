# Directory Dash — Lessons Learned & Architectural Decisions

Referenced from `CLAUDE.md`. This document records the architectural rationale, design decisions, and tradeoffs made during the development of Directory Dash.

---

## 1. SQLite Engine: `sqflite` + `sqflite_common_ffi` vs `drift`

**Decision:** Use `sqflite` for mobile persistence paired with `sqflite_common_ffi` for host testing.

**Rationale:**
- **Zero code-generation overhead:** `drift` requires `build_runner` and code generation on every schema tweak. For a fast-moving, multi-agent workflow where content schemas might evolve, raw SQLite via `sqflite` provides immediate compile cycles without build-runner friction.
- **Fast cold start & small footprint:** Directory Dash is an offline study app designed for instant loading on Android devices.
- **Host Testability:** By utilizing `sqflite_common_ffi` with in-memory databases (`inMemoryDatabasePath`), all unit tests run natively on Windows/Linux host environments in milliseconds without needing an Android emulator or device attached.

---

## 2. Question Selection: Two-Pass Weighted Allocation vs Pure Random Rolls

**Decision:** Implement a two-pass domain-weighted selection in `QuestionEngine` and `MockExamEngine`.

**Rationale:**
- In small question batches (such as a 10-question quiz or a 15-question Mock Exam), pure random Monte Carlo rolls (`_random.nextDouble() < weight`) suffer from high variance — a 15-question test could easily end up with 4 AD questions and 11 Profiles questions by chance.
- **Two-Pass Solution:**
  1. Pass 1 computes rounded integer targets: `(15 * 0.47).round() = 7` AD questions and `(15 * 0.53).round() = 8` Profiles questions.
  2. Pass 2 handles any rounding shortfall by sampling from the remaining pool using weighted probabilities.
  3. The final selected list is shuffled.
- This guarantees that mock exam question frequency strictly matches the OKADM2 rubric weights (47% AD / 53% Profiles) on every single run.

---

## 3. Flashcard Spaced Repetition: 3-Box Leitner Model for Short-Horizon Cramming

**Decision:** Use a 3-box Leitner system with 60%/30%/10% selection weights.

**Rationale:**
- Traditional SM-2 / Anki spaced repetition algorithms use multi-week exponential decay intervals. For a **2-day cram window** (exam on 8/31/2026), multi-week intervals are irrelevant.
- **The 3-Box Cram Structure:**
  - **Box 1 ("Still Shaky"):** Selected with 60% probability. Any incorrect answer immediately drops the card back here.
  - **Box 2 ("Reviewing"):** Selected with 30% probability. Earned by 1 correct answer.
  - **Box 3 ("Mastered"):** Selected with 10% probability. Earned by 2 consecutive correct answers.
- This aggressively recycles weak spots so the user gets high repetition on their hardest topics.

---

## 4. Mock Exam Flow: Hard Countdown and Immediate Answer Locking

**Decision:** Enforce non-reversible answer commits (`submitAnswer` advances `currentQuestionIndex` immediately) with domain breakdown metrics.

**Rationale:**
- The official Okta exam format does not permit revisiting previously confirmed questions in Part I.
- Storing answers immediately into SQLite ensures that an accidental app closure or phone sleep preserves the exact state and timer progress.
- Results provide actionable readiness feedback by calculating accuracy separately for each exam domain.

---

## 5. Calendar Math for Streaks: Date Strings vs `Duration(days: 1)`

**Decision:** Use calendar date strings (`YYYY-MM-DD`) derived from local date components (`dt.year`, `dt.month`, `dt.day`) rather than `dt.subtract(Duration(days: 1))`.

**Rationale (jBudget Hard Rule 23):**
- A local day across a daylight-saving transition is 23 or 25 hours. Using `Duration(days: 1)` can drift the timestamp to 23:00 on the previous day, causing false streak breaks or duplicate increments.
- Formatting to `YYYY-MM-DD` and comparing calendar day diffs provides bulletproof daily streak tracking.

---

## 6. Reference Library & Content Scaling Safeguards

**Decision:** Add browsable `ReferenceNote` model/table and ensure all tests and algorithms scale dynamically without hardcoding item counts.

**Rationale:**
- **Decoupled Reference Browsing:** Users need a mode for deep conceptual reading separate from active testing. `ReferenceNote` supports domain/topic filtering, Markdown rendering in UI, source URLs to official Okta documentation, and personal bookmarking (`bookmarked` column).
- **Scale Invariance:** Algorithms in `QuestionEngine`, `SpacedRepetitionEngine`, and `MockExamEngine` operate dynamically over arbitrary dataset sizes (from 70 to 150+ questions). Test assertions use lower bounds (`>=`) rather than brittle equality checks so content expansion by other agents never breaks the build.

---

## 7. Touch Targets & System Gesture Insets: The Flashcard Bottom Bar Postmortem

**Symptom:**
On real physical Android devices with 3-button or full-screen gesture navigation enabled, bottom action buttons on the Flashcard review screen ("Still Shaky" / "Got It") intermittently failed to register taps. Users had to repeatedly tap or aim unnaturally high above the button center to trigger the card progression.

**Root Cause:**
1. **System Gesture Inset vs. View Padding:** Modern Android OS gesture navigation (e.g. Google Pixel gesture bar, Samsung OneUI navigation pill) captures edge-swipe gestures across a dedicated hit zone at the bottom edge. Standard `viewPadding.bottom` or simple `SafeArea` only clears display notches or fixed bottom bars, but does not guarantee clearance of `systemGestureInsets.bottom` (which can extend 24–48dp up from the physical display edge).
2. **Gesture Interception:** Interactive controls positioned inside that bottom boundary have their pointer events intercepted or delayed by the OS gesture subsystem before Flutter's gesture recognizer can dispatch pointer down/up callbacks.

**Resolution & Hardening Pattern:**
1. **Unified Safe Bottom Inset Helper:** Defined `AppTheme.safeBottomInset(context)`:
   ```dart
   static double safeBottomInset(BuildContext context) {
     final mq = MediaQuery.of(context);
     final bottom = math.max(mq.systemGestureInsets.bottom, mq.viewPadding.bottom);
     return bottom > 0 ? bottom : 24.0;
   }
   ```
2. **Global Application:** Applied `safeBottomInset` padding to scrollable lists and bottom floating action rows across all screens:
   - `HomeScreen` (Home hub mode cards `ListView`)
   - `ChecklistScreen` (Day-of-exam checklist `ListView.builder`)
   - `ScenarioListScreen` and `ScenarioDetailScreen` (Scenario walkthroughs)
   - `ProgressScreen` (Dashboard and badge grid)
   - `FlashcardScreen`, `QuizScreen`, and `MockExamScreen` (Review rating bar and submit/next buttons)
3. **Minimum Touch-Target Sizing:** Enforced Material 3 minimum touch target heights (`minHeight: 48dp`) on all interactive buttons.
4. **Real `tester.tap()` Widget Regression Tests:** Built `test/widget_tap_regression_test.dart` executing real `tester.tap()` hit-testing on rendered widget centers across all screens to guarantee touch-target accessibility and route transitions.
