//
//  RandomGeneratorMode.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation

enum RandomGeneratorMode: Int {
    case nes = 1
    case sevenBag = 2

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
        case .nes: return NSLocalizedString("EnumRandomGeneratorModeNes", comment: "Description of enum case RandomGeneratorMode.nes")
        case .sevenBag: return NSLocalizedString("EnumRandomGeneratorModeSevenBag", comment: "Description of enum case RandomGeneratorMode.sevenBag")
        }
    }
}

extension RandomGeneratorMode: Adjustable { }
