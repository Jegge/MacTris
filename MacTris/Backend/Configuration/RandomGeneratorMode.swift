//
//  RandomGeneratorMode.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

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
