//
//  Settings.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import SpriteKit
import GameController

/// The settings scene. Allows customization of display mode, audio volumes,
/// key bindings, RNG mode, DAS speed, wall kick, hard drop, appearance, and animations.
class Settings: SceneBase {
    private var menuItems: [String] = []
    private var settingItems: [any SettingItem] = []

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
                value.text = self.settingItems.first { $0.identifier == item }?.value ?? ""
            }

            if let controller = self.childNode(withName: "controller" + item) as? SKLabelNode {
                controller.fontColor = index == self.selection ? NSColor(named: "MenuHilite") : NSColor(named: "MenuDefault")
                controller.isHidden = GCController.controllers().isEmpty
                controller.text = self.settingItems.first { $0.identifier == item }?.controllerValue ?? ""
            }
        }
    }

    private func adjust(item identifier: String, direction: AdjustDirection) -> Bool {
        self.settingItems.first { $0.identifier == identifier }?.adjust(direction: direction) ?? false
    }

    private func select(item identifier: String) -> Bool {
        self.settingItems.first { $0.identifier == identifier }?.select() ?? false
    }

    private func beginRebind(id: Input, for item: String) {
        self.childNode(withName: "value\(item)")?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.25),
            SKAction.fadeAlpha(to: 0.25, duration: 0.25)
        ])))
        self.rebindId = id
        self.rebindItem = item
    }

    private func endRebind(id: Input, for item: String, with event: NSEvent) -> Bool {
        guard self.inputMapper?.bind(keyCode: event.keyCode, id: id) ?? false else {
            return false
        }

        if let bindings = self.inputMapper?.keyboardBindings {
            self.gameSettings?.keyboardBindings = bindings
        }

        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
        }

        return true
    }

    private func cancelRebind(item: String) {
        if let node = self.childNode(withName: "value\(item)") {
            node.removeAllActions()
            node.run(SKAction.fadeAlpha(to: 1.0, duration: 0.25))
        }
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        guard let gameSettings = self.gameSettings else {
            return
        }

        // Each menu item XXX consists of a node named menuXXX (a bullet), a labelXXX, and a valueXXX.
        // Key-binding items may have an additional column named controllerXXX.
        // menuItems contains the menu item names in SpriteKit scene order, while settingItems contains the settings.
        // The two arrays are associated by the identifier XXX.

        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }

        self.settingItems = [
            VolumeSetting(identifier: "MusicVolume", target: self.musicPlayer, settings: gameSettings, keyPath: \.musicVolume),
            VolumeSetting(identifier: "FxVolume", target: self.audioFxPlayer, settings: gameSettings, keyPath: \.fxVolume),
            DisplaySetting(identifier: "DisplayMode", target: self.view?.window, settings: gameSettings, keyPath: \.fullscreen),

            ToggleSetting(identifier: "Animations", settings: gameSettings, keyPath: \.animations),
            ToggleSetting(identifier: "WallKick", settings: gameSettings, keyPath: \.wallKick),
            ToggleSetting(identifier: "HardDrop", settings: gameSettings, keyPath: \.hardDrop),

            KeyBindingSetting(identifier: "KeyShiftLeft", target: .shiftLeft, inputMapper: self.inputMapper, action: self.beginRebind(id:for:)),
            KeyBindingSetting(identifier: "KeyShiftRight", target: .shiftRight, inputMapper: self.inputMapper, action: self.beginRebind(id:for:)),
            KeyBindingSetting(identifier: "KeyRotateLeft", target: .rotateCounterClockwise, inputMapper: self.inputMapper, action: self.beginRebind(id:for:)),
            KeyBindingSetting(identifier: "KeyRotateRight", target: .rotateClockwise, inputMapper: self.inputMapper, action: self.beginRebind(id:for:)),
            KeyBindingSetting(identifier: "KeySoftDrop", target: .softDrop, inputMapper: self.inputMapper, action: self.beginRebind(id:for:)),
            KeyBindingSetting(identifier: "KeyHardDrop", target: .hardDrop, inputMapper: self.inputMapper, action: self.beginRebind(id:for:)),

            ChoiceSetting<RandomGeneratorMode>(identifier: "RngMode", settings: gameSettings, keyPath: \.randomGeneratorMode),
            ChoiceSetting<AutoShift>(identifier: "AutoShift", settings: gameSettings, keyPath: \.autoShift),
            ChoiceSetting<Appearance>(identifier: "Appearance", settings: gameSettings, keyPath: \.appearance),

            ActionSetting(identifier: "Back") { [weak self] in
                self?.transition(to: Menu.self)
            }
        ]

        self.selection = 0
    }

    override func controllerDidConnect() {
        self.update()
    }

    override func controllerDidDisconnect() {
        self.update()
    }

    override func didEnterFullScreen() {
        self.update()
    }

    override func didExitFullScreen() {
        self.update()
    }

    override func keyDown(with event: NSEvent) {
        if let id = self.rebindId, let item = self.rebindItem {
            // The Menu key aborts key binding. This must be checked here rather than in input(down:),
            // because this override handles key events directly and does not call super while rebinding.
            if self.inputMapper?.translate(event: event).first(where: { $0.id == .menu }) != nil {
                self.cancelRebind(item: item)
                self.rebindId = nil
                self.rebindItem = nil
                self.audioFxPlayer?.play(.negative)
                self.update()
            } else if self.endRebind(id: id, for: item, with: event) {
                self.rebindId = nil
                self.rebindItem = nil
                self.audioFxPlayer?.play(.positive)
                self.update()
            } else {
                self.audioFxPlayer?.play(.negative)
            }
        } else {
            super.keyDown(with: event)
        }
    }

    override func input(down event: InputEvent) {
        if self.rebindId != nil && self.rebindItem != nil {
            return
        }

        switch event.id {
        case .up:
            self.audioFxPlayer?.play(.select)
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1

        case .down:
            self.audioFxPlayer?.play(.select)
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0

        case .select:
            let result = self.select(item: self.menuItems[self.selection])
            self.audioFxPlayer?.play(result ? .positive : .negative)
            self.update()

        case .left:
            let result = self.adjust(item: self.menuItems[self.selection], direction: .decrease)
            self.audioFxPlayer?.play(result ? .positive : .negative)
            self.update()

        case .right:
            let result = self.adjust(item: self.menuItems[self.selection], direction: .increase)
            self.audioFxPlayer?.play(result ? .positive : .negative)
            self.update()

        case .menu:
            let result = self.select(item: "Back")
            self.audioFxPlayer?.play(result ? .positive : .negative)

        default:
            break
        }
    }
}
