//
//  Settings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit
import GameController

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

    private var rebindEvent: Input?

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

            if let controller = self.childNode(withName: "controller" + item) as? SKLabelNode {
                controller.fontColor = index == self.selection ? NSColor(named: "MenuHilite") : NSColor(named: "MenuDefault")
                controller.isHidden = GCController.controllers().isEmpty
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
            return self.rebindEvent == .moveLeft ? "" : InputMapper.shared.describe(keyboardEvent: .moveLeft)

        case Item.moveRight:
            return self.rebindEvent == .moveRight ? "" : InputMapper.shared.describe(keyboardEvent: .moveRight)

        case Item.rotateLeft:
            return self.rebindEvent == .rotateLeft ? "": InputMapper.shared.describe(keyboardEvent: .rotateLeft)

        case Item.rotateRight:
            return self.rebindEvent == .rotateRight ? "": InputMapper.shared.describe(keyboardEvent: .rotateRight)

        case Item.softDrop:
            return self.rebindEvent == .softDrop ? "" : InputMapper.shared.describe(keyboardEvent: .softDrop)

        default:
            return nil
        }
    }

    private func increase (item: String) {
        switch item {
        case Item.displayMode:
            UserDefaults.standard.fullscreen = !UserDefaults.standard.fullscreen
            self.view?.window?.toggleFullScreen(nil)
            AudioPlayer.playFxPositive()

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
        case Item.displayMode:
            UserDefaults.standard.fullscreen = !UserDefaults.standard.fullscreen
            self.view?.window?.toggleFullScreen(nil)
            AudioPlayer.playFxPositive()

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
            self.rebindEvent = .moveLeft
            AudioPlayer.playFxPositive()

        case Item.moveRight:
            self.rebindEvent = .moveRight
            AudioPlayer.playFxPositive()

        case Item.rotateLeft:
            self.rebindEvent = .rotateLeft
            AudioPlayer.playFxPositive()

        case Item.rotateRight:
            self.rebindEvent = .rotateRight
            AudioPlayer.playFxPositive()

        case Item.softDrop:
            self.rebindEvent = .softDrop
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

    override func didMove(to view: SKView) {
        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0
    }

    override func keyDown (with event: NSEvent) {
        if let rebindEvent = self.rebindEvent {

            if InputMapper.shared.translate(nsEvent: event).contains(where: { $0.id == Input.menu }) {
                AudioPlayer.playFxNegative()
                return
            }

            if InputMapper.shared.canBind(event: rebindEvent) {
                InputMapper.shared.bind(keyCode: event.keyCode, event: rebindEvent)
                AudioPlayer.playFxPositive()
            } else {
                AudioPlayer.playFxNegative()
            }

            self.rebindEvent = nil
            self.update()
        } else {
            for inputEvent in InputMapper.shared.translate(nsEvent: event) {
                self.inputDown(event: inputEvent.id)
            }
        }
    }
}

extension Settings: InputEventResponder {
    func inputDown(event: Input) {
        switch event {
        case Input.up:
            AudioPlayer.playFxSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1
            self.update()

        case Input.down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0
            self.update()

        case Input.select:
            self.select(item: self.menuItems[self.selection])
            self.update()

        case Input.left:
            self.decrease(item: self.menuItems[self.selection])
            self.update()

        case Input.right:
            self.increase(item: self.menuItems[self.selection])
            self.update()

        case Input.menu:
            self.select(item: Item.back)

        default:
            print("Unhandled input event: \(event)")
        }
    }

    func inputUp(event: Input) {
    }
}
