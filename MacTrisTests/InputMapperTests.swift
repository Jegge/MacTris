//
//  InputMapperTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Testing
import Foundation
import AppKit
@testable import MacTris

struct InputMapperTests {
    @Test func testDefaultKeyboardBindingsContainExpectedInputs() async throws {
        let mapper = InputMapper()
        let inputs = Set(mapper.keyboardBindings.map { $0.id })
        let expected: Set<Input> = [.shiftLeft, .shiftRight, .softDrop, .hardDrop, .rotateCounterClockwise, .rotateClockwise]
        #expect(inputs == expected)
    }

    @Test func testDefaultMutableBindings() async throws {
        let mapper = InputMapper()
        #expect(mapper.keyboardBindings.first(where: { $0.id == .shiftLeft })?.keyCode == KeyCode.arrowLeft.rawValue)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .shiftRight })?.keyCode == KeyCode.arrowRight.rawValue)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .softDrop })?.keyCode == KeyCode.arrowDown.rawValue)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .hardDrop })?.keyCode == KeyCode.space.rawValue)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .rotateClockwise })?.keyCode == KeyCode.s.rawValue)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .rotateCounterClockwise })?.keyCode == KeyCode.a.rawValue)
    }

    @Test func testDefaultImmutableBindings() async throws {
        let mapper = InputMapper()
        #expect(mapper.keyboardBindings.first(where: { $0.id == .left }) == nil)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .right }) == nil)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .up }) == nil)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .down }) == nil)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .menu }) == nil)
        #expect(mapper.keyboardBindings.first(where: { $0.id == .select }) == nil)
    }

    @Test func testDefaultKeyboardBoundIdDescriptions() async throws {
        let mapper = InputMapper()
        #expect(mapper.describeIdForKeyboard(.menu) == "Escape")
        #expect(mapper.describeIdForKeyboard(.select) == "Return")
        #expect(mapper.describeIdForKeyboard(.left) == "Left")
        #expect(mapper.describeIdForKeyboard(.right) == "Right")
        #expect(mapper.describeIdForKeyboard(.up) == "Up")
        #expect(mapper.describeIdForKeyboard(.down) == "Down")
        #expect(mapper.describeIdForKeyboard(.shiftLeft) == "Left")
        #expect(mapper.describeIdForKeyboard(.shiftRight) == "Right")
        #expect(mapper.describeIdForKeyboard(.hardDrop) == "Space")
        #expect(mapper.describeIdForKeyboard(.softDrop) == "Down")
        #expect(mapper.describeIdForKeyboard(.rotateClockwise) == "S")
        #expect(mapper.describeIdForKeyboard(.rotateCounterClockwise) == "A")
    }

    @Test func testDefaultControllerBoundIdDescriptions() async throws {
        let mapper = InputMapper()
        #expect(mapper.describeIdForController(.menu) == NSLocalizedString("InputMapperControllerButtonMenuOrStart", comment: "The name of the controller button"))
        #expect(mapper.describeIdForController(.select) == "⒍ or ⒉") // B / Circle
        #expect(mapper.describeIdForController(.left) == "⒤")
        #expect(mapper.describeIdForController(.right) == "⒥")
        #expect(mapper.describeIdForController(.up) == "⒢")
        #expect(mapper.describeIdForController(.down) == "⒣")
        #expect(mapper.describeIdForController(.shiftLeft) == "⒤")
        #expect(mapper.describeIdForController(.shiftRight) == "⒥")
        #expect(mapper.describeIdForController(.hardDrop) == "⒏ or ⒋") // Y / Triangle
        #expect(mapper.describeIdForController(.softDrop) == "⒣")
        #expect(mapper.describeIdForController(.rotateClockwise) == "⒍ or ⒉") // B / Circle
        #expect(mapper.describeIdForController(.rotateCounterClockwise) == "⒌ or ⒈") // A / Cross
    }

    @Test func testRebindingNewKeyMutable() async throws {
        let mapper = InputMapper()
        let oldKeyCode = mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode
        #expect(mapper.bind(keyCode: KeyCode.z.rawValue, id: .hardDrop))
        let newKeyCode = mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode
        #expect(oldKeyCode != newKeyCode)
        #expect(newKeyCode == KeyCode.z.rawValue)
    }

