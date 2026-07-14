//
//  Input.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

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
    case hardDrop
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
        case .hardDrop: "hard drop"
        }
    }
}

enum InputSource: Codable {
    case keyboard
    case controller
}
