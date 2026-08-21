# Implementation Plan: World 1 UI Enhancements

Update the game UI to use a custom background image and add new interactive elements (Settings and Daily Game).

## Proposed Changes

### Assets & Configuration

#### [MODIFY] [pubspec.yaml](file:///C:/Users/FlowUP/StudioProjects/FixIt/pubspec.yaml)
- Add `monde1_background.png` to the assets section.

### UI & Styling

#### [MODIFY] [main.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/main.dart)
- Replace the procedural `PrairieBackground` with `Image.asset('monde1_background.png')`.
- Implement a `SideMenu` or `TopActionButtons` layout:
    - **Settings Button**: Top-right corner, stylized with a cogwheel icon.
    - **Daily Game Button**: Positioned vertically below the settings button, with a unique "LinkedIn-style" label/badge.
- Refine the **Level 1 Button**:
    - Increase size or add decorative border.
    - Ensure it's visually distinct from the new background.
- Adjust the "MONDE 1" title positioning to ensure readability over the new background image.

## Verification Plan

### Manual Verification
- Run the app and verify the background image loads correctly and covers the screen.
- Test the "Settings" button (it should show a placeholder action/toast).
- Test the "Daily Game" button (it should show a placeholder action/toast).
- Verify the overall layout on different screen sizes to ensure buttons don't overlap.
