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

    struct Frames {
        /// Number of frames it takes for a tetromino to drop by one space per level. Higher levels always drop one space per frame.
        static let gravityPerLevel: [Int] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]
        /// Number  of frames it takes before a new tetromino spawns
        static let spawn: Int = 16
        /// Number of frames it takes to complete an animation step
        static let animation: Int = 4
        /// Number of frames it takes the "drop" key to repeat when held down
        static let keyRepeatDrop: Int = 1
    }

    func spawn(stackHeight: Int) -> Int {
        return TetrisOptions.Frames.spawn + (stackHeight / 4)
    }
    func gravity(level: Int) -> Int {
        return level < TetrisOptions.Frames.gravityPerLevel.count ? TetrisOptions.Frames.gravityPerLevel[level] : 1
    }
    func keyRepeatShift(initial: Bool) -> Int {
        return initial ? self.autoShift.delays.initial : self.autoShift.delays.repeating
    }
}

extension TetrisOptions: CustomStringConvertible {
    var description: String {
        "Level \(startingLevel), RNG \(self.randomGeneratorMode), DAS \(self.autoShift), \(self.wallKick ? "Wall kick" : ""), \(self.hardDrop ? "Hard drop" : "")"
    }
}
