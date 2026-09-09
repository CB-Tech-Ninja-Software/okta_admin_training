# Project Brief: Okta Administrator Exam Study App ("Directory Dash")
### Canonical build brief — hand to every agent working on this project

---

## 1. What we're building

A personal, offline-first Android study app (APK) to prep for the **Okta Certified Administrator Performance Exam (OKADM2)** on 8/31/2026. This is for one user, no accounts, no backend, no app store release — just something fast, fun, and genuinely useful to drill on a phone while traveling with no signal.

**Tech stack:** Flutter/Dart, same pattern as jBudget (`C:\Users\Chris\jbudget`) and Fieldmate — local-only storage (SQLite via `sqflite` or `drift`), no Firebase Auth, no cloud sync. Build target: Android APK first (sideload-installable), matching the Fieldmate approach. Set up a `CLAUDE.md` at project root with this brief plus a `docs/lessons-learned.md` file, same as the jBudget project structure.

**Working name:** **Directory Dash** (picked by the orchestrator from the brainstorm list — riffs on the AD weak-domain theme with an arcade/dash tone). Change it if a better name surfaces, but don't stall on naming.

---

## 2. Exam ground truth (source of all content)

The exam is 2 parts, and content weighting should mirror this exactly so quiz frequency matches real point value:

**Part I — Multiple Choice (15 Q / 30 min)**
| Domain | Weight |
|---|---|
| Active Directory Integration | 47% |
| Profiles, Sourcing & Write-Back Concepts | 53% |

**Part II — Hands-On Use Cases (4 use cases / 135 min)**
| Use Case | Weight |
|---|---|
| Custom Application Integration | 30% |
| Behavior Detection | 30% |
| Device Assurance | 20% |
| Monitoring & Troubleshooting | 20% |

Full topic breakdown, official prep links, and a cram sheet are in `reference/okta-admin-exam-study-guide.md` in this same directory — treat it as the canonical content source for generating the question bank and flashcard deck.

**Important integrity note:** Do not attempt to source or reproduce actual leaked/dumped exam questions — Okta explicitly bans dump-based prep and it risks score invalidation. Instead, generate original quiz questions and scenarios that test understanding of the *topics* listed in the official study guide (e.g., "AD groups vs. Okta groups," "delegated authentication," "attribute-level sourcing"), the same way a textbook chapter quiz would.

---

## 3. Core features (in priority order)

### 3.1 Weighted Quiz Mode
Pull questions at random, but weighted by the real domain percentages above, so time spent in the app mirrors real exam point value. Each question: 4 answer choices, one correct, a short explanation shown after answering (why right/why the distractors are wrong — this is where real learning happens, don't just show a checkmark).

### 3.2 Flashcard Mode w/ Weak-Area Tracking
Flip cards (term/concept front, explanation back). Track per-card correct/incorrect self-rating. Surface cards the user has marked "still shaky" more often — simple spaced-repetition, doesn't need to be fancy (e.g., a basic Leitner-box style bucket system is plenty for a 2-day cram).

### 3.3 Mock Exam Mode
Simulate real Part I conditions: exactly 15 questions, hard 30-minute countdown timer, no going back to change answers once submitted (matches real exam behavior), results screen at the end broken down by domain — this is the most valuable feature for gauging actual readiness.

### 3.4 Scenario Walkthroughs (Part II prep)
Can't fully simulate hands-on Okta admin console tasks in a phone app, but can quiz the *sequence and logic* of each Part II use case as ordered-step or "what do you do next" scenario questions — e.g., "You need a Device Assurance policy to actually block sign-in. Where do you reference it?" → tests the "attaches to app sign-on policy rule, not standalone" trap from the cram sheet.

### 3.5 Progress Dashboard
Per-domain mastery %, a simple XP/level system, and a visible streak counter. Keep this lightweight and fun rather than corporate-dashboard-serious — this is the "engaging" part. A few unlockable badges per domain mastered (e.g., "AD Whisperer" at 90%+ on Active Directory Integration) would fit the tone without needing real game design effort.

### 3.6 Offline-First
Everything — question bank, progress, flashcard state — stored locally in SQLite. Zero network calls. Must work fully in airplane mode.

---

## 4. Content to seed at build time

Generate an initial question bank and flashcard deck directly from the domains/topics/cram sheet in `reference/okta-admin-exam-study-guide.md`, roughly:

- **~60–80 quiz questions** distributed by the Part I/II weighting above (heaviest on AD Integration and Profiles/Sourcing)
- **~40–50 flashcards** covering the cram-sheet-level facts (AD groups vs. Okta groups, delegated auth, where Device Assurance/Behavior Detection policies attach, System Log filtering basics, SAML attribute mapping flow, etc.)
- **6–8 scenario/sequence questions**, one or two per Part II use case

---

## 5. Nice-to-haves if time allows

- Dark mode (useful for late-night hotel-room studying)
- A "Day of Exam" checklist screen pulled straight from the logistics section of the study guide (Guardian Browser, admin access, memorized login, Okta Verify installed) — simple checkboxes, satisfying to tick off
- A big "days/hours until exam" countdown on the home screen for urgency/motivation (exam: 2026-08-31 8:10 PM EDT)

---

## 6. Explicitly out of scope for v1

- No accounts, login, or cloud sync
- No monetization/app store polish — this is a personal tool, not a shippable product
- No attempt to replicate the live Okta admin console UI for Part II — that's what the free official practice exam and a real preview org are for
