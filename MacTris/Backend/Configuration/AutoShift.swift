//
//  AutoShift.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.01.24.
//

import Foundation

enum AutoShift: Int {
    case nes = 1
    case modern = 2
    case fast = 3
    case insane = 4

    var delays: (initial: Int, repeating: Int) {
        switch self {
        case .nes: return (16, 6)
        case .modern: return (8, 6)
        case .fast: return (6, 3)
        case .insane: return (5, 1)
        }
    }
}

extension AutoShift: CustomStringConvertible {
    var description: String {
        switch self {
        case .nes: return NSLocalizedString("EnumAutoShiftNes", comment: "Description of enum case AutoShift.nes")
        case .modern: return NSLocalizedString("EnumAutoShiftModern", comment: "Description of enum case AutoShift.modern")
        case .fast: return NSLocalizedString("EnumAutoShiftFast", comment: "Description of enum case AutoShift.fast")
        case .insane: return NSLocalizedString("EnumAutoShiftInsane", comment: "Description of enum case AutoShift.insane")
        }
    }
}

extension AutoShift: Adjustable {
    func increased() -> AutoShift {
        return AutoShift(rawValue: self.rawValue + 1) ?? .nes
    }

    func decreased() -> AutoShift {
        return AutoShift(rawValue: self.rawValue - 1) ?? .insane
    }
}
