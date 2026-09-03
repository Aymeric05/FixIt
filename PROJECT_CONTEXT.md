# Game Project Context & Requirements

## 1. Project Overview
This project is a mobile puzzle game (inspired by the progression model of Candy Crush). It is developed using **Flutter** and **Dart**, with the goal of multi-platform deployment on the **Google Play Store** and **Apple App Store**.

**IMPORTANT: The entire application, including UI, code documentation, and assets, must be in English.**

The application integrates level progression mechanics, a time-limited life system, social features (friends and daily leaderboards), and hybrid monetization.

## 2. Global Technical Stack
*   **Frontend:** Flutter / Dart
*   **State Management:** BLoC (Business Logic Component). Used to strictly separate UI from business logic.
*   **Backend & Database:** Supabase (PostgreSQL, Auth, Realtime).
*   **Local Storage:** Drift (SQLite) - high performance for "Offline-First" caching of progression, lives, and settings.
*   **Monetization (Ads):** Google Mobile Ads (AdMob).
*   **Monetization (IAP):** RevenueCat for secure in-app purchases.

## 3. User Interface (UI) - Home Screen
The main hub for the player:
*   **Top Left:** Profile icon opening a modal with player stats and friends. Supports real-time nickname updates.
*   **Top Center:** Lives Indicator (e.g., ❤️ 3/5) with a countdown if lives are recharging.
*   **Top Right:** Settings Button (cog icon). Contains a **Hard Reset** debug tool for developers.
*   **Bottom Center:** Main "PLAY" action button, displaying current level and difficulty.
*   **Progression Bar:** Displays levels completed in the current world and remaining levels until the next world.

### 3.1. Notification System Rules
*   **Positioning:** All in-game notifications (success, error, info) MUST appear at the **top** of the application.
*   **Layering:** Notifications reside on the **foremost layer** (Overlay), ensuring they stay above any open dialog or modal.

## 4. Core Game Mechanics
### 4.1. Life System and Timer
*   Each level is timed.
*   **Failure:** If the timer expires, the player loses one life.
*   **Security:** Server-side validation for timers and life recharge.

### 4.2. Progression & Synchronization
*   **Hybrid Storage**: Data is saved to **Drift** (local) for speed and **Supabase** (cloud) for persistence across devices.
*   **Anti-Downgrade**: Progression only increases if the player completes a level higher than their current record.
*   **Background Pre-generation**: When a player reaches or completes level N, the app automatically verifies/generates levels N+1 and N+2 on the server.

## 5. Game Modes
### 5.1. Story Mode (Main Progression)
*   **World 1: "Zip" Mini-game.**
    *   **Objective:** Connect numbers in sequence (1, 2, 3...) and fill every cell in a 6x6 grid.
    *   **Victory Recap**: Overhauled screen showing:
        *   **Global Stats**: Total completions, Average Time, and World Record (with the pseudo of the record holder).
        *   **Global Rank**: Percentile badge (e.g., "TOP 10%") if the player is in the top 50%.
        *   **Friend Ranking**: A mini-leaderboard showing the friend immediately above the user and the one immediately below.
        *   **Full Rankings**: Direct access to a complete leaderboard of all friends for that level.

### 5.2. Daily Challenge & Series Mode
A competitive mode where all players compete on identical levels.

#### 5.2.1. Daily Single Level
*   One unique level per day per world. No time limit.
*   Automatic popup on first connection. UI button for subsequent access.
*   Recap shows comparison with friends' times.

#### 5.2.2. Daily Series (Série Journalière)
*   A consecutve chain of 3 levels offered after the Daily Single Level.
*   Final score is the cumulative time.
*   Persistence: Players can resume the series later in the same day.

## 6. Social Features
### 6.1. Friend System
*   **Add Friend**: Search by pseudo (prevents self-adding and duplicates).
*   **Requests**: Incoming requests are notified via a **Real-Time Red Badge** on the Home Screen.
*   **Mutual Removal**: Deleting a friend removes the link for both players instantly.
*   **Real-Time Sync**: Uses Supabase Realtime to update lists and badges without manual refresh.

## 7. Development Tools
*   **ADMIN.md**: Strategy for an external Flutter Web dashboard (hosted on Vercel) to manage users and statistics.
*   **Hard Reset**: Wipe local database, delete Supabase records for the user, and auto-exit app for fresh testing.
