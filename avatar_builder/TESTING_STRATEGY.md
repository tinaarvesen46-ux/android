# Testing Strategy

## 1. Overview
A multi-tiered testing approach focused on maximizing reliability and rapid iteration. Uses Flutter's built-in testing capabilities along with community-standard mocking tools.

## 2. Testing Layers

### Unit Tests (`test/`)
**Goal:** Verify business logic and state management in isolation.
- **Scope:** Services, Models, and Providers.
- **Tooling:** `flutter_test` for execution, `mocktail` for mocking dependencies.
- **Approach:**
  - Inject dependencies into Services/Providers to make them testable.
  - Mock external dependencies to ensure tests run fast and without network access.
  - Follow the naming convention: `[filename]_test.dart` mapping to files in `lib/`.

### Widget Tests (`test/ui/`)
**Goal:** Verify the functionality, layout, and interaction of reusable UI components.
- **Scope:** Core widgets.
- **Tooling:** `flutter_test` (specifically `WidgetTester`).
- **Approach:**
  - Build UI components in isolation inside a mock app context.
  - Programmatically interact with the UI (taps, drags) and assert on layout and state changes.

### Integration Tests (`integration_test/`)
**Goal:** Verify end-to-end functionality of the application.
- **Scope:** Full app startup, user journeys.
- **Tooling:** `integration_test` (Flutter SDK).
- **Approach:**
  - Test critical paths on real devices or emulators.
  - Run against locally emulated environments where possible.