    @Test func testRebindingSameKeyMutable() async throws {
        let mapper = InputMapper()
        let oldKeyCode = mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode
        #expect(oldKeyCode != nil)
        #expect(mapper.bind(keyCode: oldKeyCode ?? 0, id: .hardDrop))
        let newKeyCode = mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode
        #expect(oldKeyCode == newKeyCode)
    }

    @Test func testRebindingImmutable() async throws {
        let mapper = InputMapper()
        let oldKeyCode = mapper.keyboardBindings.first { $0.id == .menu }?.keyCode
        #expect(!mapper.bind(keyCode: KeyCode.z.rawValue, id: .menu))
        let newKeyCode = mapper.keyboardBindings.first { $0.id == .menu }?.keyCode
        #expect(oldKeyCode == newKeyCode)
    }

    @Test func testBindUnmappableKeyCodeReturnsFalse() async throws {
        let mapper = InputMapper()
        #expect(!mapper.bind(keyCode: KeyCode.escape.rawValue, id: .hardDrop))
        #expect(!mapper.bind(keyCode: KeyCode.return.rawValue, id: .softDrop))
    }

    @Test func testKeyboardBindingsSetterOverwritesBindings() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.x.rawValue, id: .hardDrop))
        #expect(mapper.bind(keyCode: KeyCode.y.rawValue, id: .softDrop))
        #expect(mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode == KeyCode.x.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .softDrop }?.keyCode == KeyCode.y.rawValue)

        mapper.keyboardBindings = [
            InputMapper.KeyBinding(keyCode: KeyCode.y.rawValue, id: .hardDrop),
            InputMapper.KeyBinding(keyCode: KeyCode.x.rawValue, id: .softDrop)
        ]

        #expect(mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode == KeyCode.y.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .softDrop }?.keyCode == KeyCode.x.rawValue)
    }

    @Test func testKeyboardBindingsSetterPreservesOmittedBindings() async throws {
        let mapper = InputMapper()
        mapper.keyboardBindings = [
            InputMapper.KeyBinding(keyCode: KeyCode.x.rawValue, id: .hardDrop)
        ]

        #expect(mapper.keyboardBindings.count == 6)
        #expect(mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode == KeyCode.x.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .softDrop }?.keyCode == KeyCode.arrowDown.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .rotateClockwise }?.keyCode == KeyCode.s.rawValue)
    }

    @Test func testKeyboardBindingsSetterPreservesDefaultsForEmptyConfiguration() async throws {
        let mapper = InputMapper()
        mapper.keyboardBindings = []

        #expect(mapper.keyboardBindings.count == 6)
        #expect(mapper.keyboardBindings.first { $0.id == .shiftLeft }?.keyCode == KeyCode.arrowLeft.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode == KeyCode.space.rawValue)
    }

    @Test func testBindAlreadyBoundKeyReturnsFalse() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.x.rawValue, id: .hardDrop))
        #expect(mapper.bind(keyCode: KeyCode.y.rawValue, id: .softDrop))
        #expect(mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode == KeyCode.x.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .softDrop }?.keyCode == KeyCode.y.rawValue)

        #expect(!mapper.bind(keyCode: KeyCode.x.rawValue, id: .softDrop))
        #expect(mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode == KeyCode.x.rawValue)
        #expect(mapper.keyboardBindings.first { $0.id == .softDrop }?.keyCode == KeyCode.y.rawValue)
    }
}

struct InputEventTests {
    @Test func testEquality() async throws {
        let lhs = InputEvent(id: .hardDrop, isDown: true, source: .keyboard)
        let rhs = InputEvent(id: .hardDrop, isDown: true, source: .keyboard)
        #expect(lhs == rhs)
    }

    @Test func testInequalityDifferentIsDown() async throws {
        let lhs = InputEvent(id: .hardDrop, isDown: true, source: .keyboard)
        let rhs = InputEvent(id: .hardDrop, isDown: false, source: .keyboard)
        #expect(lhs != rhs)
    }

    @Test func testInequalityDifferentId() async throws {
        let lhs = InputEvent(id: .hardDrop, isDown: true, source: .keyboard)
        let rhs = InputEvent(id: .softDrop, isDown: true, source: .keyboard)
        #expect(lhs != rhs)
    }

    @Test func testDescription() async throws {
        #expect(InputEvent(id: .shiftLeft, isDown: true, source: .keyboard).description == "↓shift left")
        #expect(InputEvent(id: .shiftLeft, isDown: false, source: .keyboard).description == "↑shift left")
        #expect(InputEvent(id: .shiftLeft, isDown: true, source: .keyboard, isARepeat: true).description == "↓shift left (repeated)")
    }

}

