//
//  Settings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import SpriteKit
import GameController

class Settings: SceneBase {

    private struct Item {
        static let musicVolume = "MusicVolume"
        static let fxVolume = "FxVolume"
        static let displayMode = "DisplayMode"
        static let appearance = "Appearance"
        static let animations = "Animations"
        static let keyShiftLeft = "KeyShiftLeft"
        static let keyShiftRight = "KeyShiftRight"
        static let keyRotateLeft = "KeyRotateLeft"
        static let keyRotateRight = "KeyRotateRight"
        static let keySoftDrop = "KeySoftDrop"
        static let keyHardDrop = "KeyHardDrop"
        static let rngMode = "RngMode"
        static let autoShift = "AutoShift"
        static let wallKick = "WallKick"
        static let hardDrop = "HardDrop"

        static let back = "Back"
    }

    private var menuItems: [String] = []
    private var selection: Int = -1 {
        didSet {
            self.update()
        }
    }

    private var rebindId: Input?
    private var rebindItem: String?

    private func update() {
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

    private func value(for item: String) -> String? {
        switch item {
        case Item.displayMode:
            return UserDefaults.standard.fullscreen ? "Fullscreen" : "Window"

        case Item.musicVolume:
            return AudioPlayer.shared.musicVolume == 0 ? "Off" : "\(AudioPlayer.shared.musicVolume)%"

        case Item.fxVolume:
            return AudioPlayer.shared.fxVolume == 0 ? "Off" : "\(AudioPlayer.shared.fxVolume)%"

        case Item.keyShiftLeft:
            return self.inputMapper.describeIdForKeyboard(.shiftLeft)

        case Item.keyShiftRight:
            return self.inputMapper.describeIdForKeyboard(.shiftRight)

        case Item.keyRotateLeft:
            return self.inputMapper.describeIdForKeyboard(.rotateCounterClockwise)

        case Item.keyRotateRight:
            return self.inputMapper.describeIdForKeyboard(.rotateClockwise)

        case Item.keySoftDrop:
            return self.inputMapper.describeIdForKeyboard(.softDrop)

        case Item.keyHardDrop:
            return self.inputMapper.describeIdForKeyboard(.hardDrop)

        case Item.rngMode:
            return UserDefaults.standard.randomGeneratorMode.description

        case Item.autoShift:
            return UserDefaults.standard.autoShift.description

        case Item.wallKick:
            return UserDefaults.standard.wallKick ? "Enabled" : "Disabled"

        case Item.hardDrop:
            return UserDefaults.standard.hardDrop ? "Enabled" : "Disabled"

        case Item.appearance:
            return UserDefaults.standard.appearance.description

        case Item.animations:
            return UserDefaults.standard.animations ? "Enabled" : "Disabled"

        default:
            return nil
        }
    }

    private func controllerValue(for item: String) -> String? {
        switch item {
        case Item.keyShiftLeft:
            return self.inputMapper.describeIdForController(.shiftLeft)

        case Item.keyShiftRight:
            return self.inputMapper.describeIdForController(.shiftRight)

        case Item.keyRotateLeft:
            return self.inputMapper.describeIdForController(.rotateCounterClockwise)

        case Item.keyRotateRight:
            return self.inputMapper.describeIdForController(.rotateClockwise)

        case Item.keySoftDrop:
            return self.inputMapper.describeIdForController(.softDrop)

        case Item.keyHardDrop:
            return self.inputMapper.describeIdForController(.hardDrop)

        default:
            return nil
        }
    }

    private func increase(item: String) {
        switch item {
        case Item.displayMode:
            UserDefaults.standard.fullscreen = !UserDefaults.standard.fullscreen
            self.view?.window?.toggleFullScreen(nil)
            AudioPlayer.playFxPositive()

        case Item.musicVolume:
            AudioPlayer.shared.musicVolume = min(100, AudioPlayer.shared.musicVolume + 2)
            UserDefaults.standard.musicVolume = AudioPlayer.shared.musicVolume
            AudioPlayer.playFxPositive()

        case Item.fxVolume:
            AudioPlayer.shared.fxVolume = min(100, AudioPlayer.shared.fxVolume + 2)
            UserDefaults.standard.fxVolume = AudioPlayer.shared.fxVolume
            AudioPlayer.playFxPositive()

        case Item.rngMode:
            UserDefaults.standard.randomGeneratorMode = UserDefaults.standard.randomGeneratorMode.increase()
            AudioPlayer.playFxPositive()

        case Item.autoShift:
            UserDefaults.standard.autoShift = UserDefaults.standard.autoShift.increase()
            AudioPlayer.playFxPositive()

        case Item.wallKick:
            UserDefaults.standard.wallKick = !UserDefaults.standard.wallKick
            AudioPlayer.playFxPositive()

        case Item.hardDrop:
            UserDefaults.standard.hardDrop = !UserDefaults.standard.hardDrop
            AudioPlayer.playFxPositive()

        case Item.appearance:
            UserDefaults.standard.appearance = UserDefaults.standard.appearance.increase()
            AudioPlayer.playFxPositive()

        case Item.animations:
            UserDefaults.standard.animations = !UserDefaults.standard.animations
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func decrease(item: String) {
        switch item {
        case Item.displayMode:
            UserDefaults.standard.fullscreen = !UserDefaults.standard.fullscreen
            self.view?.window?.toggleFullScreen(nil)
            AudioPlayer.playFxPositive()

        case Item.musicVolume:
            AudioPlayer.shared.musicVolume = max(0, AudioPlayer.shared.musicVolume - 2)
            UserDefaults.standard.musicVolume = AudioPlayer.shared.musicVolume
            AudioPlayer.playFxPositive()

        case Item.fxVolume:
            AudioPlayer.shared.fxVolume = max(0, AudioPlayer.shared.fxVolume - 2)
            UserDefaults.standard.fxVolume = AudioPlayer.shared.fxVolume
            AudioPlayer.playFxPositive()

        case Item.rngMode:
            UserDefaults.standard.randomGeneratorMode = UserDefaults.standard.randomGeneratorMode.decrease()
            AudioPlayer.playFxPositive()

        case Item.autoShift:
            UserDefaults.standard.autoShift = UserDefaults.standard.autoShift.decrease()
            AudioPlayer.playFxPositive()

        case Item.wallKick:
            UserDefaults.standard.wallKick = !UserDefaults.standard.wallKick
            AudioPlayer.playFxPositive()

        case Item.hardDrop:
            UserDefaults.standard.hardDrop = !UserDefaults.standard.hardDrop
            AudioPlayer.playFxPositive()

        case Item.appearance:
            UserDefaults.standard.appearance = UserDefaults.standard.appearance.decrease()
            AudioPlayer.playFxPositive()

        case Item.animations:
            UserDefaults.standard.animations = !UserDefaults.standard.animations
            AudioPlayer.playFxPositive()

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func beginRebind(id: Input, for item: String) {
        self.childNode(withName: "value\(item)")?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.25),
            SKAction.fadeAlpha(to: 0.25, duration: 0.25)
        ])))
        self.rebindId = id
        self.rebindItem = item
        AudioPlayer.playFxPositive()
    }

