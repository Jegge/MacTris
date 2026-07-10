# MacTris

A simple Tetris clone using SpriteKit

## Acknowledgements

### Tetriminos

* Вадим Герасимов - https://en.wikipedia.org/wiki/Vadim_Gerasimov
* Алексей Пажитнов - https://en.wikipedia.org/wiki/Alexey_Pajitnov

### Music

* Коробушка rendered from https://en.wikipedia.org/wiki/File:Korobeiniki.mid using GarageBand

### Sound FX

* Pixabay - https://pixabay.com/sound-effects

### Font

* Silver by Poppy Works - https://poppyworks.itch.io/silver

## Known Issues

### Controller Support

Disable Launchpad on select button:
 
    defaults write com.apple.GameController bluetoothPrefsMenuLongPressAction -integer 0
    defaults write com.apple.GameController bluetoothPrefsShareLongPressSystemGestureMode -integer -1

## Build

1. The first build might fail due to generation of the file Secrets.generated.swift.
2. To supply a secret for archive builds, copy the file Secrets.xcconfig to Secrets.install.xcconfig and change it's content.

## Ideas

* Floor kick option
* Hold piece mechanic

### DMG

1. brew install create-dmg
2. copy MacTris.app into a source directory
3. create-dmg --volname "MacTris Installer" --volicon source/MacTris.app/Contents/Resources/AppIcon.icns --background InstallerBackground.svg --window-pos 200 120 --window-size 840 400 --icon-size 100 --icon MacTris.app 200 160 --hide-extension MacTris.app --app-drop-link 640 155 "MacTris-Installer.dmg" source/

## Resources

The following sites proved to be invaluable resources:

* https://meatfighter.com/nintendotetrisai/
* https://tetrissuomi.wordpress.com/wp-content/uploads/2020/04/nes_tetris_rng.pdf

