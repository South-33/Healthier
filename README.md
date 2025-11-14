# Healthier

A minimalist, Notion-like health companion app for older adults to track medications, health logs, and get AI-powered insights based on their personal data.

## Vision

**Goal**: Clear, friendly, privacy-first guidance for medication and health tracking with context-aware AI chat.

**Promise**: Not medical advice, but helpful insights and reminders grounded in your own data.

## Target Users

- **Primary**: Adults 50+, low-to-medium tech literacy.
- **Secondary**: Caregivers/family (with privacy permissions).

## Core Use Cases

- **Medication tracking**: Add meds, schedules, reminders, log intake, refill prompts.
- **Health journal**: Simple Notion-like blocks for symptoms, notes, photos, tags.
- **Vitals**: Track BP, HR, glucose, weight, temperature, SpO2.
- **Documents**: Scan/upload prescriptions/lab results; OCR to extract key info.
- **AI chat**: Ask questions; receive context-aware suggestions citing your data.
- **Today view**: What to take now, what's upcoming, quick log, alerts.

## Features Implemented ✅

### Core App Structure
- ✅ **Home Screen** - Calming “Now” medication card, timeline of today’s plan with urgency outlines, and quick log actions tuned for older adults

### Firebase Backend (Complete)
- **Authentication** - Email/password sign-in/sign-up with Firebase Auth
- **Chat Persistence** - Real-time conversation and message storage in Firestore
- **Conversation History** - View, rename, delete, and auto-title conversations
- **Security Rules** - User-isolated Firestore rules with shared `config/ai` access for Gemini key

### AI Features
- **Unified Chat & Titles** - Single Gemini model handles responses plus inline title directives `[title:...]`, backed by shared Gemini key
- **Context Awareness** - Chat responses incorporate user data and conversation history
- **Streaming Responses** - Real-time message streaming with thinking indicators
- **Smart Titling** - Automatic conversation titles based on content, triggered on tab switches

## UX Principles

- **Simple first**: One primary action per screen, obvious CTAs.
- **Accessible**: Large targets (≥48dp), high contrast, dynamic text, voice input/output.
- **Consistent**: Cohesive design tokens, spacing, iconography, typography.
- **Trust & clarity**: Always show data sources and disclaimers, transparent privacy.
- **Offline-first**: Works without internet; AI gracefully degrades with local-only mode.

## Information Architecture

- **Top-level navigation**: Bottom navigation bar with Reference and AI Chat tabs.
- **Shortcuts**: Floating "+" for Add intake/note/doc; Quick access to Emergency Card.
- **Search**: Universal search across meds, notes, docs.

## Screens and Acceptance Criteria

### Onboarding
- Capture profile: age, sex/gender, conditions, allergies, primary physician contact.
- Consent for AI/cloud usage; privacy choices clearly explained.

### Today
- Due meds (now/next), quick confirm/log intake, snooze.
- Quick add symptom/vital entry.
- Daily summary (missed doses, alerts).

### Medications
- List with status (active/on hold), sort by time.
- Add/edit: name, dosage, form, route, frequency, timing, with-food, start/end, prescriber, notes, attachments.
- Refill tracker and reminders; pause/resume.

### Intake Log
- Timeline of doses; edit/correct; mark reason for miss.

### Journal (Blocks)
- Blocks: text, symptom scale, photo, tag, vitals snapshot, checklist.
- Filter by tag/date; export selected entries.

### Vitals
- Quick entry; trends charts; target ranges per user profile.

### Documents
- Scan via camera; import PDF; crop/enhance; OCR; auto-tag.
- Side-by-side doc and extracted text; tap-to-create med from doc.

### Chat (AI)
- Context-aware: cites profile, recent intake, journal, docs.
- Shows sources and confidence; one-tap follow-ups.
- Safety: "Not medical advice"; escalation tips for red flags.
- **✅ Implemented**: Conversation persistence, history, auto-titling, rename/delete

### Reference/Insights
- **✅ Implemented**: Beautiful saved insights screen with modern glass-morphic design.
- Displays saved insights, planned collaborations, and engaging text cards.
- Custom radial background image with soft pink gradient effect.
- Filter chips for "Audio Content" and "Categories".
- Bottom navigation integration for seamless switching with AI Chat.

