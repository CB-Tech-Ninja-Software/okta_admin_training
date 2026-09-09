# Okta Certified Administrator — Performance Exam (OKADM2)
### Study Guide — Exam Date: Sunday, 8/31/2026 @ 8:10 PM EDT

You have **~2 days**. This guide is built to cram efficiently: heaviest focus goes where you're weakest (AD/directory integration) and where the exam weights points, not where you're already comfortable (policies/identity).

---

## 1. Exam Format (know this cold)

This is a **two-part, 165-minute exam** (your order lists 150 min for the reservation window — expect the exam itself to run the official 165 with no scheduled break):

| Part | Format | Time |
|---|---|---|
| **Part I** | 15 standard multiple-choice questions | 30 min |
| **Part II** | 4 performance-based, hands-on use cases in a live Okta Identity Engine Preview Org | 135 min |

- Timers are **separate per part** — leftover time from Part I does NOT roll into Part II.
- Part II: you're given credentials to a preview org and complete real configuration tasks. **Do the use cases in order** — later tasks often depend on earlier ones being done correctly.
- You **are allowed to use the Okta Help Center** during Part II.
- **One or more Part II tasks require Okta Verify on your phone** — install/update it *now*, before exam day, and make sure your phone is charged and nearby.
- Fee: $250 (this attempt); $100 for any retake.
- Grading: automated (system log + API config checks) against a rubric. You only get Pass/Fail — no partial score breakdown beyond section-level performance.

---

## 2. Where the points actually are

This is the single most important table in this guide — study time should roughly mirror this weighting, adjusted for what you already know.

### Part I — Multiple Choice (30 min / 15 questions)
| Domain | Weight | Your status |
|---|---|---|
| **Active Directory Integration** | **47%** | ⚠️ Your stated weak spot — prioritize |
| Profiles, Sourcing & Write-Back Concepts | 53% | Partially overlaps with identity/UD work you already do |

### Part II — Hands-On Use Cases (135 min / 4 use cases)
| Use Case | Weight | Your status |
|---|---|---|
| Custom Application Integration (SAML app + attribute mapping) | 30% | Likely comfortable — practice speed |
| Behavior Detection (auth policy + rules) | 30% | Your strength — policies |
| Device Assurance (policy + FastPass requirement) | 20% | Your strength — policies |
| Monitoring & Troubleshooting (System Log) | 20% | Your strength — likely daily work |

**Bottom line:** AD Integration (47% of Part I) is almost certainly what tripped you up last time — "Windows Azure and Windows configs" you mentioned is really this domain (on-prem AD agents, delegated auth, service accounts), not Azure AD/Entra as a cloud IdP. Put your first big study block there.

---

## 3. Two-Day Study Plan

