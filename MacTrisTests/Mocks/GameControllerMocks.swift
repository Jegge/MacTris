//
//  GameControllerMocks.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import GameController

class MockButtonInput: GCControllerButtonInput {
    init (pressed: Bool = false) {
        mockPressed = pressed
    }
    var mockPressed = false
    override var isPressed: Bool { mockPressed }
    override var value: Float { mockPressed ? 1.0 : 0.0 }
}

class MockDirectionPad: GCControllerDirectionPad {
    init (left: Bool, right: Bool, up: Bool, down: Bool) {
        self.mockLeft = MockButtonInput(pressed: left)
        self.mockRight = MockButtonInput(pressed: right)
        self.mockUp = MockButtonInput(pressed: up)
        self.mockDown = MockButtonInput(pressed: down)
    }
    var mockLeft = MockButtonInput()
    var mockRight = MockButtonInput()
    var mockUp = MockButtonInput()
    var mockDown = MockButtonInput()
    override var left: GCControllerButtonInput { mockLeft }
    override var right: GCControllerButtonInput { mockRight }
    override var up: GCControllerButtonInput { mockUp }
    override var down: GCControllerButtonInput { mockDown }
}

class MockExtendedGamepad: GCExtendedGamepad {
    init (left: Bool, right: Bool, up: Bool, down: Bool, a: Bool, b: Bool, y: Bool, menu: Bool) {
        self.mockDpad = MockDirectionPad(left: left, right: right, up: up, down: down)
        self.mockButtonA = MockButtonInput(pressed: a)
        self.mockButtonB = MockButtonInput(pressed: b)
        self.mockButtonY = MockButtonInput(pressed: y)
        self.mockButtonMenu = MockButtonInput(pressed: menu)
    }

    var mockDpad = MockDirectionPad(left: false, right: false, up: false, down: false)
    var mockButtonA = MockButtonInput()
    var mockButtonB = MockButtonInput()
    var mockButtonY = MockButtonInput()
    var mockButtonMenu = MockButtonInput()
    override var dpad: GCControllerDirectionPad { mockDpad }
    override var buttonA: GCControllerButtonInput { mockButtonA }
    override var buttonB: GCControllerButtonInput { mockButtonB }
    override var buttonY: GCControllerButtonInput { mockButtonY }
    override var buttonMenu: GCControllerButtonInput { mockButtonMenu }
    override var buttonX: GCControllerButtonInput { MockButtonInput() }
    override var leftTrigger: GCControllerButtonInput { MockButtonInput() }
    override var leftShoulder: GCControllerButtonInput { MockButtonInput() }
    override var leftThumbstickButton: GCControllerButtonInput { MockButtonInput() }
    override var rightTrigger: GCControllerButtonInput { MockButtonInput() }
    override var rightShoulder: GCControllerButtonInput { MockButtonInput() }
    override var rightThumbstickButton: GCControllerButtonInput { MockButtonInput() }
}
