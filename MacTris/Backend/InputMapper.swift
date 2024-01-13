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

    case shiftLeft
    case shiftRight
    case rotateCounterClockwise
    case rotateClockwise
    case softDrop
}

extension Input: CustomStringConvertible {
    var description: String {
        switch self {
        case .menu: "menu"
        case .select: "select"
        case .up: "up"
        case .down: "down"
        case .left: "left"
        case .right: "right"
        case .shiftLeft: "shift left"
        case .shiftRight: "shift right"
        case .rotateCounterClockwise: "rotate counterclockwise"
        case .rotateClockwise: "rotate clockwise"
        case .softDrop: "soft drop"
        }
    }
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

        (binding: KeyBinding(keyCode: KeyCode.arrowLeft.rawValue, id: .shiftLeft), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.arrowRight.rawValue, id: .shiftRight), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.arrowDown.rawValue, id: .softDrop), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.a.rawValue, id: .rotateCounterClockwise), mutable: true),
        (binding: KeyBinding(keyCode: KeyCode.s.rawValue, id: .rotateClockwise), mutable: true)
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
        case .shiftLeft: return "⒤"
        case .shiftRight: return "⒥"
        case .softDrop: return "⒣"
        case .select: return "⒍ or ⒉"
        case .menu: return "Menu or Start"
        case .rotateCounterClockwise: return "⒍ or ⒉" // A / Circle
        case .rotateClockwise: return "⒌ or ⒈" // B / Cross
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
            Logger.input.debug("Keyboard events: \(result, privacy: .public)")
        }

        return result
    }

    func translate (gamepad: GCExtendedGamepad, element: GCControllerElement) -> [InputEvent] {

        var result: [InputEvent] = []

        if gamepad.dpad == element {
            result = [
                // the order is important: game events before menu events
                InputEvent(id: .shiftLeft, isDown: gamepad.dpad.left.isPressed),
                InputEvent(id: .shiftRight, isDown: gamepad.dpad.right.isPressed),
                InputEvent(id: .softDrop, isDown: gamepad.dpad.down.isPressed),
                InputEvent(id: .left, isDown: gamepad.dpad.left.isPressed),
                InputEvent(id: .right, isDown: gamepad.dpad.right.isPressed),
                InputEvent(id: .down, isDown: gamepad.dpad.down.isPressed),
                InputEvent(id: .up, isDown: gamepad.dpad.up.isPressed)
            ]
        }

        if gamepad.buttonA == element {
            result =  [
                InputEvent(id: .rotateCounterClockwise, isDown: gamepad.buttonA.isPressed)
            ]
        }

        if gamepad.buttonB == element {
            result =  [
                // the order is important: game events before menu events
                InputEvent(id: .rotateClockwise, isDown: gamepad.buttonB.isPressed),
                InputEvent(id: .select, isDown: gamepad.buttonB.isPressed)
            ]
        }

        if gamepad.buttonMenu == element {
            result =  [
                InputEvent(id: .menu, isDown: gamepad.buttonMenu.isPressed)
            ]
        }

        if !result.isEmpty {
            Logger.input.debug("Gamepad events: \(result, privacy: .public)")
        }

        return result
    }

    static let shared = InputMapper()
}
