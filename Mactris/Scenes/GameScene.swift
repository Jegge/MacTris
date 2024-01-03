//
//  Game.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let framesPerCellPerLevel: [UInt64] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]
    private let baseScorePerLines = [40, 100, 300, 1200]

    private var current: Tetromino?
    private var random: RandomNumberGenerator = SystemRandomNumberGenerator()
    private var frameCount: UInt64 = 0
    private var waitFrame: UInt64 = 0

    private var dropSpeed: UInt64 {
        if self.level < self.framesPerCellPerLevel.count {
            return self.framesPerCellPerLevel[self.level]
        }
        return 1
    }

    private var isGamePaused: Bool = false {
        didSet {
            self.childNode(withName: "//labelPaused")?.isHidden = !self.isGamePaused
            self.childNode(withName: "//board")?.alpha = self.isGamePaused ? 0.5 : 1.0
        }
    }

    private var isGameOver: Bool = false {
        didSet {
            self.childNode(withName: "//labelGameOver")?.isHidden = !self.isGameOver
            self.childNode(withName: "//board")?.alpha = self.isGameOver ? 0.5 : 1.0
        }
    }

    private var lines: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelLines") as? SKLabelNode)?.text = String(format: "%003d", self.lines)
        }
    }

    private var score: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelScore") as? SKLabelNode)?.text = String(format: "%010d", self.score)
        }
    }

    private var level: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelLevel") as? SKLabelNode)?.text = String(format: "%003d", self.level)
        }
    }

    private var next: Tetromino? {
        didSet {
            if let preview = self.childNode(withName: "//preview") as? SKTileMapNode {
                preview.clear()
                if let tetronimo = self.next {
                    preview.draw(tetronimo: tetronimo)
                }
            }
        }
    }

    override func didMove(to view: SKView) {
        self.newGame()
    }

    private func newGame () {

        guard let board = self.childNode(withName: "//board") as? SKTileMapNode else {
            return
        }

        self.level = 0
        self.score = 0
        self.lines = 0
        self.next = Tetromino(using: &random)
        self.current = Tetromino(using: &random).with(position: board.startPosition)

        board.clear()

        self.frameCount = self.dropSpeed - 1
        self.waitFrame = self.dropSpeed
        self.isGameOver = false
    }

    private func apply (change: ((Tetromino) -> Tetromino)) -> Bool {

        guard let board = self.childNode(withName: "//board") as? SKTileMapNode else {
            return false
        }

        var result = false

        board.clear(tetronimo: self.current)

        if let current = self.current {
            let tetromino = change(current)

            if !board.collides(tetronimo: tetromino) {
                self.current = tetromino
                result = true
            }
        }

        board.draw(tetronimo: self.current)

        return result
    }

    private func score (rows range: Range<Int>) {
        let score = baseScorePerLines[range.upperBound - range.lowerBound - 1] * (self.level + 1)
        print("Scoring: \(range) - \(score)")

        self.score += score
        self.lines += range.upperBound - range.lowerBound
        self.level = self.lines / 10
    }

    override func keyDown(with event: NSEvent) {

        if self.isGameOver {
            self.newGame()
            return
        }

        if self.isGamePaused {
            self.isGamePaused = false
            return
        }

        switch event.keyCode {
        case 123: // left
            _ = self.apply { $0.movedLeft() }
        case 124: // right
            _ = self.apply { $0.movedRight() }
        case 125: // down
            let changed = self.apply { $0.movedDown() }
            if !changed {
                self.current = nil
            } else {
                self.score += 1
            }
//        case 126: // up
        case 0: // A
            _ = self.apply { $0.rotatedLeft() }
        case 1: // S
            _ = self.apply { $0.rotatedRight() }
        case 35: // P
            self.isGamePaused = true
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }

    override func update(_ currentTime: TimeInterval) {

        if self.isGamePaused || self.isGameOver {
            return
        }

        self.frameCount += 1

        if self.frameCount < self.waitFrame {
            return
        }

        self.frameCount = 0

        guard let board = self.childNode(withName: "//board") as? SKTileMapNode else {
            return
        }

        if self.current == nil {
            if let rows = board.completedRows() {
                board.drop(rows: rows)
                self.score(rows: rows)
            }
            self.current = self.next?.with(position: board.startPosition)
            self.next = Tetromino(using: &random)
            self.waitFrame = 0
        } else {
            let changed = self.apply { $0.movedDown() }
            if !changed {
                if let maxRow = self.current?.points.map({$0.1}).max(), maxRow >= board.numberOfRows {
                    self.isGameOver = true
                }
                self.current = nil
            }
            self.waitFrame = self.dropSpeed
        }
    }
}
