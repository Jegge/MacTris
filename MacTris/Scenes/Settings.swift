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

class Settings: SceneBase {

    private struct Item {
        public static let displayMode = "DisplayMode"
        public static let musicVolume = "MusicVolume"
        public static let fxVolume = "FxVolume"
        public static let shiftLeft = "ShiftLeft"
        public static let shiftRight = "ShiftRight"
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

    private var rebindId: Input?
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

            if let controller = self.childNode(withName: "controller" + item) as? SKLabelNode {
                controller.fontColor = index == self.selection ? NSColor(named: "MenuHilite") : NSColor(named: "MenuDefault")
                controller.isHidden = GCController.controllers().isEmpty
                if let text = self.controllerValue(for: item) {
                    controller.text = text
                }
            }
        }
    }

    private func value (for item: String) -> String? {
        switch item {
        case Item.displayMode:
            return UserDefaults.standard.fullscreen ? "Fullscreen" : "Window"

        case Item.musicVolume:
            return AudioPlayer.shared.musicVolume == 0 ? "Off" : "\(AudioPlayer.shared.musicVolume)%"

        case Item.fxVolume:
            return AudioPlayer.shared.fxVolume == 0 ? "Off" : "\(AudioPlayer.shared.fxVolume)%"

        case Item.shiftLeft:
            return InputMapper.shared.describeIdForKeyboard(.shiftLeft)

        case Item.shiftRight:
            return InputMapper.shared.describeIdForKeyboard(.shiftRight)

        case Item.rotateLeft:
            return InputMapper.shared.describeIdForKeyboard(.rotateLeft)

        case Item.rotateRight:
            return InputMapper.shared.describeIdForKeyboard(.rotateRight)

        case Item.softDrop:
            return InputMapper.shared.describeIdForKeyboard(.softDrop)

        default:
            return nil
        }
    }

    private func controllerValue (for item: String) -> String? {
        switch item {
        case Item.shiftLeft:
            return InputMapper.shared.describeIdForController(.shiftLeft)

        case Item.shiftRight:
            return InputMapper.shared.describeIdForController(.shiftRight)

        case Item.rotateLeft:
            return InputMapper.shared.describeIdForController(.rotateLeft)

        case Item.rotateRight:
            return InputMapper.shared.describeIdForController(.rotateRight)

        case Item.softDrop:
            return InputMapper.shared.describeIdForController(.softDrop)

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

    private func beginRebind (id: Input, for item: String) {
        self.childNode(withName: "value\(item)")?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.25),
            SKAction.fadeAlpha(to: 0.25, duration: 0.25)
        ])))
        self.rebindId = id
        self.rebindItem = item
        AudioPlayer.playFxPositive()
    }

    private func endRebind (id: Input, for item: String, with event: NSEvent) -> Bool {
        if InputMapper.shared.translate(event: event).contains(where: { $0.id == Input.menu }) {
            AudioPlayer.playFxNegative()
            return false
        }

        if !InputMapper.shared.canBind(id: id) {
            AudioPlayer.playFxNegative()
            return false
        }

        InputMapper.shared.bind(keyCode: event.keyCode, id: id)
        UserDefaults.standard.keyboardBindings = InputMapper.shared.keyboardBindings
        AudioPlayer.playFxPositive()

        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
        }

        return true
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

        case Item.shiftLeft:
            self.beginRebind(id: .shiftLeft, for: item)

        case Item.shiftRight:
            self.beginRebind(id: .shiftRight, for: item)

        case Item.rotateLeft:
            self.beginRebind(id: .rotateLeft, for: item)

        case Item.rotateRight:
            self.beginRebind(id: .rotateRight, for: item)

        case Item.softDrop:
            self.beginRebind(id: .softDrop, for: item)

        case Item.back:
            AudioPlayer.playFxPositive()
            self.transitionToMenu()

        default:
            print("Unknown menu option \(item)")
        }
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0
    }

    override func controllerDidConnect() {
        self.update()
    }

    override func controllerDidDisconnect() {
        self.update()
    }

    override func didEnterFullScreen() {
        UserDefaults.standard.fullscreen = true
        self.update()
    }

    override func didExitFullScreen() {
        UserDefaults.standard.fullscreen = false
        self.update()
    }

    override func keyDown (with event: NSEvent) {
        if let id = self.rebindId, let item = self.rebindItem {
            if self.endRebind(id: id, for: item, with: event) {
                self.rebindId = nil
                self.rebindItem = nil
                self.update()
            }
        } else {
            InputMapper.shared.translate(event: event).forEach {
                self.inputDown(event: $0)
            }
        }
    }

    override func inputDown (event: InputEvent) {
        switch event.id {
        case .up:
            AudioPlayer.playFxSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1
            self.update()

        case .down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0
            self.update()

        case .select:
            self.select(item: self.menuItems[self.selection])
            self.update()

        case .left:
            self.decrease(item: self.menuItems[self.selection])
            self.update()

        case .right:
            self.increase(item: self.menuItems[self.selection])
            self.update()

        case .menu:
            self.select(item: Item.back)

        default:
            print("Unhandled input event: \(event)")
        }
    }
}
