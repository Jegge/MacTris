//
//  Statistics.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 20.12.25.
//

/// Tracks the frequency of each tetromino shape that has been spawned in the current game.
struct Statistics {
    private var counts: [Tetromino.Shape: Int] = [:]

    /// Records the spawning of a shape.
    mutating func add(_ shape: Tetromino.Shape) {
        counts[shape] = (counts[shape] ?? 0) + 1
    }

    /// The total number of shapes spawned.
    var total: Int {
        counts.reduce(0) { $0 + $1.value }
    }

    /// How many times a given shape has been spawned.
    func count(_ shape: Tetromino.Shape) -> Int {
        counts[shape] ?? 0
    }

    /// The percentage of total spawns represented by the given shape.
    func percent(_ shape: Tetromino.Shape) -> Double {
        total > 0 ? (Double(count(shape)) / Double(total)) * 100.0 : 0.0
    }
}

extension Statistics: CustomStringConvertible {
    var description: String {
        Tetromino.Shape
            .allCases
            .map { String(format: "%@ %.04f%% (%d/%d)", String(describing: $0).uppercased(), percent($0), count($0), total) }
            .joined(separator: ", ")
    }
}
