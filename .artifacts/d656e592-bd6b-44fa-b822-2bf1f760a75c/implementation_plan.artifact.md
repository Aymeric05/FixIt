# Implementation Plan - Daily Level & Daily Series

This plan outlines the implementation of the "Daily Single Level" and "Daily Series" features as described in the project requirements.

## User Review Required

> [!IMPORTANT]
> - Daily Single Level: One unique level per day, no time limit.
> - Daily Series: Consecutive chain of 3 levels, cumulative time.
> - All players share the same daily levels (seeded generation).
> - Daily Series progress is persisted and can be resumed.

## Proposed Changes

### Core & Models
#### [MODIFY] [app_database.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/database/app_database.dart)
- Add `DailyChallengeStatus` table to track completion and series progress.
- Fields: `playerSupabaseId`, `date`, `isDailyLevelCompleted`, `seriesCurrentLevel` (0 to 3), `seriesAccumulatedTime`, `isSeriesCompleted`.

#### [NEW] [daily_mode.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/models/daily_mode.dart)
- Enum for `GameMode { story, dailySingle, dailySeries }`.

### Repositories
#### [NEW] [daily_repository.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/repositories/daily_repository.dart)
- Logic to generate daily levels using a date-based seed.
- Logic to fetch and update daily status from Supabase/Drift.

### Game Logic (BLoC)
#### [MODIFY] [game_event.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/bloc/game_event.dart)
- Add `GameMode` to `StartGame`.
- Add `CompleteDailyLevel` and `CompleteSeriesLevel` events if needed, or handle within `GameBloc`.

#### [MODIFY] [game_bloc.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/bloc/game_bloc.dart)
- Support `GameMode.dailySingle`: Disable timer (set to a very large value or handle UI display).
- Support `GameMode.dailySeries`: Handle transition between levels 1, 2, and 3. Accumulate time.
- Update `_onSelectCell` to handle daily completion logic.

### UI Components
#### [NEW] [daily_challenge_button.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/widgets/daily_challenge_button.dart)
- A floating or prominent button on the Home Screen for Daily Challenges.

#### [NEW] [daily_popup.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/widgets/daily_popup.dart)
- Popup that appears on the first connection of the day.

#### [MODIFY] [home_page.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/pages/home_page.dart)
- Integrate the Daily Challenge button.
- Logic to show the daily popup if not completed.

#### [MODIFY] [game_page.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/pages/game_page.dart)
- UI adjustments for Daily Mode (e.g., hidden timer for single level, cumulative time display for series).
- Different "Victory" dialog for daily modes.

## Verification Plan

### Automated Tests
- Unit tests for `DailyRepository` level generation (ensuring same date produces same level).
- Unit tests for `DailyBloc` state transitions.

### Manual Verification
- Launch the app and verify the daily popup appears.
- Play the Daily Level and verify no time limit.
- Play the Daily Series and verify time accumulates and state is persisted between levels.
- Verify that finishing the daily challenge updates the Home Screen state.