### Settings
- Privacy (cloud vs local-only AI), export/import, notifications, passcode/biometric, text size, theme.

### Emergency Card
- Large, scannable summary: conditions, allergies, meds, emergency contact.
- **✅ Implemented**: Emergency SOS countdown screen that alerts caregivers and services after a grace period

## Design System (Minimalist, Notion-like)

### Color
- Background: `#F8FAFC`
- Surface: `#FFFFFF`
- Text: `#0F172A`
- Accent: `#22C55E` (soft green) for primary elements, with subtle opacity for glassy effects
- Radial gradients and backdrop filters for modern, minimalist aesthetic
- Danger: `#EF4444`, Warning: `#F59E0B`, Info: `#3B82F6`
- High-contrast mode variants for WCAG 2.1 AA/AAA.

### Typography
- Google Fonts: Lora for headings, Inter for body text; base 18sp; scale with system setting; headings 20–24sp; line height 1.4–1.6.

### Spacing
- 8dp grid; touch targets ≥48dp; section spacing 16–24dp.

### Components
- Cards, ListTiles, Segmented controls for tabs, Elevated primary CTA, Secondary text buttons, Input fields with large labels, Chips for tags.

### Icons
- Simple line icons; consistent stroke; clear meaning.

## Data Model (Firebase + Local)

### Entities (Firebase)
- **Users** (Firebase Auth)
- **Conversations** (Firestore)
  - title, model, systemPrompt, createdAt, updatedAt
- **Messages** (Firestore)
  - role, content, status, createdAt

### Local Data (Future)
- UserProfile: id, age, sex/gender, height, weight, conditions[], allergies[], physician, emergencyContact.
- Medication: id, name, dosage, unit, form, route, withFood, instructions, startDate, endDate, prescriber, tags[], attachmentIds[].
- Schedule: id, medicationId, frequency (daily/weekly/custom), times[], daysOfWeek[], asNeeded, remindersEnabled, timezone.
- Intake: id, medicationId, scheduledTime, takenTime, dose, status (taken/missed/snoozed), note, sideEffects[].
- JournalEntry: id, dateTime, blocks[] (type, content, photoId?, tags[]).
- Vital: id, type (BP/HR/etc), value(s), units, dateTime, note.
- Document: id, type (rx/lab/pdf), filePath, ocrText, extractedEntities (meds/doses), tags[], createdAt.
- Insight: id, type, message, sources[], createdAt, severity.
- Settings: privacyMode, notifications, passcodeHash, theme, textScale, aiProviderConfig.

### Relationships
- 1–many: Medication→Schedule, Medication→Intake.
- 1–many: Document→extractedEntities (link to Medication by suggestion).
- JournalEntry blocks reference attachments.

### Storage
- Firebase Firestore for chat data
- Local encrypted storage for user data (planned)
- Binary store for files (docs/photos) separated from DB rows.
- Export/import as encrypted archive (JSON + files).

## AI Design

### Context Builder
- Pull recent intakes (e.g., last 14 days), active meds + instructions, profile (age/conditions/allergies), recent journal and vitals, relevant docs OCR.
- Summarize + cite with IDs for traceability.

### Providers
- **Chat AI**: Google Generative AI (Gemini 2.5 Flash) for conversation responses
- **Title AI**: Google Generative AI (Gemini 2.5 Flash Lite) for conversation titles
- Local-only mode: minimal on-device model for simple Q&A/summaries; if unavailable, restrict to rule-based insights.

### Safety
- Disclaimers, red-flag detection (e.g., chest pain, severe allergic reaction) → advise emergency protocols.
- No hallucinated meds: only reference stored meds unless clearly labeled as general info.
- Source links with "why you're seeing this".

### Use Cases
- "Headache after med + drink" → Cross-check recent intake + interactions list + known side effects → Suggest hydration/rest, timing adjustment, or seek care; show sources.
- "What did I miss this week?" → Summarize missed doses with reasons and tips.

## Firebase Backend (Implemented)

### Features
- **Authentication**: Email/password with Firebase Auth
- **Chat Persistence**: Real-time conversation storage in Firestore
- **Conversation Management**: History, rename, delete, auto-titling
- **Security**: User-scoped Firestore rules

