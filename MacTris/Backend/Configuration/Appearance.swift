//
//  Appearance.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation

enum Appearance: Int {
    case plain = 1
    case shaded = 2
    case bright = 3
}

extension Appearance: CustomStringConvertible {
    var description: String {
        switch self {
        case .plain: return NSLocalizedString("EnumAppearancePlain", comment: "Description of enum case Appearance.plain")
        case .shaded: return NSLocalizedString("EnumAppearanceShaded", comment: "Description of enum case Appearance.shaded")
        case .bright: return NSLocalizedString("EnumAppearanceBright", comment: "Description of enum case Appearance.bright")
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
