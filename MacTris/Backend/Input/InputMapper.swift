//
//  InputMapper.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 06.01.24.
//

import Foundation
import GameController

/// Maps keyboard key codes and game controller input to game actions (`InputEvent`).
/// Keyboard bindings can be customized and persisted.
class InputMapper {

    convenience init() {
        self.init(keyboardBindings: [])
    }

    init(keyboardBindings: [KeyBinding]) {
        self.keyboardBindings = keyboardBindings
    }

    /// Associates a hardware key code with a game action.
    struct KeyBinding: Codable {
        let keyCode: UInt16
        let id: Input
    }

    static let unknownCharacterDescription: String = "???"

    private var keymap: [(binding: KeyBinding, mutable: Bool)] = [
        (binding: KeyBinding(keyCode: KeyCode.arrowLeft.rawValue, id: .left), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.arrowRight.rawValue, id: .right), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.arrowDown.rawValue, id: .down), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.arrowUp.rawValue, id: .up), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.escape.rawValue, id: .menu), mutable: false),
        (binding: KeyBinding(keyCode: KeyCode.return.rawValue, id: .select), mutable: false),

        (binding: KeyBinding(keyCode: KeyCode.arrowLeft.rawValue, id: .shiftLeft), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.arrowRight.rawValue, id: .shiftRight), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.arrowDown.rawValue, id: .softDrop), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.space.rawValue, id: .hardDrop), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.a.rawValue, id: .rotateCounterClockwise), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.s.rawValue, id: .rotateClockwise), mutable: true)
    ]

    static let unmappableKeyCodes: [KeyCode] = [
        .escape,
        .return
    ]

    var keyboardBindings: [KeyBinding] {
        get {
            self.keymap.filter { $0.mutable }.map { $0.binding }
        }
        set {
            for binding in newValue {
                self.bindUnsafe(keyCode: binding.keyCode, id: binding.id)
            }
        }
    }

    func describeIdForKeyboard(_ id: Input) -> String {
        if let keyCode = self.keymap.first(where: { $0.binding.id == id})?.binding.keyCode {
            return KeyCode(rawValue: keyCode)?.description ?? InputMapper.unknownCharacterDescription
        }
        return InputMapper.unknownCharacterDescription
    }

    func describeIdForController(_ id: Input) -> String {
        switch id {
        case .down: return "⒣"
        case .left: return "⒤"
        case .up: return "⒢"
        case .right: return "⒥"
        case .shiftLeft: return "⒤"
        case .shiftRight: return "⒥"
        case .softDrop: return "⒣"
        case .hardDrop: return "⒏ or ⒋" // Y / Triangle
        case .select: return "⒍ or ⒉" // B / Circle
        case .menu: return NSLocalizedString("InputMapperControllerButtonMenuOrStart", comment: "The name of the controller button")
        case .rotateCounterClockwise: return "⒌ or ⒈" // A / Cross
        case .rotateClockwise:  return "⒍ or ⒉" // B / Circle
        }
    }

    private func bindUnsafe(keyCode: UInt16, id: Input) {
        self.keymap.removeAll { $0.binding.id == id && $0.mutable }
        self.keymap.append((binding: KeyBinding(keyCode: keyCode, id: id), mutable: true))
    }

    func bind(keyCode: UInt16, id: Input) -> Bool {
        if !canBind(keyCode: keyCode, id: id) {
            return false
        }
        self.bindUnsafe(keyCode: keyCode, id: id)
        return true
    }

    func canBind(keyCode: UInt16, id: Input) -> Bool {
        // check if it's a forbidden key
        if InputMapper.unmappableKeyCodes.first(where: { $0.rawValue == keyCode}) != nil {
            return false
        }

        // check if it's a mutable, bindable key
        if self.keymap.first(where: { $0.binding.id == id && $0.mutable }) == nil {
            return false
        }
        // check if it's not already bound elsewhere
        if self.keymap.first(where: { $0.binding.keyCode == keyCode && $0.binding.id != id && $0.mutable }) != nil {
            return false
        }
        return true
    }

    func translate(event: NSEvent) -> [InputEvent] {
        var result: [InputEvent] = []

        switch event.type {
        case .keyDown:
            result = self.keymap.filter { $0.binding.keyCode == event.keyCode }.map { InputEvent(id: $0.binding.id, isDown: true, source: .keyboard, isARepeat: event.isARepeat) }
        case .keyUp:
            result = self.keymap.filter { $0.binding.keyCode == event.keyCode }.map { InputEvent(id: $0.binding.id, isDown: false, source: .keyboard) }
        default:
            break
        }

        return result
    }

    func translate(gamepad: GCExtendedGamepad, element: GCControllerElement) -> [InputEvent] {

        var result: [InputEvent] = []

        if gamepad.dpad == element {
            result = [
                // the order is important: game events before menu events
                InputEvent(id: .shiftLeft, isDown: gamepad.dpad.left.isPressed, source: .controller),
                InputEvent(id: .shiftRight, isDown: gamepad.dpad.right.isPressed, source: .controller),
                InputEvent(id: .softDrop, isDown: gamepad.dpad.down.isPressed, source: .controller),
                InputEvent(id: .left, isDown: gamepad.dpad.left.isPressed, source: .controller),
                InputEvent(id: .right, isDown: gamepad.dpad.right.isPressed, source: .controller),
                InputEvent(id: .down, isDown: gamepad.dpad.down.isPressed, source: .controller),
                InputEvent(id: .up, isDown: gamepad.dpad.up.isPressed, source: .controller)
            ]
        }

        if gamepad.buttonA == element {
            result =  [
                InputEvent(id: .rotateCounterClockwise, isDown: gamepad.buttonA.isPressed, source: .controller)
            ]
        }

        if gamepad.buttonB == element {
            result =  [
                // the order is important: game events before menu events
                InputEvent(id: .rotateClockwise, isDown: gamepad.buttonB.isPressed, source: .controller),
                InputEvent(id: .select, isDown: gamepad.buttonB.isPressed, source: .controller)
            ]
        }

        if gamepad.buttonY == element {
            result =  [
                InputEvent(id: .hardDrop, isDown: gamepad.buttonY.isPressed, source: .controller)
            ]
        }

        if gamepad.buttonMenu == element {
            result =  [
                InputEvent(id: .menu, isDown: gamepad.buttonMenu.isPressed, source: .controller)
            ]
        }

        return result
    }
}
