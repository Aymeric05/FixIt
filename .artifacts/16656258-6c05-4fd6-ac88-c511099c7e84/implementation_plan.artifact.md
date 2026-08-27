# Implementation Plan: Comprehensive Friend System

Add a social layer allowing players to manage friends, search for new ones, and handle incoming friend requests with real-time badges.

## User Review Required

> [!IMPORTANT]
> **Action sur Supabase (SQL Editor)** : Tu dois exécuter ce script pour créer les tables d'amis et les règles de sécurité associées.
> ```sql
> -- 1. Table des amis
> CREATE TABLE public.friends (
>     player_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
>     friend_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
>     created_at timestamptz DEFAULT now(),
>     PRIMARY KEY (player_id, friend_id)
> );
> ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
> CREATE POLICY "Users can view their own friends." ON public.friends FOR SELECT USING (auth.uid() = player_id);
> CREATE POLICY "Users can add friends." ON public.friends FOR INSERT WITH CHECK (auth.uid() = player_id);
> CREATE POLICY "Users can remove friends." ON public.friends FOR DELETE USING (auth.uid() = player_id);
>
> -- 2. Table des demandes d'amis
> CREATE TABLE public.friend_requests (
>     id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
>     sender_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
>     receiver_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
>     status text DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
>     created_at timestamptz DEFAULT now(),
>     UNIQUE(sender_id, receiver_id)
> );
> ALTER TABLE public.friend_requests ENABLE ROW LEVEL SECURITY;
> CREATE POLICY "Users can see requests they sent or received." ON public.friend_requests FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
> CREATE POLICY "Users can send requests." ON public.friend_requests FOR INSERT WITH CHECK (auth.uid() = sender_id);
> CREATE POLICY "Receivers can update request status." ON public.friend_requests FOR UPDATE USING (auth.uid() = receiver_id);
> ```

## Proposed Changes

### 1. Database Update (Drift)
#### [MODIFY] [app_database.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/core/database/app_database.dart)
- Upgrade to Schema **Version 3**.
- Add `Friends` table: `playerId`, `friendId`, `friendUsername`.
- Add `FriendRequests` table: `id`, `senderId`, `receiverId`, `senderUsername`, `createdAt`.

### 2. Logic Layer (Repository & Bloc)
#### [NEW] `lib/core/repositories/friends_repository.dart`
- `fetchFriends()`: Get list of friends from Supabase.
- `searchPlayer(query)`: Find players by nickname.
- `sendFriendRequest(targetId)`: Send a request (checks for duplicates first).
- `handleFriendRequest(requestId, accept)`: Accept/Reject logic.
- `removeFriend(friendId)`: Delete from `friends` table.

#### [NEW] `lib/features/friends/presentation/bloc/friends_bloc.dart`
- State: `friendsList`, `pendingRequests` (list), `searchResults`, `isLoading`.
- Events: `LoadFriends`, `SearchPlayer`, `SendRequest`, `AcceptRequest`, `RejectRequest`, `RemoveFriend`.

### 3. UI Redesign
#### [MODIFY] [social_dialog.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/widgets/social_dialog.dart)
- Replace search bar with a **Friend List** view.
- Add "Add Friend" (➕) and "Requests" (📩) icons at the top.
- Add a **Red Badge** on the "Requests" icon showing the count of pending requests.
- Add a "X" button on each friend row to remove them.

#### [NEW] `lib/features/friends/presentation/widgets/add_friend_dialog.dart`
- Search bar for nicknames.
- List of results with a "Add" button.
- Prevent adding if already friends or request pending.

#### [NEW] `lib/features/friends/presentation/widgets/friend_requests_dialog.dart`
- List of incoming requests.
- Green (Accept) and Red (Reject) buttons for each.

## Verification Plan

### Manual Verification
1. **Search**: Search for "chocolat" (or any existing user). Verify result appears.
2. **Request**: Send a request. Verify Supabase `friend_requests` has the row.
3. **Badge**: On the receiver's account, verify the red bubble shows "1".
4. **Accept**: Click Green button. Verify both players now have each other in their friend list.
5. **Remove**: Click "X" on a friend. Verify they disappear from both UI and database.
