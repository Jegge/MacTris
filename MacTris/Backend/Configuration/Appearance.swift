//
//  Appearance.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

enum Appearance: Int {
    case plain = 1
    case shaded = 2
    case bright = 3

    func increase() -> Appearance {
        return Appearance(rawValue: self.rawValue + 1) ?? .plain
    }

    func decrease() -> Appearance {
        return Appearance(rawValue: self.rawValue - 1) ?? .bright
    }
}

extension Appearance: CustomStringConvertible {
    var description: String {
        switch self {
        case .plain: return "Plain"
        case .shaded: return "Shaded"
        case .bright: return "Bright"
        }
    }
}
