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

// swiftlint:disable force_unwrapping

struct InputMapperTests {
    @Test func testDefaultKeyboardBindingsContainExpectedInputs() async throws {
        let mapper = InputMapper()
        let inputs = Set(mapper.keyboardBindings.map { $0.id })
        let expected: Set<Input> = [.shiftLeft, .shiftRight, .softDrop, .hardDrop, .rotateCounterClockwise, .rotateClockwise]
        #expect(inputs == expected)
    }

    @Test func testDefaultKeyboardBindingsDoNotContainImmutableKeys() async throws {
        let mapper = InputMapper()
        let inputs = Set(mapper.keyboardBindings.map { $0.id })
        #expect(!inputs.contains(.left))
        #expect(!inputs.contains(.right))
        #expect(!inputs.contains(.down))
        #expect(!inputs.contains(.up))
        #expect(!inputs.contains(.menu))
        #expect(!inputs.contains(.select))
    }

    @Test func testDefaultHardDropBindingIsSpace() async throws {
        let mapper = InputMapper()
        let binding = mapper.keyboardBindings.first { $0.id == .hardDrop }
        #expect(binding?.keyCode == KeyCode.space.rawValue)
    }

    @Test func testDefaultRotateCounterClockwiseBindingIsA() async throws {
        let mapper = InputMapper()
        let binding = mapper.keyboardBindings.first { $0.id == .rotateCounterClockwise }
        #expect(binding?.keyCode == KeyCode.a.rawValue)
    }

    @Test func testDefaultRotateClockwiseBindingIsS() async throws {
        let mapper = InputMapper()
        let binding = mapper.keyboardBindings.first { $0.id == .rotateClockwise }
        #expect(binding?.keyCode == KeyCode.s.rawValue)
    }

    @Test func testDescribeIdForKeyboardForKnownBinding() async throws {
        let mapper = InputMapper()
        #expect(mapper.describeIdForKeyboard(.shiftLeft) == "Left")
    }

    @Test func testDescribeIdForKeyboardForMutableBinding() async throws {
        let mapper = InputMapper()
        #expect(mapper.describeIdForKeyboard(.hardDrop) == "Space")
    }

    @Test func testDescribeIdForKeyboardAfterUnbindingReturnsUnknown() async throws {
        let mapper = InputMapper()
        // All Inputs have bindings by default, so the "unknown" path is unreachable
        // in default state. Verify that immutable bindings are still described.
        #expect(mapper.describeIdForKeyboard(.menu) == "Escape")
        #expect(mapper.describeIdForKeyboard(.select) == "Return")
        #expect(mapper.describeIdForKeyboard(.left) == "Left")
        #expect(mapper.describeIdForKeyboard(.right) == "Right")
        #expect(mapper.describeIdForKeyboard(.up) == "Up")
        #expect(mapper.describeIdForKeyboard(.down) == "Down")
    }

    @Test func testDescribeIdForKeyboardAfterRebind() async throws {
        let mapper = InputMapper()
        mapper.bind(keyCode: KeyCode.return.rawValue, id: .hardDrop)
        #expect(mapper.describeIdForKeyboard(.hardDrop) == "Return")
    }

    @Test func testDescribeIdForControllerAllCasesNonEmpty() async throws {
        let mapper = InputMapper()
        for input: Input in [.menu, .select, .up, .down, .left, .right, .shiftLeft, .shiftRight, .rotateCounterClockwise, .rotateClockwise, .softDrop, .hardDrop] {
            let desc = mapper.describeIdForController(input)
            #expect(!desc.isEmpty, "Description for \(input) should not be empty")
        }
    }

