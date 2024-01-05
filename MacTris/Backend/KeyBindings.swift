//
//  KeyBindings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

public struct KeyBindings {
    static let quit = KeyCode.escape.rawValue
    static let pause = KeyCode.escape.rawValue
    static let select = KeyCode.space.rawValue
    static let enter = KeyCode.return.rawValue
    static let backspace = KeyCode.delete.rawValue

    static let down = KeyCode.arrowDown.rawValue
    static let up = KeyCode.arrowUp.rawValue
    static let left = KeyCode.arrowLeft.rawValue
    static let right = KeyCode.arrowRight.rawValue

    static var moveLeft = KeyCode.arrowLeft.rawValue
    static var moveRight = KeyCode.arrowRight.rawValue
    static var softDrop = KeyCode.arrowDown.rawValue
    static var rotateLeft = KeyCode.a.rawValue
    static var rotateRight = KeyCode.s.rawValue
}
