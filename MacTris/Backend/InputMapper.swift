//
//  KeyMapper.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 06.01.24.
//

import Foundation
import GameController

enum Input {
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
    // swiftlint:disable:next large_tuple
    private var keymap: [(keyCode: UInt16, event: Input, canBind: Bool)] = [
        (keyCode: KeyCode.arrowLeft.rawValue, event: .left, canBind: false),
        (keyCode: KeyCode.arrowLeft.rawValue, event: .moveLeft, canBind: true),
        (keyCode: KeyCode.arrowRight.rawValue, event: .right, canBind: false),
        (keyCode: KeyCode.arrowRight.rawValue, event: .moveRight, canBind: true),
        (keyCode: KeyCode.arrowDown.rawValue, event: .down, canBind: false),
        (keyCode: KeyCode.arrowDown.rawValue, event: .softDrop, canBind: true),
        (keyCode: KeyCode.arrowUp.rawValue, event: .up, canBind: false),
        (keyCode: KeyCode.escape.rawValue, event: .menu, canBind: false),
        (keyCode: KeyCode.space.rawValue, event: .select, canBind: false),
        (keyCode: KeyCode.return.rawValue, event: .select, canBind: false),
        (keyCode: KeyCode.a.rawValue, event: .rotateLeft, canBind: true),
        (keyCode: KeyCode.s.rawValue, event: .rotateRight, canBind: true)
    ]

    func describe (keyboardEvent: Input) -> String {
        if let keyCode = self.keymap.first(where: { $0.event == keyboardEvent})?.keyCode {
            return KeyCode(rawValue: keyCode)?.description ?? "⍰"
        }
        return "⍰"
    }

    func bind (keyCode: UInt16, event: Input) {
        self.keymap.removeAll { $0.event == event && $0.canBind }
        self.keymap.append((keyCode: keyCode, event: event, canBind: true))
    }

    func canBind (event: Input) -> Bool {
        return self.keymap.first { $0.event == event && $0.canBind } != nil
    }

    func translate (nsEvent event: NSEvent) -> [InputEvent] {
        switch event.type {
        case .keyDown:
            return self.keymap.filter { $0.keyCode == event.keyCode }.map { InputEvent(id: $0.event, isDown: true) }
        case .keyUp:
            return self.keymap.filter { $0.keyCode == event.keyCode }.map { InputEvent(id: $0.event, isDown: false) }
        default:
            return []
        }
    }

    func translate (gamepad: GCExtendedGamepad, element: GCControllerElement) -> [InputEvent] {
        if gamepad.dpad == element {
            return [
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
            return [
                InputEvent(id: .rotateLeft, isDown: gamepad.buttonA.isPressed)
            ]
        }

        if gamepad.buttonB == element {
            return [
                InputEvent(id: .select, isDown: gamepad.buttonB.isPressed),
                InputEvent(id: .rotateRight, isDown: gamepad.buttonB.isPressed)
            ]
        }

        if gamepad.buttonMenu == element {
            return [
                InputEvent(id: .menu, isDown: gamepad.buttonMenu.isPressed)
            ]
        }

        return []
    }

    static let shared = InputMapper()
}
