# Walkthrough - Server Time Sync & Dynamic New Day

Implemented a robust server-time synchronization and dynamic midnight transition system.

## Changes Made

### Anti-Cheat & Accuracy
- **Server Time Reference**: The app now fetches the official UTC timestamp from Supabase at startup.
- **Offset Calculation**: Instead of relying on the phone's clock (which can be manipulated), the app calculates the difference (offset) between the device and the server. All game logic now uses this "Server-Aligned Time".
- **Deterministic Seed**: The generation of daily levels is now based on this verified server date.

### Dynamic Transition (Live Refresh)
- **Midnight Monitor**: Added a background timer in `HomeBloc` that tracks the seconds remaining until UTC midnight.
- **Auto-Refresh**: When midnight UTC is reached, the app automatically:
    1.  Refreshes the player's home data.
    2.  Updates the `currentDate` in the state.
    3.  Triggers the `DailyPopup` to appear with the new day's levels, even if the player is currently in the menus.

### Technical Implementation
- **DailyRepository**: Added `syncWithServerTime()` and `getSecondsUntilMidnight()`.
- **HomeBloc**: Added `MidnightReached` event and a persistent timer.
- **Supabase**: Requires the `get_server_time()` SQL function to be installed.

## Verification Results

### Anti-Cheat Test
Verified that changing the phone's date manually does not affect the daily level as long as the app can verify the true time with Supabase.

### Live Transition Test
Simulated a midnight approach and verified that the UI refreshes and the new day's popup appears exactly at 00:00:00 UTC without app restart.
