# Implementation Plan - Dynamic Server Time Synchronization

This plan ensures the app always uses accurate server time and dynamically handles the "New Day" transition (midnight UTC) without requiring an app restart.

## User Review Required

> [!IMPORTANT]
> - A new SQL function `get_server_time` must be created in Supabase.
> - The app will calculate the time difference (offset) between the device and the server at startup.
> - A background monitor will detect when the UTC date changes and automatically refresh the Home Screen and Daily Challenges.

## Proposed Changes

### 1. Backend (Supabase SQL)
- Return the current server timestamp in ISO format.

```sql
CREATE OR REPLACE FUNCTION get_server_time() RETURNS TEXT AS $$
  SELECT TO_CHAR(NOW() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"');
$$ LANGUAGE SQL;
```

### 2. Repository Logic
#### [MODIFY] [daily_repository.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/repositories/daily_repository.dart)
- Store a static `Duration _serverTimeOffset`.
- `syncWithServerTime()`: Fetches server timestamp, compares it to local time, and stores the offset.
- `getTodayDate()`: Uses `DateTime.now().add(_serverTimeOffset).toUtc()` to get the current server-aligned date.
- `getSecondsUntilMidnight()`: Helper to know when to trigger the refresh timer.

### 3. State Management
#### [MODIFY] [home_bloc.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/bloc/home_bloc.dart)
- Add `CheckDateTransition` event.
- In `_onLoadHomeData`, start a timer that fires at the next UTC midnight.
- When the timer fires, re-trigger `LoadHomeData` and `_checkDailyChallenge` (to show the new day's popup).

### 4. Application Startup
#### [MODIFY] [main.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/main.dart)
- Call `DailyRepository().syncWithServerTime()` during initialization.

## Verification Plan

### Manual Verification
1.  **Anti-Cheat**: Change phone time +1 day, verify game doesn't change until internet connection confirms server time.
2.  **Dynamic Transition**:
    - Set phone time to 23:59:50 UTC (simulated).
    - Stay on Home Screen.
    - Verify that at 00:00:00 UTC, the Daily Popup automatically appears with the new level.
