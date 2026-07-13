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

extension Appearance: Adjustable {
    func increased() -> Appearance {
        return Appearance(rawValue: self.rawValue + 1) ?? .plain
    }

    func decreased() -> Appearance {
        return Appearance(rawValue: self.rawValue - 1) ?? .bright
    }
}
