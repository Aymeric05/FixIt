# Game Project Context & Requirements

## 1. Project Overview
This project is a mobile puzzle game (inspired by the progression model of Candy Crush). It is developed using **Flutter** and **Dart**, with the goal of multi-platform deployment on the **Google Play Store** and **Apple App Store**.

**IMPORTANT: The entire application, including UI, code documentation, and assets, must be in English.**

The application integrates level progression mechanics, a time-limited life system, social features (friends and daily leaderboards), and hybrid monetization.

## 2. Global Technical Stack
*   **Frontend:** Flutter / Dart
*   **State Management:** BLoC (Business Logic Component). Used to strictly separate UI from business logic, functioning similarly to an MVVM pattern.
*   **Backend & Database:** Supabase (PostgreSQL, Auth, Edge Functions).
*   **Local Storage:** Drift (SQLite) - high performance for caching progression, lives, and offline settings, fully compatible with Android SDK 34+.
*   **Monetization (Ads):** Google Mobile Ads (AdMob) integrated standalone.
*   **Monetization (IAP):** RevenueCat for secure in-app purchases.

## 3. User Interface (UI) - Home Screen
The main hub for the player:
*   **Top Left:** Profile icon opening a modal with player stats and friends.
*   **Top Center:** Lives Indicator (e.g., ❤️ 3/5) with a countdown if lives are recharging.
*   **Top Right:** Settings Button (cog icon).
*   **Bottom Center:** Main "PLAY" action button, displaying current level and difficulty (Easy, Medium, Hard).

## 4. Core Game Mechanics
### 4.1. Life System and Timer
*   Each level is timed.
*   **Failure:** If the timer expires, the player loses one life and must restart.
*   **Blocking:** If the life counter reaches 0, level access is blocked until recharge or purchase.
*   **Security:** Server-side validation (Supabase) for timers and life recharge to prevent local clock cheating.

### 4.2. Hints and Skips
*   Acquisition via real money (RevenueCat) or rewarded ads (AdMob).

## 5. Game Modes
### 5.1. Story Mode (Main Progression)
*   Progression divided into **Worlds**. 1 World = 1 specific mini-game type.
*   **World 1: "Zip" Mini-game.**
    *   **Grid Size:** 6x6.
    *   **Objective:** Connect numbers in sequence (1, 2, 3...) and fill every cell in the grid.
    *   **Difficulty:**
        *   **Easy:** 12 numbers to connect, 5:00 timer.
        *   **Medium:** 8 numbers to connect, 4:00 timer.
        *   **Hard:** 7 numbers to connect, 3:00 timer.

### 5.2. Daily Challenge Mode (Social)
*   A "Daily Game" generated for each unlocked World, identical for all players.

## 6. Architecture & Development Logic
### 6.1. Abstract Interface
Base abstract classes for `MinigameEngine` or generic `MinigameBloc` to define contracts: `initializeGame()`, `useHint()`, `triggerTimeout()`, `onWin()`.

### 6.2. Procedural Generation
Levels generated from a mathematical *seed* and difficulty parameters. For Daily Challenges, the *seed* is the current date (e.g., `20260822`).

### 6.3. Timing Management
Managed with native Flutter `Tickers` or dedicated Streams for high performance (60 fps).
