//
//  KeyBindings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation

public struct KeyBindings {
    static let quit: UInt16 = 53 // ESC
    static let pause: UInt16 = 35 // P
    static let select: UInt16 = 49 // enter

    static let enter: UInt16 = 36 // enter
    static let backspace: UInt16 = 51 // backspace

    static let down: UInt16 = 125 // arrow down
    static let up: UInt16 = 126 // arrow up
    static let left: UInt16 = 123 // arrow left
    static let right: UInt16 = 124 // arrow right

    static let moveLeft: UInt16 = 123 // arrow left
    static let moveRight: UInt16 = 124 // arrow right
    static let softDrop: UInt16 = 125 // arrow down
    static let rotateLeft: UInt16 = 0 // A
    static let rotateRight: UInt16 = 1 // S
}
