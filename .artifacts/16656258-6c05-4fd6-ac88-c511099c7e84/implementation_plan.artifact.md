# Implementation Plan: Victory Screen Fixes & Polish

Address the layout overflow, refine the "First Player" experience, and fix the percentile calculation logic on the level victory screen.

## Proposed Changes

### 1. Fix Percentile & Logic (Repository)
#### [MODIFY] [progression_repository.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/repositories/progression_repository.dart)
- Update `getLevelWinSummary`:
    - Fix the **TOP 0%** bug: If the player is the fastest, return a percentile calculated as `1 / globalCount` (or a specific flag to show "World Record" in the UI).
    - Ensure `worldRecordSeconds` and `worldRecordHolder` are correctly identified.
    - Improve error handling to return safe defaults.

### 2. Layout & UI Polish (GamePage)
#### [MODIFY] [game_page.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/pages/game_page.dart)
- **Fix Overflow**: Wrap `_buildStatBadge` calls in `Expanded` widgets within the `Row` to prevent fixed-width overflows on smaller screens.
- **First Player UI**: If `summary.globalCompletionCount == 1`, simplify the dialog:
    - Hide the Average and Friends sections.
    - Show a large "NEW WORLD RECORD!" banner.
- **Percentile Display**:
    - If percentile is extremely low (e.g. the player is 1st), show **TOP 1%** (or similar) instead of 0%.
    - Only show the TOP % badge if the player is in the top 50% AND there are enough players to make it meaningful (e.g., more than 1).
- **Mini-Leaderboard**: Ensure it strictly shows "Above, Me, Below" as requested.

## Verification Plan

### Manual Verification
1. **Overflow**: Check the victory screen on a narrow device/emulator. Verify the badges resize instead of overflowing.
2. **First Player**: Solve a fresh level. Verify the dialog is clean and only highlights the record.
3. **Top 1%**: Be the fastest in a level with multiple players. Verify it doesn't show "TOP 0%".
4. **Mini-Leaderboard**: Verify that only the relevant friends (immediately better/worse) are shown.