### Setup (Already Done)
1. Firebase project created and configured
2. FlutterFire CLI configuration complete
3. Dependencies added and Firebase initialized
4. Firestore rules deployed
5. Authentication enabled in Firebase Console

### Data Structure
```
users/{uid}
  conversations/{conversationId}
    title: string
    model: string
    systemPrompt: string
    createdAt: timestamp
    updatedAt: timestamp
  conversations/{conversationId}/messages/{messageId}
    role: 'user' | 'assistant'
    content: string
    status: 'streaming' | 'final' | 'error'
    createdAt: timestamp
```

## Architecture & Stack

### Framework
- Flutter (Stable), cross-platform (Android, iOS, Windows).

### AI Provider
- Google Generative AI (Gemini) for context-aware chat responses and titles.

### UI/Rendering
- flutter_markdown for rich text in chat, google_fonts for typography (Lora and Inter).

### Storage
- **Firebase Firestore** for chat data
- shared_preferences for API key persistence
- Encrypted local storage for user data (planned)

### State
- Riverpod (code-gen) for modular, testable state; Freezed for models.

### Navigation
- go_router with typed routes and deep links.

### Data
- Firebase repositories for auth and conversations
- Drift ORM + sqlite3; sqlcipher for encryption (planned).

### Dependencies (Current)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_ai_toolkit: any
  google_generative_ai: ^0.4.7
  flutter_markdown: ^0.6.18
  shared_preferences: any
  google_fonts: any
  firebase_core: any
  firebase_auth: any
  cloud_firestore: any
  firebase_ui_auth: any
```

## Directory Structure

lib/
├── core/ (theme, tokens, utils, routing)
├── data/
│   ├── models/ (message.dart, conversation.dart)
│   └── repositories/ (auth_repository.dart, conversation_repository.dart)
├── features/
│   ├── auth/ (auth_gate.dart)
│   ├── chat/ (chat_page.dart)
│   ├── reference/ (reference_screen.dart)
│   └── ... (other features)
├── widgets/ (shared UI)
└── app.dart, main.dart

## Core Features Checklist

- [x] **Onboarding and user profile setup**
- [ ] Medication CRUD with scheduling and reminders
- [ ] Intake logging and history
- [ ] Health journal with block-based entries
- [ ] Vitals tracking and trends
- [ ] Document scanning and OCR
- [x] **AI chat with context awareness and persistence**
- [x] **Reference/Insights screen with beautiful UI and bottom navigation**
- [ ] Privacy and security features
- [ ] Accessibility compliance
- [ ] Export/import functionality

## Recent Updates

- **Firebase Backend Complete**: Authentication, chat persistence, conversation history, and auto-titling implemented
- **Dual AI Models**: Separate models for chat responses and conversation titles
- **Live Conversation Titles**: AppBar shows current conversation title from Firestore
- **In-Thread Thinking Indicator**: Shows typing bubble while AI generates responses
- **Persistent Tab State**: Chat page state preserved when switching tabs
- **Conversation Management**: Full CRUD operations for conversations with rename/delete
- **UI Polish**: Glassy, minimalist design with radial gradients and backdrop filters
- **Weekly Planner Refresh**: Scrollable day strip, stacked medication previews, dividers, and consistent 32pt headings across top-level screens
- **Shared Gemini Key Flow**: Firestore `config/ai.geminiApiKey` powers chat by default, settings sheet allows overrides

## Architecture Diagram

```mermaid
flowchart TB
  UI[Flutter UI\n(Chat/Reference/Settings)] --> State[Riverpod State]
  State --> Repo[Repositories]
  Repo --> Firebase[(Firestore + Auth)]
  UI --> Auth[Firebase Auth]
  Chat[AI Chat\n(Gemini Models)] --> Repo
  Chat -->|optional| Gemini[(Gemini API)]
  Settings --> Security[Secure Storage]
```

## Risks & Mitigations

### AI Hallucinations
- Strong citations; prefer user data; conservative phrasing; rules fallback.

### OCR Quality
- Manual confirmation UI; enhance images; allow manual entry.

### Reminder Reliability
- Use native scheduling APIs; thorough device-specific testing.

### Privacy
- Default local-only; explicit consent; clear data sharing settings.