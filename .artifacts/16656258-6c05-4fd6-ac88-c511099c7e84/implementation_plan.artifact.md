# Implementation Plan: Full Reset for Testing

Provide a way to completely reset the game state (local and remote) to test the "New Player" experience.

## User Review Required

> [!WARNING]
> **Action sur Supabase (Remote Reset)** : Pour effacer toutes les données globales et repartir de zéro côté serveur, exécute ce script dans ton **SQL Editor** :
> ```sql
> TRUNCATE TABLE public.level_completions CASCADE;
> TRUNCATE TABLE public.progression CASCADE;
> TRUNCATE TABLE public.profiles CASCADE;
> -- Note: global_levels peut être gardé si tu veux garder les labyrinthes générés,
> -- sinon ajoute: TRUNCATE TABLE public.global_levels CASCADE;
> ```

## Proposed Changes

### 1. Hard Reset Logic
#### [MODIFY] [database_service.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/services/database_service.dart)
- Add a `hardReset()` method that:
    1. Deletes all rows from all Drift tables (`Players`, `Progressions`, `LevelCompletions`).
    2. Logs out the user from Supabase.
    3. Clears local preferences (if any).

### 2. UI Entry Point
#### [MODIFY] [settings_dialog.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/widgets/settings_dialog.dart)
- Add a "DEBUG: RESET ALL DATA" button at the bottom of the settings.
- This button will call `DatabaseService().hardReset()` and then restart the app or redirect to the initialization flow.

## Verification Plan

### Manual Verification
1. **Local Reset**: Click the reset button. Verify the app restarts and you are assigned a new "Guest#XXXX" ID.
2. **Progression Reset**: Verify the main button returns to "PLAY LEVEL 1".
3. **Database Check**: After resetting both Supabase and the App, verify that performing actions creates fresh, clean records.
