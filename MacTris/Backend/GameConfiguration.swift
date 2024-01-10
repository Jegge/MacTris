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

    func increase () -> RandomGeneratorMode {
        return self == .sevenBag ? .nes : .sevenBag
    }

    func decrease () -> RandomGeneratorMode {
        return self == .sevenBag ? .nes : .sevenBag

    }
}

extension RandomGeneratorMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .nes: return "Classic"
        case .sevenBag: return "Modern"
        }
    }
}

enum Appearance: Int {
    case plain = 1
    case shaded = 2
}

extension Appearance: CustomStringConvertible {
    var description: String {
        switch self {
        case .plain: return "Plain"
        case .shaded: return "Shaded"
        }
    }
}
