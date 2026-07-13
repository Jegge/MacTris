# Changelog

## [1.10.0] - 2026-07-13

### Added
- Added a game over animation

### Changed
- Binding a key can now be aborted with ESC
- Lots of refactorings and unit tests

### Fixed
- Fixed a bug where a keybinding would not work correctly
- Fixed a bug where resuming the game from the pause menu could result in a hard drop

## [1.9.0] - 2026-07-10

### Added
- New, brighter color scheme is available
- Hard Drop option (can be disabled)
- Animations for score and drops (can be disabled)

### Fixed
- Wall kick bug
- Tetromino getting stuck in the top corners
- Wrong controller keybinding display
- Automatically pauses when the app loses focus

## [1.8.0] - 2026-07-08

### Added
- Option to enable wall kick
- Menu entry to download the latest version if available

### Fixed
- Some code quality issues
- Improved the settings screen

## [1.7.0] - 2026-07-07

### Added
- Some unit tests

### Fixed
- Some code quality issues

## [1.6.0] - 2025-12-21

### Added
- Improved NES style RNG
- Improved debugging
- Added an even faster autoshift (5 initial frames, then 1 frame)

### Changed
- Changed text in settings menu to clarify the meaning

## [1.5.0] - 2025-12-13

### Added
- Setting to change the tetromino appearance

## [1.4.0] - 2025-12-13

### Fixed
- Bug with hiscores getting lost

## [1.3.0] - 2025-09-29

### Added
- Updated for macOS Tahoe 26

## [1.2.0] - 2024-08-12

### Added
- Release is notarized by Apple

### Changed
- Spawn time delayed by current stack height

## [1.1.1] - 2024-01-13

### Added
- Selectable random generator:
  - Classic: NES style
  - Modern: 7 Bag

- Selectable auto shift:
  - Classic: 16 initial frames, then 6 frames
  - Modern: 8 initial frames, then 6 frames
  - Fast: 6 initial frames, then 3 frames

### Fixed
- Hiscores now properly saved on older macOS versions

## [1.0.0] - 2024-01-09

### Added
- Initial release of MacTris
