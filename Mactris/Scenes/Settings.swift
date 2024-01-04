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

    private var menuItems: [String] = []
    private var selection: Int = -1 {
        didSet {
            self.update()
        }
    }

    private var rebind: String?

    private func update () {
        for (index, item) in menuItems.enumerated() {
            guard let bullet = self.childNode(withName: "menu" + item) as? SKLabelNode,
                  let label = self.childNode(withName: "label" + item) as? SKLabelNode,
                  let value = self.childNode(withName: "value" + item) as? SKLabelNode
            else {
                continue
            }

            if index == self.selection {
                bullet.isHidden = false
                bullet.fontColor = NSColor(named: "MenuHilite")
                label.fontColor = NSColor(named: "MenuHilite")
                value.fontColor = NSColor(named: "MenuHilite")
            } else {
                bullet.isHidden = true
                bullet.fontColor = NSColor(named: "MenuDefault")
                label.fontColor = NSColor(named: "MenuDefault")
                value.fontColor = NSColor(named: "MenuDefault")
            }

            if let text = self.value(for: item) {
                value.text = text
            }
        }
    }

    private func value (for item: String) -> String? {
        switch item {
        case "DisplayMode":
            return (self.view?.isInFullScreenMode ?? false) ? "fullscreen" : "windowed"

        case "MusicVolume":
            return AudioPlayer.shared.musicVolume == 0 ? "off" : "\(AudioPlayer.shared.musicVolume)%"

        case "FxVolume":
            return AudioPlayer.shared.fxVolume == 0 ? "off" : "\(AudioPlayer.shared.fxVolume)%"

        case "MoveLeft":
            return self.rebind == "MoveLeft" ? "" : KeyCode(rawValue: KeyBindings.moveLeft)?.description ?? "⍰"

        case "MoveRight":
            return self.rebind == "MoveRight" ? "" : KeyCode(rawValue: KeyBindings.moveRight)?.description ?? "⍰"

        case "RotateLeft":
            return self.rebind == "RotateLeft" ? "" : KeyCode(rawValue: KeyBindings.rotateLeft)?.description ?? "⍰"

        case "RotateRight":
            return self.rebind == "RotateRight" ? "" : KeyCode(rawValue: KeyBindings.rotateRight)?.description ?? "⍰"

        case "SoftDrop":
            return self.rebind == "SoftDrop" ? "" : KeyCode(rawValue: KeyBindings.softDrop)?.description ?? "⍰"

        default:
            return nil
        }
    }

    private func increase (item: String) {
        switch item {
        case "MusicVolume":
            AudioPlayer.shared.musicVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            UserDefaults.standard.musicVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            AudioPlayer.playFxPositive()

        case "FxVolume":
            AudioPlayer.shared.fxVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            UserDefaults.standard.fxVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func decrease (item: String) {
        switch item {
        case "MusicVolume":
            AudioPlayer.shared.musicVolume = max(0, AudioPlayer.shared.musicVolume - 2)
            UserDefaults.standard.musicVolume = max(0, AudioPlayer.shared.musicVolume - 2)
            AudioPlayer.playFxPositive()

        case "FxVolume":
            AudioPlayer.shared.fxVolume = max(0, AudioPlayer.shared.fxVolume - 2)
            UserDefaults.standard.fxVolume = max(0, AudioPlayer.shared.fxVolume - 2)
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func select (item: String) {
        switch item {
        case "DisplayMode":
            if self.view?.isInFullScreenMode ?? false {
                self.view?.exitFullScreenMode()
                UserDefaults.standard.fullscreen = false
            } else {
                self.view?.enterFullScreenMode(NSScreen.main!)
                UserDefaults.standard.fullscreen = true
            }
            AudioPlayer.playFxPositive()

        case "MusicVolume":
            let volume = ((AudioPlayer.shared.musicVolume / 10) * 10) + 10
            AudioPlayer.shared.musicVolume = volume > 100 ? 0 : volume
            UserDefaults.standard.musicVolume = volume > 100 ? 0 : volume
            AudioPlayer.playFxPositive()

        case "FxVolume":
            let volume = ((AudioPlayer.shared.fxVolume / 10) * 10) + 10
            AudioPlayer.shared.fxVolume = volume > 100 ? 0 : volume
            UserDefaults.standard.fxVolume = volume > 100 ? 0 : volume
            AudioPlayer.playFxPositive()

        case "MoveLeft":
            self.rebind = "MoveLeft"
            AudioPlayer.playFxPositive()

        case "MoveRight":
            self.rebind = "MoveRight"
            AudioPlayer.playFxPositive()

        case "RotateLeft":
            self.rebind = "RotateLeft"
            AudioPlayer.playFxPositive()

        case "RotateRight":
            self.rebind = "RotateRight"
            AudioPlayer.playFxPositive()

        case "SoftDrop":
            self.rebind = "SoftDrop"
            AudioPlayer.playFxPositive()

        default:
            print("Unknown menu option \(item)")
            AudioPlayer.playFxNegative()
        }
    }

    override func didMove(to view: SKView) {
        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0
    }

    override func keyDown(with event: NSEvent) {
        if let rebind = self.rebind {

            if event.keyCode == KeyBindings.quit {
                AudioPlayer.playFxNegative()
                return
            }

            switch rebind {
            case "MoveLeft":
                KeyBindings.moveLeft = event.keyCode
                UserDefaults.standard.keyMoveLeft = event.keyCode
                AudioPlayer.playFxPositive()

            case "MoveRight":
                KeyBindings.moveRight = event.keyCode
                UserDefaults.standard.keyMoveRight = event.keyCode
                AudioPlayer.playFxPositive()

            case "RotateLeft":
                KeyBindings.rotateLeft = event.keyCode
                UserDefaults.standard.keyRotateLeft = event.keyCode
                AudioPlayer.playFxPositive()

            case "RotateRight":
                KeyBindings.rotateRight = event.keyCode
                UserDefaults.standard.keyRotateRight = event.keyCode
                AudioPlayer.playFxPositive()

            case "SoftDrop":
                KeyBindings.softDrop = event.keyCode
                UserDefaults.standard.keySoftDrop = event.keyCode
                AudioPlayer.playFxPositive()

            default:
                AudioPlayer.playFxNegative()
            }

            self.rebind = nil
            self.update()

            return
        }

        switch event.keyCode {
        case KeyBindings.up:
            AudioPlayer.playFxSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.selection
            self.update()

        case KeyBindings.down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : self.selection
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
            AudioPlayer.playFxPositive()
            if let newScene = SKScene(fileNamed: "Menu") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }

        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
}
