//
//  TetrisOptions.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 09.07.26.
//

struct TetrisOptions {
    let startingLevel: Int
    let appearance: Appearance
    let animations: Bool
    let autoShift: AutoShift
    let randomGeneratorMode: RandomGeneratorMode
    let wallKick: Bool
    let hardDrop: Bool
}

extension TetrisOptions: CustomStringConvertible {
    var description: String {
        "Level \(startingLevel), RNG \(self.randomGeneratorMode), DAS \(self.autoShift), \(self.wallKick ? "Wall kick" : ""), \(self.hardDrop ? "Hard drop" : "")"
    }
}
