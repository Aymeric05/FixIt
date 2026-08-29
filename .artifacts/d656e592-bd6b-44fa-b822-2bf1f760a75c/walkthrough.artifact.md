# Walkthrough - Daily Level & Daily Series

Implemented the Daily Challenge system, allowing players to compete on the same levels every day.

## Changes Made

### Core & Infrastructure
- **Database**: Added `DailyChallenges` table to track daily completion and series progression (1-3 levels).
- **Models**: Created `GameMode` (Story, Daily Single, Daily Series) to differentiate game logic.
- **Seeded Generation**: Refactored `LevelGenerator` to accept a `Random` instance, ensuring deterministic level generation based on the date.

### Logic (BLoC & Repositories)
- **`DailyRepository`**: Handles date-based seeds and synchronizes daily progress between local SQLite (Drift) and Supabase.
- **`GameBloc`**:
    - Daily Level: Disabled the restrictive timer (set to 1 hour).
    - Daily Series: Tracks cumulative time across 3 levels and allows resuming.

### UI / UX
- **`DailyPopup`**: A new dialog shown on first launch of the day, offering both daily modes.
- **`DailyChallengeButton`**: Added a calendar icon on the Home Screen for quick access.
- **`GamePage` Updates**:
    - Header now shows "DAILY LEVEL" or "SERIES X/3".
    - Timer displays cumulative time for the series.
    - Series progress is saved immediately upon level completion.

### Debug & Resilience
- **Hard Reset**: Updated to clear `daily_challenges` on both Supabase and Drift.
- **Startup Protection**: Added a 10s timeout to Supabase initialization and a fatal error screen to prevent the "white screen of death" if something goes wrong.
- **Improved Migrations**: Added try-catch blocks to database migrations to handle existing columns gracefully.
