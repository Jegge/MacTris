//
//  TetrisAnimation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 11.07.26.
//

/// A special tetris board that can be manipulated based on a sequence of calls.
protocol TetrisAnimation {
    /// The current grid
    var grid: Tetris.Grid { get }
    /// A flag that indicates that the animation is finished
    var finished: Bool { get }
    /// Advance the animation to the next frame
    func next()
}

class DissolveLinesAnimation: TetrisAnimation {
    init(grid: Tetris.Grid, lines: Range<Int>) {
        self.grid = grid
        self.lines = lines
    }

    private var step: Int = 0
    private let lines: Range<Int>

    private(set) var grid: Tetris.Grid

    var finished: Bool {
        return self.step > self.grid.count / 2
    }

    func next() {
        let mid = self.grid.count / 2

        for row in lines {
            guard row >= 0 && row < (self.grid.first?.count ?? 0) else {
                continue
            }
            for column in (mid - step)..<mid where column >= 0 && column < self.grid.count {
                self.grid[column][row] = nil
            }
            for column in mid..<(mid + step) where column < self.grid.count {
                self.grid[column][row] = nil
            }
        }

        self.step += 1
    }
}

class StackOutAnimation: TetrisAnimation {
    init(grid: Tetris.Grid, fillAmountPerStep: Int) {
        self.grid = grid
        self.fillAmountPerStep = fillAmountPerStep
    }

    private(set) var grid: Tetris.Grid
    private let fillAmountPerStep: Int

    private func emptySpaces() -> [Point] {
        var result: [Point] = []
        for column in 0..<self.grid.count {
            for row in 0..<self.grid[column].count where grid[column][row] == nil {
                result.append((column, row))
            }
        }
        return result
    }

    var finished: Bool {
        for column in 0..<self.grid.count {
            for row in 0..<self.grid[column].count where grid[column][row] == nil {
                return false
            }
        }
        return true
    }

    func next() {
        var spaces = self.emptySpaces()

        for _ in 0..<fillAmountPerStep {
            if let space = spaces.randomElement() {
                spaces.removeAll { $0 == space }
                self.grid[space.x][space.y] = .allCases.randomElement()
            }
        }
    }
}
