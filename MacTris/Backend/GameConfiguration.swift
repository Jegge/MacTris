//
//  GameConfiguration.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.01.24.
//

import Foundation

enum RandomGeneratorMode: Int {
    case nes = 1
    case sevenBag = 2

    func increase() -> RandomGeneratorMode {
        return RandomGeneratorMode(rawValue: self.rawValue + 1) ?? .nes
    }

    func decrease() -> RandomGeneratorMode {
        return RandomGeneratorMode(rawValue: self.rawValue - 1) ?? .sevenBag
    }

    func createGenerator() -> RandomTetrominoShapeGenerator {
        switch self {
        case .nes:
            return NesTetrominoShapeGenerator()
        case .sevenBag:
            return SevenBagTetrominoShapeGenerator()
        }
    }
}

extension RandomGeneratorMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .nes: return "Classic (NES)"
        case .sevenBag: return "Modern (7-Bag)"
        }
    }
}

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

    func increase() -> AutoShift {
        return AutoShift(rawValue: self.rawValue + 1) ?? .nes
    }

    func decrease() -> AutoShift {
        return AutoShift(rawValue: self.rawValue - 1) ?? .insane
    }
}

extension AutoShift: CustomStringConvertible {
    var description: String {
        switch self {
        case .nes: return "Classic (16–6)"
        case .modern: return "Modern (8–6)"
        case .fast: return "Fast (6–3)"
        case .insane: return "Insane (5–1)"
        }
    }
}
