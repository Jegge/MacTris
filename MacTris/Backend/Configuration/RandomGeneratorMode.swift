//
//  RandomGeneratorMode.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 13.07.26.
//

import Foundation

/// The algorithm used to generate random tetromino sequences.
enum RandomGeneratorMode: Int {
    /// NES Tetris weighted-probability algorithm.
    case nes = 1
    /// Modern 7-bag shuffling algorithm.
    case sevenBag = 2

    /// Creates the corresponding random generator instance.
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
