# Implementation Plan: Foundation & Home Screen UI

Establish a solid architectural foundation and implement the Home Screen UI according to the requirements in `PROJECT_CONTEXT.md`. This iteration focuses on the layout and structure without the full backend integration.

## User Review Required

> [!IMPORTANT]
> This will involve creating a new directory structure and moving logic into BLoCs. I will start with `flutter_bloc` and `google_fonts`.

## Proposed Changes

### 1. Project Infrastructure
- **Dependencies**: Add `flutter_bloc`, `equatable`, and `google_fonts` to `pubspec.yaml`.
- **Directory Structure**:
    - `lib/core/theme/` (Colors, Typography)
    - `lib/features/home/presentation/` (Pages, Widgets, Bloc)
    - `lib/features/lives/presentation/` (Widgets, Bloc)

### 2. UI Alignment (Section 3 of PROJECT_CONTEXT.md)
#### [NEW] [home_page.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/pages/home_page.dart)
- **Top Left**: Profile icon button (Placeholder).
- **Top Center**: Lives Indicator (❤️ 3/5) with a placeholder countdown.
- **Top Right**: Settings button (Cog icon).
- **Bottom Center**: Large "JOUER" button displaying:
    - Current Level (e.g., "Niveau 1")
    - Difficulty (e.g., "Facile")
- **Background**: Integration of `monde1_background.png`.

### 3. State Management (Initial)
#### [NEW] [home_bloc.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/bloc/home_bloc.dart)
- Manage the state of the Home Screen (Current Level, Life count).

## Verification Plan

### Manual Verification
- Confirm the new UI layout matches the specified requirements.
- Verify that the "PLAY" button displays the correct level and difficulty.
- Ensure the background image is still correctly integrated.
