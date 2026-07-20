//
//  TetrisOptions.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 09.07.26.
//

/// Configuration options for a game of Tetris.
struct TetrisOptions {
    /// The starting level, which affects gravity speed.
    let startingLevel: Int
    /// The auto-shift (DAS) configuration.
    let autoShift: AutoShift
    /// The random generator used to produce tetromino shapes.
    let randomGeneratorMode: RandomGeneratorMode
    /// Whether wall-kick rotation is enabled.
    let wallKick: Bool
    /// Whether hard-drop is enabled.
    let hardDrop: Bool

    /// Number of lines needed to advance past the starting level.
    /// Uses the classic NES formula, including replicating its off-by-one bug
    /// (min of `level * 10 + 10` and `max(100, level * 10 - 50)`).
    var startingLinesToNextLevel: Int {
        min(self.startingLevel * 10 + 10, max(100, self.startingLevel * 10 - 50))
    }

    /// Frame-count constants used for timing in the game loop. A frame is 1/60 seconds long, at a fixed 60 fps rate.
    struct Frames {
        /// NES Tetris gravity table (29 levels).
        /// Number of frames it takes for a tetromino to drop by one space per level. Higher levels always drop one space per frame.
        static let gravityPerLevel: [Int] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]
        /// Number of frames it takes before a new tetromino spawns.
        static let spawn: Int = 16
        /// Number of frames it takes to complete an animation step.
        static let animation: Int = 4
        /// Number of frames it takes the "drop" key to repeat when held down.
        static let keyRepeatDrop: Int = 1
    }

    /// Returns the spawn delay in frames, adjusted by the current stack height.
    func spawn(stackHeight: Int) -> Int {
        return TetrisOptions.Frames.spawn + (stackHeight / 4)
    }
    /// Returns the gravity interval in frames for the given level.
    func gravity(level: Int) -> Int {
        return level < TetrisOptions.Frames.gravityPerLevel.count ? TetrisOptions.Frames.gravityPerLevel[level] : 1
    }
    /// Returns the key-repeat delay in frames. Uses a shorter delay for the initial press.
    func keyRepeatShift(initial: Bool) -> Int {
        return initial ? self.autoShift.delays.initial : self.autoShift.delays.repeating
    }
}

extension TetrisOptions: CustomStringConvertible {
    var description: String {
        "Level \(startingLevel), RNG \(self.randomGeneratorMode), DAS \(self.autoShift), \(self.wallKick ? "Wall kick" : ""), \(self.hardDrop ? "Hard drop" : "")"
    }
}
