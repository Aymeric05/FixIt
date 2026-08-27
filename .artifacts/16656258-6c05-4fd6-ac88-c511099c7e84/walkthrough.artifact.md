# Walkthrough: Comprehensive Friend System

I have implemented a full-featured social system that allows players to find friends, manage requests, and maintain their friend list with real-time updates.

## Key Features

### 👥 Friend Management
- **Friend List**: The **Social** dialog now displays your current friends with their pseudos and a quick "X" button to remove them.
- **Search & Add**: A new **Add Friend** interface allows you to search for any player by their pseudo and send them a request instantly.
- **Prevention**: The system prevents duplicate friend requests if one is already pending.
- **Self-Add Protection**: Double security layer prevents adding yourself as a friend (filtered from search results + explicit check in the repository).

### 📩 Friend Requests & Notifications
- **Request Center**: A dedicated view lists all your incoming friend requests.
- **Accept/Reject**: Simple Green (Accept) and Red (Reject) buttons to manage your social circle.
- **Real-Time Badge**: Added a **dynamic red bubble** on the Social button in the main menu that shows the number of pending requests. It disappears automatically when all requests are handled.

### ☁️ Cloud & Local Synchronization
- **Hybrid Storage**: Friends and requests are synced between **Supabase** (for global consistency) and **Drift** (for instant offline access).
- **Auto-Refresh**: The friend list and badges update automatically when you log in or complete an action.

## Changes Made

### Database & Logic
- **`AppDatabase`**: Upgraded to Version 3 with new `Friends` and `FriendRequests` tables.
- **`FriendsRepository`**: Handles all Supabase joins and Drift caching logic.
- **`FriendsBloc`**: Manages the complex state of search results, incoming requests, and the friend list.

### UI Components
- **`SocialDialog`**: Redesigned to act as the main social hub.
- **`AddFriendDialog`**: New searchable interface for player discovery.
- **`FriendRequestsDialog`**: New interface for handling incoming invitations.
- **`TopNavBar`**: Updated the Social button with a notification badge.

## Verification

1. **Badge Test**: Send a friend request from another account. Verify the red bubble appears on the main screen.
2. **Search Test**: Open **Social** > **Add**, type a known pseudo. Verify the player appears and you can click **ADD**.
3. **Acceptance Test**: Open **Social** > **Requests**, click the **Green Check**. Verify the player now appears in your **MY FRIENDS** list.
4. **Removal Test**: Click the **X** on a friend. Verify they are removed from both your list and your friend's list.
