//
//  Settings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit

class Settings: SKScene {

    private struct Item {
        public static let displayMode = "DisplayMode"
        public static let musicVolume = "MusicVolume"
        public static let fxVolume = "FxVolume"
        public static let moveLeft = "MoveLeft"
        public static let moveRight = "MoveRight"
        public static let rotateLeft = "RotateLeft"
        public static let rotateRight = "RotateRight"
        public static let softDrop = "SoftDrop"
        public static let back = "Back"
    }

    private var menuItems: [String] = []
    private var selection: Int = -1 {
        didSet {
            self.update()
        }
    }

    private var rebindItem: String?

    private func update () {
        for (index, item) in menuItems.enumerated() {
            if let bullet = self.childNode(withName: "menu" + item) as? SKLabelNode {
                bullet.isHidden = index != self.selection
                bullet.fontColor = index == self.selection ? NSColor(named: "MenuHilite") : NSColor(named: "MenuDefault")
            }

            if let label = self.childNode(withName: "label" + item) as? SKLabelNode {
                label.fontColor = index == self.selection ? NSColor(named: "MenuHilite") : NSColor(named: "MenuDefault")
            }

            if let value = self.childNode(withName: "value" + item) as? SKLabelNode {
                value.fontColor = index == self.selection ? NSColor(named: "MenuHilite") : NSColor(named: "MenuDefault")
                if let text = self.value(for: item) {
                    value.text = text
                }
            }
        }
    }

    private func value (for item: String) -> String? {
        switch item {
        case Item.displayMode:
            return UserDefaults.standard.fullscreen ? "fullscreen" : "windowed"

        case Item.musicVolume:
            return AudioPlayer.shared.musicVolume == 0 ? "off" : "\(AudioPlayer.shared.musicVolume)%"

        case Item.fxVolume:
            return AudioPlayer.shared.fxVolume == 0 ? "off" : "\(AudioPlayer.shared.fxVolume)%"

        case Item.moveLeft:
            return self.rebindItem == Item.moveLeft ? "" : KeyCode(rawValue: KeyBindings.moveLeft)?.description ?? "⍰"

        case Item.moveRight:
            return self.rebindItem == Item.moveRight ? "" : KeyCode(rawValue: KeyBindings.moveRight)?.description ?? "⍰"

        case Item.rotateLeft:
            return self.rebindItem == Item.rotateLeft ? "": KeyCode(rawValue: KeyBindings.rotateLeft)?.description ?? "⍰"

        case Item.rotateRight:
            return self.rebindItem == Item.rotateRight ? "": KeyCode(rawValue: KeyBindings.rotateRight)?.description ?? "⍰"

        case Item.softDrop:
            return self.rebindItem == Item.softDrop ? "" : KeyCode(rawValue: KeyBindings.softDrop)?.description ?? "⍰"

        default:
            return nil
        }
    }

    private func increase (item: String) {
        switch item {
        case Item.musicVolume:
            AudioPlayer.shared.musicVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            UserDefaults.standard.musicVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            AudioPlayer.playFxPositive()

        case Item.fxVolume:
            AudioPlayer.shared.fxVolume = min(100, AudioPlayer.shared.fxVolume + 2)
            UserDefaults.standard.fxVolume = min(100, AudioPlayer.shared.fxVolume + 2)
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func decrease (item: String) {
        switch item {
        case Item.musicVolume:
            AudioPlayer.shared.musicVolume = max(0, AudioPlayer.shared.musicVolume - 2)
            UserDefaults.standard.musicVolume = max(0, AudioPlayer.shared.musicVolume - 2)
            AudioPlayer.playFxPositive()

        case Item.fxVolume:
            AudioPlayer.shared.fxVolume = max(0, AudioPlayer.shared.fxVolume - 2)
            UserDefaults.standard.fxVolume = max(0, AudioPlayer.shared.fxVolume - 2)
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func select (item: String) {
        switch item {
        case Item.displayMode:
            UserDefaults.standard.fullscreen = !UserDefaults.standard.fullscreen
            self.view?.window?.toggleFullScreen(nil)
            AudioPlayer.playFxPositive()

        case Item.musicVolume:
            let volume = ((AudioPlayer.shared.musicVolume / 10) * 10) + 10
            AudioPlayer.shared.musicVolume = volume > 100 ? 0 : volume
            UserDefaults.standard.musicVolume = volume > 100 ? 0 : volume
            AudioPlayer.playFxPositive()

        case Item.fxVolume:
            let volume = ((AudioPlayer.shared.fxVolume / 10) * 10) + 10
            AudioPlayer.shared.fxVolume = volume > 100 ? 0 : volume
            UserDefaults.standard.fxVolume = volume > 100 ? 0 : volume
            AudioPlayer.playFxPositive()

        case Item.moveLeft:
            self.rebindItem = item
            AudioPlayer.playFxPositive()

        case Item.moveRight:
            self.rebindItem = item
            AudioPlayer.playFxPositive()

        case Item.rotateLeft:
            self.rebindItem = item
            AudioPlayer.playFxPositive()

        case Item.rotateRight:
            self.rebindItem = item
            AudioPlayer.playFxPositive()

        case Item.softDrop:
            self.rebindItem = item
            AudioPlayer.playFxPositive()

        case Item.back:
            AudioPlayer.playFxPositive()
            if let newScene = SKScene(fileNamed: "Menu") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }

        default:
            print("Unknown menu option \(item)")
        }
    }

    private func rebind(item: String, keyCode: UInt16) {
        if keyCode == KeyBindings.quit {
            AudioPlayer.playFxNegative()
            return
        }

        switch item {
        case Item.moveLeft:
            KeyBindings.moveLeft = keyCode
            UserDefaults.standard.keyMoveLeft = keyCode
            AudioPlayer.playFxPositive()

        case Item.moveRight:
            KeyBindings.moveRight = keyCode
            UserDefaults.standard.keyMoveRight = keyCode
            AudioPlayer.playFxPositive()

        case Item.rotateLeft:
            KeyBindings.rotateLeft = keyCode
            UserDefaults.standard.keyRotateLeft = keyCode
            AudioPlayer.playFxPositive()

        case Item.rotateRight:
            KeyBindings.rotateRight = keyCode
            UserDefaults.standard.keyRotateRight = keyCode
            AudioPlayer.playFxPositive()

        case Item.softDrop:
            KeyBindings.softDrop = keyCode
            UserDefaults.standard.keySoftDrop = keyCode
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    override func didMove(to view: SKView) {
        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0
    }

    override func keyDown(with event: NSEvent) {

        if let item = self.rebindItem {
            self.rebind(item: item, keyCode: event.keyCode)
            self.rebindItem = nil
            self.update()
            return
        }

        switch event.keyCode {
        case KeyBindings.up:
            AudioPlayer.playFxSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1
            self.update()

        case KeyBindings.down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0
            self.update()

        case KeyBindings.select:
            self.select(item: self.menuItems[self.selection])
            self.update()

        case KeyBindings.enter:
            self.select(item: self.menuItems[self.selection])
            self.update()

        case KeyBindings.left:
            self.decrease(item: self.menuItems[self.selection])
            self.update()

        case KeyBindings.right:
            self.increase(item: self.menuItems[self.selection])
            self.update()

        case KeyBindings.quit:
            self.select(item: Item.back)

        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
}
