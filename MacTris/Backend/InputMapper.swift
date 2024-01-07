//
//  KeyMapper.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 06.01.24.
//

import Foundation
import GameController
import OSLog

enum Input: Codable {
    case menu
    case select

    case up
    case down
    case left
    case right

    case moveLeft
    case moveRight
    case rotateLeft
    case rotateRight
    case softDrop
}

class InputMapper {

    struct KeyBinding: Codable {
        let keyCode: UInt16
        let id: Input
    }

    private var keymap: [(binding: KeyBinding, mutable: Bool)] = [
        (binding: KeyBinding(keyCode: KeyCode.arrowLeft.rawValue, id: .left), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.arrowRight.rawValue, id: .right), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.arrowDown.rawValue, id: .down), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.arrowUp.rawValue, id: .up), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.escape.rawValue, id: .menu), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.space.rawValue, id: .select), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.return.rawValue, id: .select), mutable: false),

        (binding: KeyBinding(keyCode: KeyCode.arrowLeft.rawValue, id: .moveLeft), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.arrowRight.rawValue, id: .moveRight), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.arrowDown.rawValue, id: .softDrop), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.a.rawValue, id: .rotateLeft), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.s.rawValue, id: .rotateRight), mutable: true)
    ]

    var keyboardBindings: [KeyBinding] {
        get {
            self.keymap.filter { $0.mutable }.map { $0.binding }
        }
        set {
            for binding in newValue {
                self.bind(keyCode: binding.keyCode, id: binding.id)
            }
        }
    }

    func describeIdForKeyboard (_ id: Input) -> String {
        if let keyCode = self.keymap.first(where: { $0.binding.id == id})?.binding.keyCode {
            return KeyCode(rawValue: keyCode)?.description ?? "⍰"
        }
        return "⍰"
    }

    func describeIdForController (_ id: Input) -> String {
        switch id {
        case .down: return "⒣"
        case .left: return "⒤"
        case .up: return "⒢"
        case .right: return "⒥"
        case .moveLeft: return "⒤"
        case .moveRight: return "⒥"
        case .softDrop: return "⒣"
        case .select: return "Select"
        case .menu: return "Menu or Start"
        case .rotateLeft: return "⒍ or ⒉" // A / Circle
        case .rotateRight: return "⒌ or ⒈" // B / Cross
        }
    }

    func bind (keyCode: UInt16, id: Input) {
        self.keymap.removeAll { $0.binding.id == id && $0.mutable }
        self.keymap.append((binding: KeyBinding(keyCode: keyCode, id: id), mutable: true))
    }

    func canBind (id: Input) -> Bool {
        return self.keymap.first { $0.binding.id == id && $0.mutable } != nil
    }

    func translate (event: NSEvent) -> [InputEvent] {
        var result: [InputEvent] = []

        switch event.type {
        case .keyDown:
            result = self.keymap.filter { $0.binding.keyCode == event.keyCode }.map { InputEvent(id: $0.binding.id, isDown: true) }
        case .keyUp:
            result = self.keymap.filter { $0.binding.keyCode == event.keyCode }.map { InputEvent(id: $0.binding.id, isDown: false) }
        default:
            break
        }

        if !result.isEmpty {
            Logger.input.debug("Keyboard events: \(result)")
        }

        return result
    }

    func translate (gamepad: GCExtendedGamepad, element: GCControllerElement) -> [InputEvent] {

        var result: [InputEvent] = []

        if gamepad.dpad == element {
            result = [
                InputEvent(id: .left, isDown: gamepad.dpad.left.isPressed),
                InputEvent(id: .right, isDown: gamepad.dpad.right.isPressed),
                InputEvent(id: .down, isDown: gamepad.dpad.down.isPressed),
                InputEvent(id: .up, isDown: gamepad.dpad.up.isPressed),
                InputEvent(id: .moveLeft, isDown: gamepad.dpad.left.isPressed),
                InputEvent(id: .moveRight, isDown: gamepad.dpad.right.isPressed),
                InputEvent(id: .softDrop, isDown: gamepad.dpad.down.isPressed)
            ]
        }

        if gamepad.buttonA == element {
            result =  [
                InputEvent(id: .rotateLeft, isDown: gamepad.buttonA.isPressed)
            ]
        }

        if gamepad.buttonB == element {
            result =  [
                InputEvent(id: .select, isDown: gamepad.buttonB.isPressed),
                InputEvent(id: .rotateRight, isDown: gamepad.buttonB.isPressed)
            ]
        }

        if gamepad.buttonMenu == element {
            result =  [
                InputEvent(id: .menu, isDown: gamepad.buttonMenu.isPressed)
            ]
        }

        if !result.isEmpty {
            Logger.input.debug("Gamepad events: \(result)")
        }

        return result
    }

    static let shared = InputMapper()
}
