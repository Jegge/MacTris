//
//  AutoShift.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.01.24.
//

import Foundation

/// Auto-shift (DAS) presets that determine how quickly a held direction key
/// starts to repeat and how fast it repeats.
enum AutoShift: Int {
    /// NES-style DAS: 16 frames initial delay, 6 frames repeat.
    case nes = 1
    /// Modern DAS: 8 frames initial delay, 6 frames repeat.
    case modern = 2
    /// Fast DAS: 6 frames initial delay, 3 frames repeat.
    case fast = 3
    /// Insane DAS: 5 frames initial delay, 1 frame repeat.
    case insane = 4

    /// The (initial delay, repeat delay) in frames.
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

extension AutoShift: Adjustable { }
