# Walkthrough: Full Game Reset for Testing

I have provided both manual and automated ways to reset the game data so you can test as a brand-new player.

## 🛠️ How to Reset

### 1. Remote Reset (Supabase)
To clear all player data from the cloud, run this in your **Supabase SQL Editor**:
```sql
TRUNCATE TABLE public.level_completions CASCADE;
TRUNCATE TABLE public.progression CASCADE;
TRUNCATE TABLE public.profiles CASCADE;
```
> [!NOTE]
> This deletes all players, their progress, and their records. The levels themselves (in `global_levels`) will remain unless you truncate that table too.

### 2. Local Reset (In-App)
I've added a "Hidden" developer button to make testing easier:
1. Open the **Settings** (⚙️) on the Home Screen.
2. At the bottom, you'll see a red button: **DEBUG: RESET ALL DATA**.
3. Click it and confirm.
4. **Restart the app**.

### 3. Native Reset (Android)
Alternatively, you can use the standard Android way:
1. Long press the app icon on your device.
2. Go to **App Info** > **Storage & Cache**.
3. Click **Clear Storage** (or Clear Data).

## Changes Made

### Logic
- **`DatabaseService`**: Added `hardReset()` which wipes all local Drift tables and logs out of Supabase Auth.
- **`SettingsDialog`**: Added the UI trigger for the hard reset flow with a confirmation dialog.

## Verification
1. **Trigger Reset**: Use the button in Settings.
2. **Restart**: Close and reopen the app.
3. **Confirm**: You should see a new Guest ID (e.g., `Guest#5678`) and the Play button should show **LEVEL 1**.
