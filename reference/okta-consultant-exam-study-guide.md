# Okta Certified Consultant — Hands-On Configuration Exam (OKCON1) — Study Guide

Source: https://certification.okta.com/page/occ-hoc-exam-study-guide (fetched 2026-09-01).
Supersedes the OKADM2 (Administrator) study guide this app was originally built around — Chris
passed OKADM2 and is now targeting the Consultant certification, the next tier up.

## Exam Format

- **Duration:** 180 minutes total
- **Fee:** USD $250 (USD $100 per retake)
- **Prerequisites:** Active, unexpired Okta Certified Professional certification AND active,
  unexpired Okta Certified Administrator certification (Chris has this). Recommended training
  or self-study completed. One or more Part II tasks require access to an email address during
  the exam.
- **Structure:** Two parts in one sitting.

### Part I — 47 Discrete Option Multiple Choice (DOMC) Questions
Two case studies frame roughly half of Part I's questions; some questions are independent of
any case study. DOMC means options are presented one at a time (YES/NO per option), not as a
traditional 4-choice list — but for this app's original-content quiz/flashcard/mock-exam modes,
model these as standard single-best-answer multiple choice (4 options), same approach used for
the OKADM2 build, since DOMC's specific UX isn't practical to replicate faithfully and isn't the
point — the point is testing the same knowledge.

### Part II — 4 Performance-Based, Hands-On Use Cases
Live Okta org configuration tasks, each independently weighted 25%. No case-study framing here —
each use case is a self-contained hands-on task. Model these as Scenario Walkthroughs (same
mechanic as the OKADM2 build's Part II), describing the configuration task and asking a
best-next-step / correct-configuration-choice multiple choice question, optionally with ordered
context steps.

## Part I Domains & Weighting (sums to 100%)

| Domain | Weight |
|---|---|
| Implementing Advanced Sourcing | 8% |
| Implementing Advanced SSO Strategies | 15% |
| Implementing Custom Configuration Options with Okta | 19% |
| Implementing Directory Solutions | 13% |
| Implementing Inbound Federation with Okta | 13% |
| Implementing Okta Policies | 15% |
| Working with Okta APIs | 6% |
| Working with API Access Management | 11% |

### 1. Implementing Advanced Sourcing (8%)
- "As a Source" setup and configuration flow
- Attribute-level sourcing and profile source priority
- Advanced sourcing architecture, deployment, testing, troubleshooting
- Data migration strategy
- HR-as-a-Source scenarios
- Profile mappings and attribute transformations

### 2. Implementing Advanced SSO Strategies (15%)
- Advanced SAML implementation scenarios
- Advanced Server Access concepts
- Okta Access Gateway (OAG)
- OIDC flows and OAuth 2.0 roles
- Okta RADIUS Agent configuration
- Testing and troubleshooting SSO integrations

### 3. Implementing Custom Configuration Options with Okta (19%) — heaviest Part I domain
- Okta Provisioning Platform (OPP) architecture and capabilities
- Custom Email Domain
- Deployment models & Authentication API
- Custom URL Domain
- MFA as a Service
- Okta Hooks (Inline Hooks, Event Hooks) and use cases
- SCIM App Wizard

### 4. Implementing Directory Solutions (13%)
- Active Directory Integration (multi-domain/multi-forest environments)
- Advanced configuration with DSSO (Agentless Desktop SSO)
- LDAP Integration and LDAP Agent
- LDAP Interface

### 5. Implementing Inbound Federation with Okta (13%)
- IdP Discovery and routing rules
- Okta as a Service Provider with a 3rd-party IdP
- Social Identity Providers
- Inbound federation troubleshooting
- Account linking functions
- Okta Org2Org configuration

### 6. Implementing Okta Policies (15%)
- Okta FastPass functionality and configuration
- Global Session Policy with Behavioral Detection
- Authentication Policies
- Pre-Authentication Sign-On Evaluation Policy
- ThreatInsight configuration and capabilities

### 7. Working with Okta APIs (6%) — lightest Part I domain
- API Code Collection and common use cases
- Commonly used scripted API calls
- OAuth / API Access Management best practices

### 8. Working with API Access Management (11%)
- API Access Management use cases
- Custom authorization server creation
- Claims and Scopes architecture
- API Access Management policies
- OAuth grant types
- Okta SDKs

## Part II Use Cases & Weighting (each 25%)

1. **App Integrations** — Create an app integration using the OIN (Okta Integration Network);
   create a custom app integration.
2. **Creating a Custom Admin** — Create a custom administrator role; assign apps to users and
   groups.
3. **Configuring Policies** — Configure authentication policies.
4. **Creating Routing Rules** — Create routing rules; assign routing rules.

## Integrity Note (unchanged from OKADM2 build)

No leaked exam dumps, no real DOMC item content. All quiz/flashcard/scenario content must be
original, testing the topics above the way a textbook chapter quiz would — same standing rule
as before, still integrity-critical, still Okta-prohibited to violate.