### Day 1 (Sat 8/29) — Attack the weak domain
- **AM/early block (2–3 hrs): Active Directory Integration** — this is unfamiliar territory, so go slow and hands-on if you have any test AD/Okta agent access. See Section 4 below for the full checklist.
- **Afternoon block (1–2 hrs): Profiles, Sourcing & Write-Back** — this connects directly to AD (profile mastering, group push) so it reinforces what you just studied.
- **Evening (30–45 min):** Take the free [Okta Administrator Performance Practice Exam](https://certification.okta.com/okta-administrator-performance-practice-exam) once, cold, to see where you actually stand — don't study for it, just take it.
- Download and install **Guardian Browser** tonight (link in your confirmation), and run the [equipment test](https://go.proctoru.com/students/system-metrics/new) tonight, not on exam day.

### Day 2 (Sun 8/30) — Reinforce weak spots + hands-on Part II
- **AM (1.5–2 hrs):** Review whatever you missed on the practice exam, re-drill AD integration weak points.
- **Midday (2–3 hrs): Part II hands-on drilling.** If you have any Okta Identity Engine sandbox/dev org access, actually build: a custom SAML app with attribute mapping, a behavior detection rule, a device assurance policy + FastPass requirement, and a System Log filter. Speed matters in Part II — 135 minutes for 4 use cases is tight if you're fumbling through menus.
- **Evening:** Light review only — skim Section 4/5 below, re-read the AD vs Okta groups distinction, get to bed. Don't cram new material the night before a 150-minute proctored exam.

### Exam Day (Mon 8/31, exam at 8:10 PM EDT)
- Morning/afternoon: light review only, don't burn out.
- **1–2 hours before:** re-run the equipment test, confirm Guardian Browser launches cleanly, confirm your Okta Verify login credentials are **memorized or written down** — password managers will not work inside Guardian.
- Have your phone with Okta Verify installed, charged, and nearby (required for at least one Part II task).
- Ensure you have **administrative access to your computer** — Guardian needs it.
- Test in the same room/setup you'll actually use for the exam.

---

## 4. Deep Dive: Active Directory Integration (47% — your priority)

Go through each of these and be able to explain it out loud, not just recognize it:

- **Delegated authentication with AD/LDAP via Okta agents** — understand *why* delegated auth exists (AD stays the password authority; Okta never stores/validates the AD password itself) and how it's enabled per the Password authenticator config.
- **Okta AD/LDAP agent architecture & best practices** — multiple agent installs for redundancy/load, how agents communicate outbound-only to Okta (no inbound firewall holes needed), DMZ port requirements for AD integrations.
- **Okta agent service account & permissions** — what AD permissions the service account needs (read directory, reset passwords, etc.) and why least-privilege matters here.
- **AD/Okta password policy requirements** — how Okta password policy must align with (or defer to) the AD password policy when AD is the source.
- **User activation options when AD is the source** — how activation flows differ when AD is authoritative vs. Okta-mastered.
- **AD groups vs. Okta groups** — this is a classic exam trap. AD groups imported become **read-only in Okta** (you manage membership in AD, not Okta) unless you use group rules/Okta-native groups for anything Okta needs to own. Know **Group Push** (sending an Okta group's membership out to AD) as the inverse direction.

**Prep resources (official):**
- [Add/update users with AD Just-In-Time provisioning](https://help.okta.com/oie/en-us/Content/Topics/Directory/ad-agent-add-update-JIT.htm)
- [Enable delegated authentication for Active Directory](https://help.okta.com/oie/en-us/content/topics/security/enable_delegated_auth.htm)
- [Install multiple Okta AD agents](https://help.okta.com/oie/en-us/Content/Topics/Directory/ad-agent-install-multiple.htm)
- [About Okta service account permissions](https://help.okta.com/oie/en-us/Content/Topics/Directory/ad-agent-about-service-account.htm)
- [Import groups from Active Directory](https://help.okta.com/oie/en-us/Content/Topics/Directory/ad-agent-import-groups.htm)
- [Manage Active Directory users and groups](https://help.okta.com/oie/en-us/Content/Topics/Directory/ad-agent-manage-users-groups.htm)

---

## 5. Deep Dive: Profiles, Sourcing & Write-Back (53%)

- **HR as a source** — why using an HR system as the profile master (vs. AD) changes how groups/group rules should be built downstream.
- **Profile sourcing** — attribute-level sourcing/mastering: which system "owns" which attribute when a user has multiple sources (e.g., HR owns title, AD owns sAMAccountName).
- **Write-back to directories/apps** — when and why you'd push Okta-managed attribute changes back out to AD or a downstream app.
- **Multiple profile sources** — how Okta resolves conflicts/precedence when a user profile is sourced from more than one system.
- **Lifecycle management + writing to apps** — provisioning/deprovisioning flows, and how JIT provisioning from AD fits in.
- **Okta Workflows for advanced lifecycle use cases** — know this exists and conceptually what it's for (event-driven automation beyond what native LCM/provisioning covers), even if you don't build flows day-to-day.

**Prep resources (official):**
- [Manage profiles](https://help.okta.com/oie/en-us/Content/Topics/users-groups-profiles/usgp-user-profiles-main.htm)
- [About attribute-level sourcing](https://help.okta.com/en-us/Content/Topics/users-groups-profiles/usgp-about-attribute-sourcing.htm)
- [Manage profile and attribute sourcing](https://help.okta.com/oie/en-us/Content/Topics/users-groups-profiles/usgp-sourcing-main.htm)
- [Manage Group Push](https://help.okta.com/oie/en-us/Content/Topics/users-groups-profiles/usgp-group-push-main.htm)
- [Provision applications](https://help.okta.com/oie/en-us/Content/Topics/Apps/Provisioning_Deprovisioning_Overview.htm)
- [Okta Workflows overview](https://help.okta.com/wf/en-us/Content/Topics/Workflows/workflows-main.htm)

---

## 6. Part II Use Cases — what you'll actually build

### Use Case 1: Custom Application Integration (30%)
Tasks: create a group + group rule → use Okta Expression Language → add a custom SAML 2.0 app → map Okta attributes to app attributes → create/map a custom attribute → assign the group to the app → verify a user's attribute data reflects correctly in the app.
- Practice the **Profile Editor** attribute mapping flow specifically — it's easy to fumble under time pressure if you haven't done it recently.
- Refresh OEL syntax basics (string functions, conditional logic for expressions).

### Use Case 2: Behavior Detection (30%)
Tasks: set up Okta Verify on a mobile device → configure a behavior detection rule for a group → modify the Catch-All Rule on an authentication policy → test the policy + rule.
- Know the difference between the **behavior detection rule itself** and **where it gets referenced** (inside an authentication policy rule condition).
- This should play to your strength — just make sure Okta Verify is actually installed and working on your phone before exam day, since you'll need it live.

### Use Case 3: Device Assurance (20%)
Tasks: create a Device Assurance policy for your mobile platform → add a rule to the Dashboard app sign-on policy for a group → require Okta FastPass to satisfy the Device Assurance policy's security requirements → test it.
- Know that Device Assurance policies get **referenced inside an app sign-on policy rule**, not applied standalone.
- FastPass is the authenticator that can evaluate/enforce device assurance signals — know why plain password/MFA can't satisfy a device-assurance requirement the same way.

### Use Case 4: Monitoring & Troubleshooting (20%)
Tasks: filter the System Log for successful authentication attempts with specific factors → troubleshoot and correct a login issue.
- Practice System Log filter syntax (event type, outcome, actor) so you're fast, not fumbling with the query builder under time pressure.

---

## 7. Test-Day Logistics (from your ProctorU confirmation)

- **Guardian Browser is required** — download it now and install before exam day.
- **Password managers and stored/autofilled passwords will not work in Guardian.** Have your Okta Certification Credential Manager login memorized or written down somewhere you can read (not type-from) during the exam.
- You need **administrative access to your computer** for Guardian to run its checks.
- **Test your equipment in advance**, ideally in the same room/setup as exam day.
- Review the equipment requirements and port/allow-list requirements — worth checking now in case your network blocks something.
- No scheduled break — you can ask your proctor for a brief one, but the clock keeps running and you may be asked to re-scan your room on return.
- Order #76453159, Live+OKADM2, 8/31/2026 @ 8:10 PM EDT, 150 minutes reserved.

---

## 8. Approved Prep Resources Only

Okta explicitly prohibits exam dumps/brain dumps as prep material — using them risks invalidating your score or getting banned from the certification program. Stick to:
- The official Administrator Performance Exam Study Guide (source for everything above)
- Okta Administrator Performance Practice Exam (free)
- Okta Help Center and Product Documentation
- Okta Administrator Series Learning Plan

---

## 9. Last-Minute Cram Sheet (night before / morning of)

- AD groups imported into Okta = manage membership **in AD**. Okta group + Group Push = manage membership **in Okta**, pushed **to AD**.
- Delegated auth = AD still validates the password; Okta never stores it.
- Device Assurance policies attach to **app sign-on policy rules**, not standalone.
- Behavior detection rules attach to **authentication policy rules** (often the Catch-All Rule).
- Custom SAML app attribute mapping happens in the **Profile Editor**, not the app's general settings.
- Part II — do the 4 use cases **in order**; later ones can depend on earlier ones.
- Guardian Browser + admin access + memorized login + charged phone with Okta Verify = non-negotiable logistics.

Good luck — with AD Integration being both your stated weak point and the single largest slice of Part I, closing that gap is the highest-leverage thing you can do in the next two days.
