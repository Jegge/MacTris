//
//  GameControllerMocks.swift
//  MacTrisTests
//
//  Created by OpenCode on 13.07.26.
//

import GameController

class MockButtonInput: GCControllerButtonInput {
    var mockPressed = false
    override var isPressed: Bool { mockPressed }
    override var value: Float { mockPressed ? 1.0 : 0.0 }
}

class MockDirectionPad: GCControllerDirectionPad {
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
    var mockDpad = MockDirectionPad()
    var mockButtonA = MockButtonInput()
    var mockButtonB = MockButtonInput()
    var mockButtonY = MockButtonInput()
    var mockButtonMenu = MockButtonInput()
    override var dpad: GCControllerDirectionPad { mockDpad }
    override var buttonA: GCControllerButtonInput { mockButtonA }
    override var buttonB: GCControllerButtonInput { mockButtonB }
    override var buttonY: GCControllerButtonInput { mockButtonY }
    override var buttonMenu: GCControllerButtonInput { mockButtonMenu }
}
