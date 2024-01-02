//
//  GameScene.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    private let framesPerCellPerLevel: [UInt64] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]

    private var currentTetromino: Tetromino?
    private var board: SKTileMapNode!
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
        }
    }

    private var isGameOver: Bool = false {
        didSet {
            self.childNode(withName: "//labelGameOver")?.isHidden = !self.isGameOver
        }
    }

    private var lines: Int = 0 {
        didSet {
            if let label = self.childNode(withName: "//labelLines") as? SKLabelNode {
                label.text = String(format: "%003d", self.lines)
            }
        }
    }

    private var score: Int = 0 {
        didSet {
            if let label = self.childNode(withName: "//labelScore") as? SKLabelNode {
                label.text = String(format: "%010d", self.score)
            }
        }
    }

    private var level: Int = 0 {
        didSet {
            if let label = self.childNode(withName: "//labelLevel") as? SKLabelNode {
                label.text = String(format: "%003d", self.level)
            }
        }
    }

    private var nextTetromino: Tetromino? {
        didSet {
            if let preview = self.childNode(withName: "//preview") as? SKTileMapNode {
                preview.clear()
                if let tetronimo = self.nextTetromino {
                    preview.draw(tetronimo: tetronimo)
                }
            }
        }
    }

    override func didMove(to view: SKView) {
        self.board = self.childNode(withName: "//board") as? SKTileMapNode
        self.newGame()
    }

    private func newGame () {
        self.level = 0
        self.score = 0
        self.lines = 0
        self.currentTetromino = nil
        self.nextTetromino = Tetromino.init(using: &random)
        self.currentTetromino = Tetromino.init(using: &random).with(position: ((self.board.numberOfColumns / 2) - 1, self.board.numberOfRows))

        self.board.clear()

        self.frameCount = self.dropSpeed - 1
        self.waitFrame = self.dropSpeed
        self.isGameOver = false
    }

    private func apply (change: ((Tetromino) -> Tetromino)) -> Bool {

        var result = false

        self.board.clear(tetronimo: self.currentTetromino)

        if let current = self.currentTetromino {
            let tetromino = change(current)

            if !self.board.collides(tetronimo: tetromino) {
                self.currentTetromino = tetromino
                result = true
            }
        }

        self.board.draw(tetronimo: self.currentTetromino)

        return result
    }


    private func score (rows range: Range<Int>) {
        switch range.upperBound - range.upperBound {
        case 0: self.score += 40 * (self.level + 1)
        case 1: self.score += 100 * (self.level + 1)
        case 2: self.score += 300 * (self.level + 1)
        case 3: self.score += 1200 * (self.level + 1)
        default:
            break
        }
    }

    override func keyDown(with event: NSEvent) {

        if self.isGameOver {
            self.newGame()
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
                self.currentTetromino = nil
            } else {
                self.score += 1
            }
//        case 126: // up
        case 0: // A
            _ = self.apply { $0.rotatedLeft() }
        case 1: // S
            _ = self.apply { $0.rotatedRight() }
        case 35: // P
            self.isGamePaused = !self.isGamePaused
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

        if self.currentTetromino == nil {
            if let completed = self.board.lowestCompletedRows() {
                self.board.drop(rows: completed)
                self.score(rows: completed)
                self.lines += completed.upperBound - completed.lowerBound
                self.level = self.lines / 10
            }
            self.currentTetromino = self.nextTetromino?.with(position: ((self.board.numberOfColumns / 2) - 1, self.board.numberOfRows))
            self.nextTetromino = Tetromino.init(using: &random)
            self.waitFrame = 0
        } else {
            let changed = self.apply { $0.movedDown() }
            if !changed {
                if let maxRow = self.currentTetromino?.points.map({$0.1}).max(), maxRow >= self.board.numberOfRows {
                    self.isGameOver = true
                }
                self.currentTetromino = nil
            }
            self.waitFrame = self.dropSpeed
        }
    }
}