struct InputMapperTranslateKeyboardTests {
    private func makeKeyEvent(with type: NSEvent.EventType, keyCode: UInt16, isARepeat: Bool = false) -> NSEvent {
        NSEvent.keyEvent(with: type,
                         location: .zero,
                         modifierFlags: [],
                         timestamp: 0,
                         windowNumber: 0,
                         context: nil,
                         characters: "",
                         charactersIgnoringModifiers: "",
                         isARepeat: type == .keyDown && isARepeat,
                         keyCode: keyCode)!
        // swiftlint:disable:previous force_unwrapping
    }

    private func makeFlagsChangedEvent(with keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags) -> NSEvent {
        NSEvent.keyEvent(with: .flagsChanged,
                         location: .zero,
                         modifierFlags: modifierFlags,
                         timestamp: 0,
                         windowNumber: 0,
                         context: nil,
                         characters: "",
                         charactersIgnoringModifiers: "",
                         isARepeat: false,
                         keyCode: keyCode)!
        // swiftlint:disable:previous force_unwrapping
    }

    @Test func testTranslateBoundKeyDown() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.x.rawValue, id: .hardDrop))
        let events = mapper.translate(event: makeKeyEvent(with: .keyDown, keyCode: KeyCode.x.rawValue))
        #expect(events.count == 1)
        #expect(events.first?.id == .hardDrop)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateBoundKeyUp() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.x.rawValue, id: .hardDrop))
        let events = mapper.translate(event: makeKeyEvent(with: .keyUp, keyCode: KeyCode.x.rawValue))
        #expect(events.count == 1)
        #expect(events.first?.id == .hardDrop)
        #expect(events.first?.isDown == false)
    }

    @Test func testTranslateUnboundKeyEmpty() async throws {
        let mapper = InputMapper()
        #expect(mapper.translate(event: makeKeyEvent(with: .keyUp, keyCode: KeyCode.x.rawValue)).isEmpty)
        #expect(mapper.translate(event: makeKeyEvent(with: .keyDown, keyCode: KeyCode.x.rawValue)).isEmpty)
    }

    @Test func testTranslateKeyDownArrowLeftReturnsFirstShiftLeftAndThenLeft() async throws {
        let mapper = InputMapper()
        let events = mapper.translate(event: makeKeyEvent(with: .keyDown, keyCode: KeyCode.arrowLeft.rawValue))
        #expect(events.count == 2)
        #expect(events[0].id == .left)
        #expect(events[0].isDown == true)
        #expect(events[1].id == .shiftLeft)
        #expect(events[1].isDown == true)
    }

    @Test func testTranslateNavigationKeyAlsoBoundToGameplayAction() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.arrowUp.rawValue, id: .hardDrop))

        let events = mapper.translate(event: makeKeyEvent(with: .keyDown, keyCode: KeyCode.arrowUp.rawValue))

        #expect(events.count == 2)
        #expect(events[0].id == .up)
        #expect(events[0].isDown)
        #expect(events[1].id == .hardDrop)
        #expect(events[1].isDown)
    }

    @Test func testTranslateKeyboardRespectsRepeat() async throws {
        let mapper = InputMapper()
        #expect(mapper.translate(event: makeKeyEvent(with: .keyDown, keyCode: KeyCode.space.rawValue, isARepeat: true)).first?.isARepeat == true)
        #expect(mapper.translate(event: makeKeyEvent(with: .keyDown, keyCode: KeyCode.space.rawValue, isARepeat: false)).first?.isARepeat == false)
    }

    @Test func testTranslateModifierKeyDown() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.shift.rawValue, id: .hardDrop))

        let events = mapper.translate(event: makeFlagsChangedEvent(with: KeyCode.shift.rawValue, modifierFlags: .shift))

        #expect(events == [InputEvent(id: .hardDrop, isDown: true, source: .keyboard)])
    }

    @Test func testTranslateModifierKeyUp() async throws {
        let mapper = InputMapper()
        #expect(mapper.bind(keyCode: KeyCode.shift.rawValue, id: .hardDrop))

        let events = mapper.translate(event: makeFlagsChangedEvent(with: KeyCode.shift.rawValue, modifierFlags: []))

        #expect(events == [InputEvent(id: .hardDrop, isDown: false, source: .keyboard)])
    }

    @Test func testTranslateUnboundModifierEmpty() async throws {
        let mapper = InputMapper()

        let events = mapper.translate(event: makeFlagsChangedEvent(with: KeyCode.shift.rawValue, modifierFlags: .shift))

        #expect(events.isEmpty)
    }

    @Test func testTranslateOtherEventTypeReturnsEmpty() async throws {
        let mapper = InputMapper()
        let event = NSEvent.mouseEvent(
            with: .leftMouseDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            eventNumber: 0,
            clickCount: 1,
            pressure: 0
        )
        // swiftlint:disable:next force_unwrapping
        #expect(mapper.translate(event: event!).isEmpty)
    }
}

