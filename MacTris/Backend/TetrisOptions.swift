//
//  TetrisOptions.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 09.07.26.
//

struct TetrisOptions {
    let startingLevel: Int
    let appearance: Appearance
    let autoShift: AutoShift
    let randomGeneratorMode: RandomGeneratorMode
    let wallKick: Bool
}

extension TetrisOptions: CustomStringConvertible {
    var description: String {
        "Begin game: RNG: \(self.randomGeneratorMode), DAS: \(self.autoShift), Wall kick \(self.wallKick ? "enabled" : "disabled")"
    }
}
