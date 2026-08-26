# Implementation Plan: Social Tab UI Refinement

Refine the "Social" tab to clearly display the player's username with an explicit edit button, improving visibility and usability of the identity management feature.

## Proposed Changes

### UI & Interaction

#### [MODIFY] [social_dialog.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/home/presentation/widgets/social_dialog.dart)
- Introduce a `bool _isEditing` state variable.
- Wrap the username section in a `BlocBuilder<AuthBloc, AuthState>` to ensure it stays in sync with the global profile.
- **Display Mode**: Show the username as a bold `Text` widget with a small "pencil" `IconButton` next to it.
- **Edit Mode**: Switch to the `TextField` for input, with "confirm" (check) and "cancel" (close) icons.
- Maintain the current "FIND FRIENDS" section at the bottom as requested.

## Verification Plan

### Manual Verification
- Open the **Social** tab. Verify that you see your `Guest#XXXX` name as static text.
- Click the edit button. Verify that it switches to an input field.
- Confirm a change and verify that it updates correctly in the UI.
- Cancel a change and verify that the original name is restored.
