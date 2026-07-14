//
//  TetrisBoardAnimation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 11.07.26.
//

/// A special tetris board that can be manipulated based on a sequence of calls.
protocol TetrisBoardAnimation {
    /// The curernt board
    var board: [[Tetromino.Shape?]] { get }
    /// A flag that indicates wether the animation is finished or still running
    var finished: Bool { get }
    /// Advance the animation to the next frame
    func next()
}

class DissolveLinesAnimation: TetrisBoardAnimation {
    init (board: [[Tetromino.Shape?]], lines: Range<Int>) {
        self.board = board
        self.lines = lines
    }

    private var step: Int = 0
    private let lines: Range<Int>

    private(set) var board: [[Tetromino.Shape?]]
    var finished: Bool {
        return self.step > self.board.count / 2
    }

    func next() {
        let mid = self.board.count / 2

        for row in lines {
            guard row >= 0 && row < (self.board.first?.count ?? 0) else {
                continue
            }
            for column in (mid - step)..<mid where column >= 0 && column < self.board.count {
                self.board[column][row] = nil
            }
            for column in mid..<(mid + step) where column < self.board.count {
                self.board[column][row] = nil
            }
        }

        self.step += 1
    }
}

class StackOutAnimation: TetrisBoardAnimation {
    init(board: [[Tetromino.Shape?]], fillAmountPerStep: Int) {
        self.board = board
        self.fillAmountPerStep = fillAmountPerStep
    }

    private(set) var board: [[Tetromino.Shape?]]
    private let fillAmountPerStep: Int

    private func emptySpaces() -> [Point] {
        var result: [Point] = []
        for column in 0..<self.board.count {
            for row in 0..<self.board[column].count where board[column][row] == nil {
                result.append((column, row))
            }
        }
        return result
    }

    var finished: Bool {
        for column in 0..<self.board.count {
            for row in 0..<self.board[column].count where board[column][row] == nil {
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
                self.board[space.x][space.y] = .allCases.randomElement()
            }
        }
    }
}