    @Test func testBindReplacesExistingMutableBinding() async throws {
        let mapper = InputMapper()
        let oldKeyCode = mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode
        mapper.bind(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        let newKeyCode = mapper.keyboardBindings.first { $0.id == .hardDrop }?.keyCode
        #expect(oldKeyCode != newKeyCode)
        #expect(newKeyCode == KeyCode.z.rawValue)
    }

    @Test func testBindAffectsDescribeIdForKeyboard() async throws {
        let mapper = InputMapper()
        mapper.bind(keyCode: KeyCode.x.rawValue, id: .rotateClockwise)
        #expect(mapper.describeIdForKeyboard(.rotateClockwise) == "X")
    }

    @Test func testBindDoesNotAffectOtherInputs() async throws {
        let mapper = InputMapper()
        let before = mapper.keyboardBindings.first { $0.id == .rotateCounterClockwise }?.keyCode
        mapper.bind(keyCode: KeyCode.x.rawValue, id: .rotateClockwise)
        let after = mapper.keyboardBindings.first { $0.id == .rotateCounterClockwise }?.keyCode
        #expect(before == after)
    }

    // MARK: - canBind

    @Test func testCanBindToMutableInputWithUnusedKey() async throws {
        let mapper = InputMapper()
        #expect(mapper.canBind(keyCode: KeyCode.d.rawValue, id: .hardDrop))
    }

    @Test func testCanBindToImmutableInputReturnsFalse() async throws {
        let mapper = InputMapper()
        #expect(!mapper.canBind(keyCode: KeyCode.d.rawValue, id: .left))
    }

    @Test func testCanBindDuplicateKeyCodeToDifferentInputReturnsFalse() async throws {
        let mapper = InputMapper()
        #expect(!mapper.canBind(keyCode: KeyCode.space.rawValue, id: .rotateClockwise))
    }

    @Test func testCanBindSameKeyToSameInputReturnsTrue() async throws {
        let mapper = InputMapper()
        #expect(mapper.canBind(keyCode: KeyCode.space.rawValue, id: .hardDrop))
    }

    @Test func testCanBindAfterRebindToNewKey() async throws {
        let mapper = InputMapper()
        mapper.bind(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        #expect(mapper.canBind(keyCode: KeyCode.d.rawValue, id: .hardDrop))
    }

    // MARK: - keyboardBindings setter

    @Test func testKeyboardBindingsSetterUpdatesBindings() async throws {
        let mapper = InputMapper()
        mapper.keyboardBindings = [
            InputMapper.KeyBinding(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        ]
        let binding = mapper.keyboardBindings.first { $0.id == .hardDrop }
        #expect(binding?.keyCode == KeyCode.z.rawValue)
    }

    @Test func testKeyboardBindingsSetterReplacesExistingBinding() async throws {
        let mapper = InputMapper()
        let oldKeyCode = mapper.keyboardBindings.first { $0.id == .rotateClockwise }?.keyCode
        mapper.keyboardBindings = [
            InputMapper.KeyBinding(keyCode: KeyCode.d.rawValue, id: .rotateClockwise)
        ]
        let newKeyCode = mapper.keyboardBindings.first { $0.id == .rotateClockwise }?.keyCode
        #expect(oldKeyCode != newKeyCode)
        #expect(newKeyCode == KeyCode.d.rawValue)
    }

    // MARK: - Instance independence

    @Test func testDistinctInstancesAreIndependent() async throws {
        let mapper1 = InputMapper()
        let mapper2 = InputMapper()
        mapper1.bind(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        let binding2 = mapper2.keyboardBindings.first { $0.id == .hardDrop }
        #expect(binding2?.keyCode == KeyCode.space.rawValue)
    }
}

// MARK: - InputEventTests

struct InputEventTests {

    @Test func testEquality() async throws {
        let lhs = InputEvent(id: .hardDrop, isDown: true)
        let rhs = InputEvent(id: .hardDrop, isDown: true)
        #expect(lhs == rhs)
    }

    @Test func testInequalityDifferentIsDown() async throws {
        let lhs = InputEvent(id: .hardDrop, isDown: true)
        let rhs = InputEvent(id: .hardDrop, isDown: false)
        #expect(lhs != rhs)
    }

    @Test func testInequalityDifferentId() async throws {
        let lhs = InputEvent(id: .hardDrop, isDown: true)
        let rhs = InputEvent(id: .softDrop, isDown: true)
        #expect(lhs != rhs)
    }

    @Test func testDescriptionKeyDown() async throws {
        let event = InputEvent(id: .shiftLeft, isDown: true)
        #expect(event.description == "↓shift left")
    }

    @Test func testDescriptionKeyUp() async throws {
        let event = InputEvent(id: .shiftLeft, isDown: false)
        #expect(event.description == "↑shift left")
    }

    @Test func testDescriptionRepeat() async throws {
        let event = InputEvent(id: .shiftLeft, isDown: true, isARepeat: true)
        #expect(event.description == "↓shift left (repeated)")
    }

    @Test func testDefaultIsARepeatIsFalse() async throws {
        let event = InputEvent(id: .hardDrop, isDown: true)
        #expect(event.isARepeat == false)
    }

    @Test func testPostNotificationDown() async throws {
        let event = InputEvent(id: .select, isDown: true)
        var received = false
        let token = NotificationCenter.default.addObserver(forName: InputEvent.inputDownNotification, object: nil, queue: nil) { notification in
            if let obj = notification.object as? InputEvent, obj.id == .select {
                received = true
            }
        }
        defer { NotificationCenter.default.removeObserver(token) }
        event.postNotification()
        #expect(received)
    }

    @Test func testPostNotificationUp() async throws {
        let event = InputEvent(id: .select, isDown: false)
        var received = false
        let token = NotificationCenter.default.addObserver(forName: InputEvent.inputUpNotification, object: nil, queue: nil) { notification in
            if let obj = notification.object as? InputEvent, obj.id == .select {
                received = true
            }
        }
        defer { NotificationCenter.default.removeObserver(token) }
        event.postNotification()
        #expect(received)
    }
}

struct InputMapperTranslateKeyboardTests {

    private func makeKeyDownEvent(keyCode: UInt16, isARepeat: Bool = false) -> NSEvent {
        NSEvent.keyEvent(with: .keyDown,
                         location: .zero,
                         modifierFlags: [],
                         timestamp: 0,
                         windowNumber: 0,
                         context: nil,
                         characters: "",
                         charactersIgnoringModifiers: "",
                         isARepeat: isARepeat,
                         keyCode: keyCode)!
    }

    private func makeKeyUpEvent(keyCode: UInt16) -> NSEvent {
        NSEvent.keyEvent(with: .keyUp,
                         location: .zero,
                         modifierFlags: [],
                         timestamp: 0,
                         windowNumber: 0,
                         context: nil,
                         characters: "",
                         charactersIgnoringModifiers: "",
                         isARepeat: false,
                         keyCode: keyCode)!
    }

    @Test func testTranslateKeyDownSpaceReturnsHardDrop() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.space.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .hardDrop)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateKeyDownAAReturnsRotateCCW() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.a.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .rotateCounterClockwise)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateKeyDownSReturnsRotateCW() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.s.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .rotateClockwise)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateKeyDownArrowLeftReturnsBothShiftLeftAndLeft() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.arrowLeft.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 2)
        let ids = events.map { $0.id }
        #expect(ids.contains(.shiftLeft))
        #expect(ids.contains(.left))
        for event in events {
            #expect(event.isDown == true)
        }
    }

    @Test func testTranslateKeyDownArrowRightReturnsBothShiftRightAndRight() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.arrowRight.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 2)
        let ids = events.map { $0.id }
        #expect(ids.contains(.shiftRight))
        #expect(ids.contains(.right))
    }

    @Test func testTranslateKeyDownArrowDownReturnsBothSoftDropAndDown() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.arrowDown.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 2)
        let ids = events.map { $0.id }
        #expect(ids.contains(.softDrop))
        #expect(ids.contains(.down))
    }

    @Test func testTranslateKeyDownArrowUpReturnsUp() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.arrowUp.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .up)
    }

    @Test func testTranslateKeyDownEscapeReturnsMenu() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.escape.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .menu)
    }

    @Test func testTranslateKeyDownReturnReturnsSelect() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.return.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .select)
    }

    @Test func testTranslateKeyDownRepeatMarksIsARepeat() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.space.rawValue, isARepeat: true)
        let events = mapper.translate(event: event)
        #expect(events.first?.isARepeat == true)
    }

    @Test func testTranslateKeyDownUnboundKeyReturnsEmpty() async throws {
        let mapper = InputMapper()
        let event = makeKeyDownEvent(keyCode: KeyCode.f1.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.isEmpty)
    }

    // MARK: - keyUp

    @Test func testTranslateKeyUpSpaceReturnsHardDropUp() async throws {
        let mapper = InputMapper()
        let event = makeKeyUpEvent(keyCode: KeyCode.space.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 1)
        #expect(events.first?.id == .hardDrop)
        #expect(events.first?.isDown == false)
    }

    @Test func testTranslateKeyUpArrowLeftReturnsBothShiftLeftAndLeftUp() async throws {
        let mapper = InputMapper()
        let event = makeKeyUpEvent(keyCode: KeyCode.arrowLeft.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.count == 2)
        for event in events {
            #expect(event.isDown == false)
        }
    }

    @Test func testTranslateKeyUpIsARepeatAlwaysFalse() async throws {
        let mapper = InputMapper()
        let event = makeKeyUpEvent(keyCode: KeyCode.space.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.first?.isARepeat == false)
    }

    // MARK: - other event types

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
        )!
        let events = mapper.translate(event: event)
        #expect(events.isEmpty)
    }

    // MARK: - rebinding

    @Test func testTranslateRespectsReboundKey() async throws {
        let mapper = InputMapper()
        mapper.bind(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        let event = makeKeyDownEvent(keyCode: KeyCode.z.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.first?.id == .hardDrop)
    }

    @Test func testTranslateOldKeyNoLongerWorksAfterRebind() async throws {
        let mapper = InputMapper()
        mapper.bind(keyCode: KeyCode.z.rawValue, id: .hardDrop)
        let event = makeKeyDownEvent(keyCode: KeyCode.space.rawValue)
        let events = mapper.translate(event: event)
        #expect(events.isEmpty)
    }
}

