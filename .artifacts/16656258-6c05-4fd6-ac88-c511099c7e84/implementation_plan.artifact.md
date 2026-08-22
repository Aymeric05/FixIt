# Implementation Plan: Flexible Validation & Wall Obstacles

Improve the "Zip" game by making validation more flexible (accepting any valid Hamiltonian path that respects hint order) and adding "walls" to guide players and create more unique puzzles.

## Proposed Changes

### 1. Logic & State Management

#### [MODIFY] [game_state.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/bloc/game_state.dart)
- Add `walls`: A collection of pairs of adjacent cells between which a wall exists.
- A wall between `Cell A` and `Cell B` prevents the user from moving directly from A to B.

#### [MODIFY] [game_bloc.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/bloc/game_bloc.dart)
- **Flexible Validation**: Update `_validatePath` to check if hints are visited in the correct sequence (1 -> 2 -> 3...), regardless of the exact step count between them.
- **Wall Generation**:
    - After generating the Hamiltonian path, randomly select pairs of adjacent cells that are **not** consecutive in the path and place a wall between them.
    - This increases difficulty and forces the player into the intended path.
- **Enforce Walls**: In `_onSelectCell`, check if a wall exists between the `last` cell and the `tapped` cell. If so, ignore the move.

### 2. Interaction & UI

#### [MODIFY] [game_page.dart](file:///C:/Users/FlowUP/StudioProjects/FixIt/lib/features/game/presentation/pages/game_page.dart)
- **Wall Rendering**:
    - Update the `GridView` cell rendering to display a thick black border on the edge(s) where a wall exists.
    - This will match the visual style of the provided reference image.

## Verification Plan

### Manual Verification
- **Validation**: Find a path that fills the grid and respects hint order but differs from the generator's path. Verify it now triggers a win.
- **Walls**: Start a game and verify that thick black lines appear between some cells.
- **Wall Interaction**: Try to drag your finger across a wall. Verify the path does not cross it.
- **Solvability**: Ensure that even with walls, a valid path (the one generated initially) is always possible.
