# Implementation Plan: World 1 Map (Prairie Theme)

Create the foundational map for World 1 of a Candy Crush-inspired puzzle game. The theme will be "Prairie" (green), featuring a playful and colorful aesthetic.

## Proposed Changes

### Configuration

#### [MODIFY] [pubspec.yaml](file:///C:/Users/FlowUP/StudioProjects/FixIt/pubspec.yaml)
- Add `google_fonts` dependency for playful typography.

### UI & Styling

#### [MODIFY] [main.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/main.dart)
- Set up the main app structure with a custom `ThemeData` (green primary color, playful fonts).
- Implement `WorldMapScreen` as the home screen.
- Create a `PrairieBackground` widget using gradients and decorative elements (like simple clouds or grass patches).
- Implement a `LevelPath` widget (a curved path representing progress).
- Create a `LevelButton` widget:
    - Highly stylized (shadows, gradients, rounded).
    - Represents Level 1.
    - Animation on press for an "addictive" feel.

### Assets & Resources
- Use `GoogleFonts.bungee` or `GoogleFonts.fredoka` for a rounded, playful look.
- Define a color palette:
    - Background: `Colors.green[300]`, `Colors.lightGreen[200]`.
    - Path: `Colors.brown[300]` or a darker green.
    - Level Button: Vibrant pink or orange to stand out against the green.

## Verification Plan

### Manual Verification
- Run the app and verify the visual style matches the "Candy Crush" aesthetic.
- Ensure the "World 1" theme is clearly "Prairie/Green".
- Check that the Level 1 button is prominent and follows the path.
- Verify that fonts are playful and rounded.