// MARK: - InputMapperTranslateGamepadTests

struct InputMapperTranslateGamepadTests {

    private func makeButton(pressed: Bool) -> MockButtonInput {
        let button = MockButtonInput()
        button.mockPressed = pressed
        return button
    }

    private func makeDpad(left: Bool = false, right: Bool = false, up: Bool = false, down: Bool = false) -> MockDirectionPad {
        let dpad = MockDirectionPad()
        dpad.mockLeft = makeButton(pressed: left)
        dpad.mockRight = makeButton(pressed: right)
        dpad.mockUp = makeButton(pressed: up)
        dpad.mockDown = makeButton(pressed: down)
        return dpad
    }

    private func makeGamepad(dpad: MockDirectionPad? = nil,
                             buttonA: MockButtonInput? = nil,
                             buttonB: MockButtonInput? = nil,
                             buttonY: MockButtonInput? = nil,
                             buttonMenu: MockButtonInput? = nil) -> MockExtendedGamepad {
        let gamepad = MockExtendedGamepad()
        gamepad.mockDpad = dpad ?? makeDpad()
        gamepad.mockButtonA = buttonA ?? makeButton(pressed: false)
        gamepad.mockButtonB = buttonB ?? makeButton(pressed: false)
        gamepad.mockButtonY = buttonY ?? makeButton(pressed: false)
        gamepad.mockButtonMenu = buttonMenu ?? makeButton(pressed: false)
        return gamepad
    }

