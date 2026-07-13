//
//  Settings.swift
//  MacTris
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent

        switch item {
        case Item.displayMode:
            return UserDefaults.standard.fullscreen
                ? NSLocalizedString("SettingDisplayModeFullscreen", comment: "Value, if display mode is fullscreen")
                : NSLocalizedString("SettingDisplayModeWindow", comment: "Value, if display mode is window")

        case Item.musicVolume:
            return MusicPlayer.shared.volume == 0
                ? NSLocalizedString("SettingAudioOff", comment: "Value, if music volume or fx volume is 0")
                : formatter.string(from: NSNumber(value: Double(MusicPlayer.shared.volume) / 100.0))

        case Item.fxVolume:
            return self.fxPlayer.volume == 0
                ? NSLocalizedString("SettingAudioOff", comment: "Value, if music volume or fx volume is 0")
                : formatter.string(from: NSNumber(value: Double(self.fxPlayer.volume) / 100.0))

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
            return UserDefaults.standard.wallKick
                ? NSLocalizedString("SettingGenericEnabled", comment: "Value, if a setting is enabled")
                : NSLocalizedString("SettingGenericDisabled", comment: "Value, if a setting is disabled")

        case Item.hardDrop:
            return UserDefaults.standard.hardDrop
                ? NSLocalizedString("SettingGenericEnabled", comment: "Value, if a setting is enabled")
                : NSLocalizedString("SettingGenericDisabled", comment: "Value, if a setting is disabled")

        case Item.appearance:
            return UserDefaults.standard.appearance.description

        case Item.animations:
            return UserDefaults.standard.animations
                ? NSLocalizedString("SettingGenericEnabled", comment: "Value, if a setting is enabled")
                : NSLocalizedString("SettingGenericDisabled", comment: "Value, if a setting is disabled")

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

    private func adjust(item: String, direction: AdjustDirection) {
        switch item {
        case Item.displayMode:
            UserDefaults.standard.fullscreen = UserDefaults.standard.fullscreen.adjusted(by: direction)
            self.view?.window?.toggleFullScreen(nil)
            self.fxPlayer.playPositive()

        case Item.musicVolume:
            let volume = min(100, max(0, MusicPlayer.shared.volume + (direction == .increase ? 2 : -2)))
            MusicPlayer.shared.volume = volume
            UserDefaults.standard.musicVolume = volume
            self.fxPlayer.playPositive()

        case Item.fxVolume:
            let volume = min(100, max(0, self.fxPlayer.volume + (direction == .increase ? 2 : -2)))
            self.fxPlayer.volume = volume
            UserDefaults.standard.fxVolume = volume
            self.fxPlayer.playPositive()

        case Item.rngMode:
            UserDefaults.standard.randomGeneratorMode = UserDefaults.standard.randomGeneratorMode.adjusted(by: direction)
            self.fxPlayer.playPositive()

        case Item.autoShift:
            UserDefaults.standard.autoShift = UserDefaults.standard.autoShift.adjusted(by: direction)
            self.fxPlayer.playPositive()

        case Item.wallKick:
            UserDefaults.standard.wallKick = UserDefaults.standard.wallKick.adjusted(by: direction)
            self.fxPlayer.playPositive()

        case Item.hardDrop:
            UserDefaults.standard.hardDrop = UserDefaults.standard.hardDrop.adjusted(by: direction)
            self.fxPlayer.playPositive()

        case Item.appearance:
            UserDefaults.standard.appearance = UserDefaults.standard.appearance.adjusted(by: direction)
            self.fxPlayer.playPositive()

        case Item.animations:
            UserDefaults.standard.animations = UserDefaults.standard.animations.adjusted(by: direction)
            self.fxPlayer.playPositive()

        default:
            self.fxPlayer.playNegative()
        }
    }

    private func select(item: String) {
        switch item {
        case Item.musicVolume:
            let volume = ((MusicPlayer.shared.volume / 10) * 10) + 10
            MusicPlayer.shared.volume = volume > 100 ? 0 : volume
            UserDefaults.standard.musicVolume = volume > 100 ? 0 : volume
            self.fxPlayer.playPositive()

        case Item.fxVolume:
            let volume = ((self.fxPlayer.volume / 10) * 10) + 10
            self.fxPlayer.volume = volume > 100 ? 0 : volume
            UserDefaults.standard.fxVolume = volume > 100 ? 0 : volume
            self.fxPlayer.playPositive()

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

        case Item.back:
            self.fxPlayer.playPositive()
            self.transitionToMenu()

        default:
            // selecting all other items results in the same behaviour as increasing it's value
            self.adjust(item: item, direction: .increase)
        }
    }

    private func beginRebind(id: Input, for item: String) {
        self.childNode(withName: "value\(item)")?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.25),
            SKAction.fadeAlpha(to: 0.25, duration: 0.25)
        ])))
        self.rebindId = id
        self.rebindItem = item
        self.fxPlayer.playPositive()
    }

    private func endRebind(id: Input, for item: String, with event: NSEvent) -> Bool {
        if !self.inputMapper.canBind(keyCode: event.keyCode, id: id) {
            self.fxPlayer.playNegative()
            return false
        }

        self.inputMapper.bind(keyCode: event.keyCode, id: id)
        UserDefaults.standard.keyboardBindings = self.inputMapper.keyboardBindings
        self.fxPlayer.playPositive()

        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
        }

        return true
    }

    private func cancelRebind(item: String) {
        self.fxPlayer.playNegative()
        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
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
                self.cancelRebind(item: item)
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
        if self.rebindId != nil && self.rebindItem != nil {
            return
        }

        switch event.id {
        case .up:
            self.fxPlayer.playSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1
            self.update()

        case .down:
            self.fxPlayer.playSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0
            self.update()

        case .select:
            self.select(item: self.menuItems[self.selection])
            self.update()

        case .left:
            self.adjust(item: self.menuItems[self.selection], direction: .decrease)
            self.update()

        case .right:
            self.adjust(item: self.menuItems[self.selection], direction: .increase)
            self.update()

        case .menu:
            self.select(item: Item.back)

        default:
            break
        }
    }
}
