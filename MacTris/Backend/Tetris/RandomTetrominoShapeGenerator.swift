//
//  RandomTetrominoShapeGenerator.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

/// A random generator that produces a stream of tetromino shapes.
protocol RandomTetrominoShapeGenerator {
    /// Retrieve the next tetromino shape.
    func next() -> Tetromino.Shape
}

/// Generates shapes using the "7-bag" system: all seven shapes are shuffled
/// into a bag, and each call draws one. When the bag is empty, a new bag is shuffled.
class SevenBagTetrominoShapeGenerator: RandomTetrominoShapeGenerator {
    private var random: RandomNumberGenerator
    private var bag: [Tetromino.Shape] = []

    init(random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init() {
        self.init(random: SystemRandomNumberGenerator())
    }

    func next() -> Tetromino.Shape {
        if self.bag.isEmpty {
            self.bag = Tetromino.Shape.allCases.shuffled(using: &self.random)
        }
        // swiftlint:disable:next force_unwrapping
        return self.bag.popLast()!
    }
}

/// Generates shapes using the same weighted-probability algorithm as the
/// original NES Tetris. Probabilities for each shape depend on the previously
/// drawn shape, closely replicating the NES RNG behavior.
///
/// See https://tetrissuomi.wordpress.com/wp-content/uploads/2020/04/nes_tetris_rng.pdf, Tables 2 & 3
class NesTetrominoShapeGenerator: RandomTetrominoShapeGenerator {
    private var random: RandomNumberGenerator
    private var last: Tetromino.Shape?

    // These are the weighted probabilities for each shape, depending on the previous shape.
    // So if no previous shape is known, we use probabilities[nil] as table; if the previous shape was a .t for instance,
    // we query the table probabilities[.t]. Effectively, this has to be read "if the previous shape was a .s, the probability for a .z is now 15.625%"
    private let probabilities: [Tetromino.Shape?: [(shape: Tetromino.Shape, probability: Int)]] = [
        nil: [ (.t, 14635), (.j, 14248), (.z, 14387), (.o, 14219), (.s, 14625), (.l, 13975), (.i, 13911) ],
         .t: [ (.t, 03125), (.j, 15625), (.z, 18750), (.o, 15625), (.s, 15625), (.l, 15625), (.i, 15625) ],
         .j: [ (.t, 18750), (.j, 03125), (.z, 15625), (.o, 15625), (.s, 15625), (.l, 15625), (.i, 15625) ],
         .z: [ (.t, 15625), (.j, 18750), (.z, 03125), (.o, 15625), (.s, 15625), (.l, 15625), (.i, 15625) ],
         .o: [ (.t, 15625), (.j, 15625), (.z, 15625), (.o, 06250), (.s, 15625), (.l, 15625), (.i, 15625) ],
         .s: [ (.t, 15625), (.j, 15625), (.z, 15625), (.o, 15625), (.s, 06250), (.l, 15625), (.i, 15625) ],
         .l: [ (.t, 18750), (.j, 15625), (.z, 15625), (.o, 15625), (.s, 15625), (.l, 03125), (.i, 15625) ],
         .i: [ (.t, 15625), (.j, 15625), (.z, 15625), (.o, 15625), (.s, 18750), (.l, 15625), (.i, 03125) ]
    ]

    init(random: RandomNumberGenerator) {
        self.random = random
    }

    convenience init() {
        self.init(random: SystemRandomNumberGenerator())
    }

    func next() -> Tetromino.Shape {
        // swiftlint:disable:next force_unwrapping
        let table = probabilities[self.last]!

        let sum = table.reduce(0) { (result, entry) in result + entry.probability }
        let rnd = Int(truncatingIfNeeded: self.random.next(upperBound: UInt(sum)))
        var acc = 0

        for (shape, probability) in table {
            acc += probability
            if rnd < acc {
                self.last = shape
                return shape
            }
        }

        fatalError("NesTetrominoShapeGenerator invalid probability")
    }
}
