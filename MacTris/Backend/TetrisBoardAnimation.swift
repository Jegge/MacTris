//
//  DissolveAnimation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 11.07.26.
//

import SpriteKit
import GameplayKit
import GameController
import OSLog

protocol TetrisBoardAnimation {
    var board: [[Tetromino.Shape?]] { get }
    var finished: Bool { get }
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