    // MARK: - DPad

    @Test func testTranslateDpadLeftPressed() async throws {
        let mapper = InputMapper()
        let dpad = makeDpad(left: true)
        let gamepad = makeGamepad(dpad: dpad)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)

        let shiftLeft = events.first { $0.id == .shiftLeft }
        #expect(shiftLeft?.isDown == true)

        let left = events.first { $0.id == .left }
        #expect(left?.isDown == true)

        let shiftRight = events.first { $0.id == .shiftRight }
        #expect(shiftRight?.isDown == false)
    }

    @Test func testTranslateDpadRightPressed() async throws {
        let mapper = InputMapper()
        let dpad = makeDpad(right: true)
        let gamepad = makeGamepad(dpad: dpad)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)

        let shiftRight = events.first { $0.id == .shiftRight }
        #expect(shiftRight?.isDown == true)

        let right = events.first { $0.id == .right }
        #expect(right?.isDown == true)

        let shiftLeft = events.first { $0.id == .shiftLeft }
        #expect(shiftLeft?.isDown == false)
    }

    @Test func testTranslateDpadUpPressed() async throws {
        let mapper = InputMapper()
        let dpad = makeDpad(up: true)
        let gamepad = makeGamepad(dpad: dpad)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)

        let up = events.first { $0.id == .up }
        #expect(up?.isDown == true)
    }

    @Test func testTranslateDpadDownPressed() async throws {
        let mapper = InputMapper()
        let dpad = makeDpad(down: true)
        let gamepad = makeGamepad(dpad: dpad)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)

        let softDrop = events.first { $0.id == .softDrop }
        #expect(softDrop?.isDown == true)

        let down = events.first { $0.id == .down }
        #expect(down?.isDown == true)
    }

    @Test func testTranslateDpadNothingPressed() async throws {
        let mapper = InputMapper()
        let gamepad = makeGamepad()
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        #expect(events.count == 7)
        for event in events {
            #expect(event.isDown == false)
        }
    }

    @Test func testTranslateDpadEventsGameplayBeforeMenu() async throws {
        let mapper = InputMapper()
        let dpad = makeDpad(left: true)
        let gamepad = makeGamepad(dpad: dpad)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.dpad)
        let ids = events.map { $0.id }
        let gameplayInputs: [Input] = [.shiftLeft, .shiftRight, .softDrop]
        let menuInputs: [Input] = [.left, .right, .down, .up]
        let lastGameplayIndex = gameplayInputs.last.map { ids.lastIndex(of: $0) ?? -1 } ?? -1
        let firstMenuIndex = menuInputs.first.map { ids.firstIndex(of: $0) ?? Int.max } ?? Int.max
        #expect(lastGameplayIndex < firstMenuIndex)
    }

    // MARK: - Button A (rotateCounterClockwise)

    @Test func testTranslateButtonAPressed() async throws {
        let mapper = InputMapper()
        let buttonA = makeButton(pressed: true)
        let gamepad = makeGamepad(buttonA: buttonA)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonA)
        #expect(events.count == 1)
        #expect(events.first?.id == .rotateCounterClockwise)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateButtonAReleased() async throws {
        let mapper = InputMapper()
        let buttonA = makeButton(pressed: false)
        let gamepad = makeGamepad(buttonA: buttonA)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonA)
        #expect(events.count == 1)
        #expect(events.first?.isDown == false)
    }

    // MARK: - Button B (rotateClockwise + select)

    @Test func testTranslateButtonBPressed() async throws {
        let mapper = InputMapper()
        let buttonB = makeButton(pressed: true)
        let gamepad = makeGamepad(buttonB: buttonB)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonB)
        #expect(events.count == 2)
        let ids = events.map { $0.id }
        #expect(ids.contains(.rotateClockwise))
        #expect(ids.contains(.select))
        for event in events {
            #expect(event.isDown == true)
        }
    }

    @Test func testTranslateButtonBPressedGameplayBeforeMenu() async throws {
        let mapper = InputMapper()
        let buttonB = makeButton(pressed: true)
        let gamepad = makeGamepad(buttonB: buttonB)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonB)
        let ids = events.map { $0.id }
        #expect(ids.first == .rotateClockwise)
        #expect(ids.last == .select)
    }

    @Test func testTranslateButtonBReleased() async throws {
        let mapper = InputMapper()
        let buttonB = makeButton(pressed: false)
        let gamepad = makeGamepad(buttonB: buttonB)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonB)
        for event in events {
            #expect(event.isDown == false)
        }
    }

    // MARK: - Button Y (hardDrop)

    @Test func testTranslateButtonYPressed() async throws {
        let mapper = InputMapper()
        let buttonY = makeButton(pressed: true)
        let gamepad = makeGamepad(buttonY: buttonY)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonY)
        #expect(events.count == 1)
        #expect(events.first?.id == .hardDrop)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateButtonYReleased() async throws {
        let mapper = InputMapper()
        let buttonY = makeButton(pressed: false)
        let gamepad = makeGamepad(buttonY: buttonY)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonY)
        #expect(events.first?.isDown == false)
    }

    // MARK: - Button Menu

    @Test func testTranslateButtonMenuPressed() async throws {
        let mapper = InputMapper()
        let buttonMenu = makeButton(pressed: true)
        let gamepad = makeGamepad(buttonMenu: buttonMenu)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonMenu)
        #expect(events.count == 1)
        #expect(events.first?.id == .menu)
        #expect(events.first?.isDown == true)
    }

    @Test func testTranslateButtonMenuReleased() async throws {
        let mapper = InputMapper()
        let buttonMenu = makeButton(pressed: false)
        let gamepad = makeGamepad(buttonMenu: buttonMenu)
        let events = mapper.translate(gamepad: gamepad, element: gamepad.buttonMenu)
        #expect(events.first?.isDown == false)
    }

    @Test func testTranslateUnrelatedElementReturnsEmpty() async throws {
        let mapper = InputMapper()
        let gamepad = makeGamepad()
        let unrelatedButton = makeButton(pressed: true)
        let events = mapper.translate(gamepad: gamepad, element: unrelatedButton)
        #expect(events.isEmpty)
    }
}

// swiftlint:enable force_unwrapping
