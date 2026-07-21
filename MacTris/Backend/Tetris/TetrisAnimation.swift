//
//  TetrisAnimation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 11.07.26.
//

/// Protocol for board-level animations that advance frame by frame.
protocol TetrisAnimation {
    /// The current grid.
    var grid: Tetris.Grid { get }
    /// Advances the animation to the next frame. Returns `false` if the animation is finished.
    func next() -> Bool
    /// Closure invoked when the animation reaches its final frame.
    var completion: (() -> Void)? { get }
}

/// Animates the dissolution of completed lines by clearing them outward from
/// the center column over successive steps.
class DissolveLinesAnimation: TetrisAnimation {
    init(grid: Tetris.Grid, lines: Range<Int>, completion: @escaping (() -> Void)) {
        self.grid = grid
        self.lines = lines
        self.completion = completion
    }

    private var step: Int = 0
    private(set) var grid: Tetris.Grid
    private let lines: Range<Int>
    let completion: (() -> Void)?

    func next() -> Bool {
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
        if self.step > self.grid.count / 2 {
            self.completion?()
            return false
        }

        return true
    }
}

/// Animates a "stack out" (game over) by filling empty spaces on the board
/// with random tetromino tiles, step by step.
class StackOutAnimation: TetrisAnimation {
    init(grid: Tetris.Grid, fillAmountPerStep: Int, completion: @escaping (() -> Void)) {
        self.grid = grid
        self.fillAmountPerStep = fillAmountPerStep
        self.completion = completion
    }

    private(set) var grid: Tetris.Grid
    private let fillAmountPerStep: Int
    let completion: (() -> Void)?

    private func emptySpaces() -> [Point] {
        var result: [Point] = []
        for column in 0..<self.grid.count {
            for row in 0..<self.grid[column].count where grid[column][row] == nil {
                result.append(Point(column, row))
            }
        }
        return result
    }

    func next() -> Bool {
        var spaces = self.emptySpaces()

        for _ in 0..<fillAmountPerStep {
            if let space = spaces.randomElement() {
                spaces.removeAll { $0 == space }
                self.grid[space.column][space.row] = .allCases.randomElement()
            }
        }

        if spaces.isEmpty {
            self.completion?()
            return false
        }

        return true
    }
}