struct InputMapperTranslateGamepadTests {

    @Test func testTranslateDpadLeftPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: true, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)
        #expect(events[0].id == .shiftLeft)
        #expect(events[0].isDown == true)
        #expect(events[1].id == .shiftRight)
        #expect(events[1].isDown == false)
        #expect(events[2].id == .softDrop)
        #expect(events[2].isDown == false)
        #expect(events[3].id == .left)
        #expect(events[3].isDown == true)
        #expect(events[4].id == .right)
        #expect(events[4].isDown == false)
        #expect(events[5].id == .down)
        #expect(events[5].isDown == false)
        #expect(events[6].id == .up)
        #expect(events[6].isDown == false)
    }

    @Test func testTranslateDpadRightPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: true, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)
        #expect(events[0].id == .shiftLeft)
        #expect(events[0].isDown == false)
        #expect(events[1].id == .shiftRight)
        #expect(events[1].isDown == true)
        #expect(events[2].id == .softDrop)
        #expect(events[2].isDown == false)
        #expect(events[3].id == .left)
        #expect(events[3].isDown == false)
        #expect(events[4].id == .right)
        #expect(events[4].isDown == true)
        #expect(events[5].id == .down)
        #expect(events[5].isDown == false)
        #expect(events[6].id == .up)
        #expect(events[6].isDown == false)
    }

    @Test func testTranslateDpadUpPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: true, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)
        #expect(events[0].id == .shiftLeft)
        #expect(events[0].isDown == false)
        #expect(events[1].id == .shiftRight)
        #expect(events[1].isDown == false)
        #expect(events[2].id == .softDrop)
        #expect(events[2].isDown == false)
        #expect(events[3].id == .left)
        #expect(events[3].isDown == false)
        #expect(events[4].id == .right)
        #expect(events[4].isDown == false)
        #expect(events[5].id == .down)
        #expect(events[5].isDown == false)
        #expect(events[6].id == .up)
        #expect(events[6].isDown == true)
    }

    @Test func testTranslateDpadDownPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: true, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)
        #expect(events[0].id == .shiftLeft)
        #expect(events[0].isDown == false)
        #expect(events[1].id == .shiftRight)
        #expect(events[1].isDown == false)
        #expect(events[2].id == .softDrop)
        #expect(events[2].isDown == true)
        #expect(events[3].id == .left)
        #expect(events[3].isDown == false)
        #expect(events[4].id == .right)
        #expect(events[4].isDown == false)
        #expect(events[5].id == .down)
        #expect(events[5].isDown == true)
        #expect(events[6].id == .up)
        #expect(events[6].isDown == false)
    }

    @Test func testTranslateButtonAPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: true, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonA)
        #expect(events.count == 1)
        #expect(events[0].id == .rotateCounterClockwise)
        #expect(events[0].isDown == true)
    }

    @Test func testTranslateButtonBPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: true, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonB)
        #expect(events.count == 2)
        #expect(events[0].id == .rotateClockwise)
        #expect(events[0].isDown == true)
        #expect(events[1].id == .select)
        #expect(events[1].isDown == true)
    }

    @Test func testTranslateButtonYPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: true, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonY)
        #expect(events.count == 1)
        #expect(events[0].id == .hardDrop)
        #expect(events[0].isDown == true)
    }

    @Test func testTranslateButtonMenuPressed() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: true)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonMenu)
        #expect(events.count == 1)
        #expect(events[0].id == .menu)
        #expect(events[0].isDown == true)
    }

    @Test func testTranslateDpadReleased() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)
        #expect(events[0].id == .shiftLeft)
        #expect(events[0].isDown == false)
        #expect(events[1].id == .shiftRight)
        #expect(events[1].isDown == false)
        #expect(events[2].id == .softDrop)
        #expect(events[2].isDown == false)
        #expect(events[3].id == .left)
        #expect(events[3].isDown == false)
        #expect(events[4].id == .right)
        #expect(events[4].isDown == false)
        #expect(events[5].id == .down)
        #expect(events[5].isDown == false)
        #expect(events[6].id == .up)
        #expect(events[6].isDown == false)
    }

    @Test func testTranslateButtonAReleased() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonA)
        #expect(events.count == 1)
        #expect(events[0].id == .rotateCounterClockwise)
        #expect(events[0].isDown == false)
    }

    @Test func testTranslateButtonBReleased() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonB)
        #expect(events.count == 2)
        #expect(events[0].id == .rotateClockwise)
        #expect(events[0].isDown == false)
        #expect(events[1].id == .select)
        #expect(events[1].isDown == false)
    }

    @Test func testTranslateButtonYReleased() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonY)
        #expect(events.count == 1)
        #expect(events[0].id == .hardDrop)
        #expect(events[0].isDown == false)
    }

    @Test func testTranslateButtonMenuReleased() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonMenu)
        #expect(events.count == 1)
        #expect(events[0].id == .menu)
        #expect(events[0].isDown == false)
    }

    @Test func testTranslateUnrelatedElementReturnsEmpty() async throws {
        let mapper = InputMapper()
        let gamepad = MockExtendedGamepad(left: false, right: false, up: false, down: false, a: false, b: false, y: false, menu: false)
        #expect(mapper.translate(gamepad: gamepad, element: gamepad.buttonX).isEmpty)
        #expect(mapper.translate(gamepad: gamepad, element: gamepad.leftTrigger).isEmpty)
        #expect(mapper.translate(gamepad: gamepad, element: gamepad.leftShoulder).isEmpty)
        #expect(mapper.translate(gamepad: gamepad, element: gamepad.rightThumbstickButton).isEmpty)
        #expect(mapper.translate(gamepad: gamepad, element: gamepad.rightTrigger).isEmpty)
        #expect(mapper.translate(gamepad: gamepad, element: gamepad.rightShoulder).isEmpty)
    }
}

