# Project: Admin Web Dashboard (Flutter Web)

This document outlines the plan for an external administration interface to manage the FixIt application.

## Goal
Create a secure, standalone web dashboard to manage players, monitor global progression, and perform administrative actions (resetting accounts, gifting lives/hints).

## 1. Security & Permissions (Supabase)

### Database Update
- **Column**: Add `is_admin` (boolean, default: false) to the `profiles` table.
- **Manual Step**: Admin status must be granted manually via the Supabase Dashboard by setting `is_admin = true` on the chosen profile.

### RLS Policies
```sql
-- Allow admins to see all profiles
CREATE POLICY "Admins can view all profiles" ON public.profiles 
FOR SELECT USING (
  (SELECT is_admin FROM profiles WHERE id = auth.uid()) = true
);

-- Allow admins to update any profile
CREATE POLICY "Admins can update all profiles" ON public.profiles 
FOR UPDATE USING (
  (SELECT is_admin FROM profiles WHERE id = auth.uid()) = true
);
```

## 2. Admin Logic Layer (`lib/core/repositories/admin_repository.dart`)

- `fetchPlayers()`: Retrieve all user profiles with pagination.
- `updateInventory(String uid, int lives, int hints)`: Directly modify player resources.
- `resetProgression(String uid)`: Clear `level_completions` and reset `progression.current_level` to 1.
- `banPlayer(String uid)`: (Optional) Mark a player as restricted.

## 3. UI Features (Flutter Web)

### Login Page
- Secure entry for authorized users only.

### Dashboard Layout
- **Sidebar**: Navigation between Player List, Global Stats, and Level Management.
- **Player Data Table**: 
    - Columns: Pseudo, ID, Level, Lives, Hints, Last Seen.
    - Search bar (by Pseudo or ID).
- **Quick Action Modal**:
    - "Give +5 Vies"
    - "Reset Level to 1"
    - "Set Custom Nickname"

### Global Statistics
- Total players count.
- Daily active users.
- Level difficulty heatmap (which levels players fail most often).

## 4. Technical Configuration

- **Entry Point**: Create `lib/main_admin.dart` to separate the Admin logic from the mobile game logic.
- **Run Command**: `flutter run -t lib/main_admin.dart -d chrome`

---

> [!NOTE]
> This plan is documented for future implementation. No code changes have been made to the production mobile app regarding this feature yet.
