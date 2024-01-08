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
            return self.rebindEvent == .shiftLeft ? "" : InputMapper.shared.describeIdForKeyboard(.shiftLeft)

        case Item.shiftRight:
            return self.rebindEvent == .shiftRight ? "" : InputMapper.shared.describeIdForKeyboard(.shiftRight)

        case Item.rotateLeft:
            return self.rebindEvent == .rotateLeft ? "": InputMapper.shared.describeIdForKeyboard(.rotateLeft)

        case Item.rotateRight:
            return self.rebindEvent == .rotateRight ? "": InputMapper.shared.describeIdForKeyboard(.rotateRight)

        case Item.softDrop:
            return self.rebindEvent == .softDrop ? "" : InputMapper.shared.describeIdForKeyboard(.softDrop)

        default:
            return nil
        }
    }

    private func controllerValue (for item: String) -> String? {
        switch item {
        case Item.shiftLeft:
            return /*self.rebindEvent == .shfitLeft ? "" :*/ InputMapper.shared.describeIdForController(.shiftLeft)

        case Item.shiftRight:
            return /*self.rebindEvent == .shiftRight ? "" :*/ InputMapper.shared.describeIdForController(.shiftRight)

        case Item.rotateLeft:
            return /*self.rebindEvent == .rotateLeft ? "":*/ InputMapper.shared.describeIdForController(.rotateLeft)

        case Item.rotateRight:
            return /*self.rebindEvent == .rotateRight ? "":*/ InputMapper.shared.describeIdForController(.rotateRight)

        case Item.softDrop:
            return /*self.rebindEvent == .softDrop ? "" :*/ InputMapper.shared.describeIdForController(.softDrop)

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

        case Item.shiftLeft:
            self.rebindEvent = .shiftLeft
            AudioPlayer.playFxPositive()

        case Item.shiftRight:
            self.rebindEvent = .shiftRight
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
            self.transitionToMenu()

        default:
            print("Unknown menu option \(item)")
        }
    }

    override func didMove(to view: SKView) {
        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0

        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in
            self?.update()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            self?.update()
        }

        NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { [weak self] _ in
            UserDefaults.standard.fullscreen = true
            self?.update()
        }

        NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { [weak self] _ in
            UserDefaults.standard.fullscreen = false
            self?.update()
        }
    }

    override func keyDown (with event: NSEvent) {
        if let rebindEvent = self.rebindEvent {
            if InputMapper.shared.translate(event: event).contains(where: { $0.id == Input.menu }) {
                AudioPlayer.playFxNegative()
                return
            }

            if InputMapper.shared.canBind(id: rebindEvent) {
                InputMapper.shared.bind(keyCode: event.keyCode, id: rebindEvent)
                UserDefaults.standard.keyboardBindings = InputMapper.shared.keyboardBindings
                AudioPlayer.playFxPositive()
                self.rebindEvent = nil
                self.update()
            } else {
                AudioPlayer.playFxNegative()
            }
        } else {
            InputMapper.shared.translate(event: event).forEach {
                self.inputDown(event: $0)
            }
        }
    }
}

extension Settings: InputEventResponder {
    func inputDown(event: InputEvent) {
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

    func inputUp(event: InputEvent) {
    }
}