struct InputMapperTranslateMicroGamepadTests {
    @Test func testTranslateDpad() async throws {
        let mapper = InputMapper()
        let gamepad = MockMicroGamepad(left: true, right: false, up: false, down: false, a: false, buttonXPressed: false, menu: false)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)

        #expect(events.count == 7)
        #expect(events[0] == InputEvent(id: .shiftLeft, isDown: true, source: .controller))
        #expect(events[1] == InputEvent(id: .shiftRight, isDown: false, source: .controller))
        #expect(events[2] == InputEvent(id: .softDrop, isDown: false, source: .controller))
        #expect(events[3] == InputEvent(id: .left, isDown: true, source: .controller))
        #expect(events[4] == InputEvent(id: .right, isDown: false, source: .controller))
        #expect(events[5] == InputEvent(id: .down, isDown: false, source: .controller))
        #expect(events[6] == InputEvent(id: .up, isDown: false, source: .controller))
    }

    @Test func testTranslateButtons() async throws {
        let mapper = InputMapper()
        let gamepad = MockMicroGamepad(left: false, right: false, up: false, down: false, a: true, buttonXPressed: true, menu: true)

        let aEvents = mapper.translate(gamepad: gamepad, element: gamepad.buttonA)
        #expect(aEvents == [InputEvent(id: .rotateCounterClockwise, isDown: true, source: .controller)])

        let xEvents = mapper.translate(gamepad: gamepad, element: gamepad.buttonX)
        #expect(xEvents == [
            InputEvent(id: .rotateClockwise, isDown: true, source: .controller),
            InputEvent(id: .select, isDown: true, source: .controller)
        ])

        let menuEvents = mapper.translate(gamepad: gamepad, element: gamepad.buttonMenu)
        #expect(menuEvents == [InputEvent(id: .menu, isDown: true, source: .controller)])
    }

    @Test func testTranslateUnrelatedElementReturnsEmpty() async throws {
        let mapper = InputMapper()
        let gamepad = MockMicroGamepad(left: false, right: false, up: false, down: false, a: false, buttonXPressed: false, menu: false)
        #expect(mapper.translate(gamepad: gamepad, element: MockButtonInput()).isEmpty)
    }
}