    private func endRebind(id: Input, for item: String, with event: NSEvent) -> Bool {
        if !self.inputMapper.canBind(keyCode: event.keyCode, id: id) {
            AudioPlayer.playFxNegative()
            return false
        }

        self.inputMapper.bind(keyCode: event.keyCode, id: id)
        UserDefaults.standard.keyboardBindings = self.inputMapper.keyboardBindings
        AudioPlayer.playFxPositive()

        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
        }

        return true
    }

    private func canceRebind(item: String) {
        AudioPlayer.playFxNegative()
        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
        }
    }

    private func select(item: String) {
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

        case Item.keyShiftLeft:
            self.beginRebind(id: .shiftLeft, for: item)

        case Item.keyShiftRight:
            self.beginRebind(id: .shiftRight, for: item)

        case Item.keyRotateLeft:
            self.beginRebind(id: .rotateCounterClockwise, for: item)

        case Item.keyRotateRight:
            self.beginRebind(id: .rotateClockwise, for: item)

        case Item.keySoftDrop:
            self.beginRebind(id: .softDrop, for: item)

        case Item.keyHardDrop:
            self.beginRebind(id: .hardDrop, for: item)

        case Item.rngMode:
            UserDefaults.standard.randomGeneratorMode = UserDefaults.standard.randomGeneratorMode.increase()
            AudioPlayer.playFxPositive()

        case Item.autoShift:
            UserDefaults.standard.autoShift = UserDefaults.standard.autoShift.increase()
            AudioPlayer.playFxPositive()

        case Item.wallKick:
            UserDefaults.standard.wallKick = !UserDefaults.standard.wallKick
            AudioPlayer.playFxPositive()

        case Item.hardDrop:
            UserDefaults.standard.hardDrop = !UserDefaults.standard.hardDrop
            AudioPlayer.playFxPositive()

        case Item.appearance:
            UserDefaults.standard.appearance = UserDefaults.standard.appearance.increase()
            AudioPlayer.playFxPositive()

        case Item.animations:
            UserDefaults.standard.animations = !UserDefaults.standard.animations
            AudioPlayer.playFxPositive()

        case Item.back:
            AudioPlayer.playFxPositive()
            self.transitionToMenu()

        default:
            break
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

    override func keyDown(with event: NSEvent) {
        if let id = self.rebindId, let item = self.rebindItem {
            // the menu key aborts binding the key
            if self.inputMapper.translate(event: event).first(where: { $0.id == .menu }) != nil {
                self.canceRebind(item: item)
                self.rebindId = nil
                self.rebindItem = nil
                self.update()
            } else if self.endRebind(id: id, for: item, with: event) {
                self.rebindId = nil
                self.rebindItem = nil
                self.update()
            }
        } else {
            super.keyDown(with: event)
        }
    }

    override func inputDown(event: InputEvent) {
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
            break

        }
    }
}
