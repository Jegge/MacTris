//
//  Game.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameplayKit

class Game: SKScene {

    private var soundSuccess = SKAction.playSoundFileNamed("Success.aiff", waitForCompletion: false)
    private var soundQuadSuccess = SKAction.playSoundFileNamed("QuadSuccess.aiff", waitForCompletion: false)
    private var soundGameOver = SKAction.playSoundFileNamed("GameOver.aiff", waitForCompletion: false)
    private var soundPositive = SKAction.playSoundFileNamed("Positive.aiff", waitForCompletion: false)
    private var soundSelect = SKAction.playSoundFileNamed("Select.aiff", waitForCompletion: false)

    private let framesPerCellPerLevel: [UInt64] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]
    private let baseScorePerLines = [40, 100, 300, 1200]

    private var current: Tetromino?
    private var random: RandomNumberGenerator = SystemRandomNumberGenerator()
    private var completed: Range<Int>?
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
            self.run(self.soundSelect)
        }
    }

    private var isGameOver: Bool = false {
        didSet {
            self.childNode(withName: "//labelGameOver")?.isHidden = !self.isGameOver
            self.childNode(withName: "//board")?.alpha = self.isGameOver ? 0.5 : 1.0
            if self.isGameOver {
                self.run(self.soundGameOver)
            }
        }
    }

    private var lines: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelLines") as? SKLabelNode)?.text = String(format: "%3d", self.lines)
        }
    }

    private var score: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelScore") as? SKLabelNode)?.text = String(format: "%10d", self.score)
        }
    }

    private var level: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelLevel") as? SKLabelNode)?.text = String(format: "%3d", self.level)
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
        let score = baseScorePerLines[range.count - 1] * (self.level + 1)
        self.score += score
        self.lines += range.count
        self.level = self.lines / 10

        if range.count > 3 {
            self.run(self.soundQuadSuccess)
        } else {
            self.run(self.soundSuccess)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    override func keyDown(with event: NSEvent) {

        if self.isGameOver {
            self.run(self.soundPositive)
            if let newScene = SKScene(fileNamed: "Scores") as? Scores {
                newScene.scaleMode = .aspectFit
                newScene.score = self.score
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
            return
        }

        if self.isGamePaused {
            self.isGamePaused = false
            return
        }

        switch event.keyCode {
        case KeyBindings.moveLeft:
            _ = self.apply { $0.movedLeft() }

        case KeyBindings.moveRight:
            _ = self.apply { $0.movedRight() }

        case KeyBindings.softDrop:
            let changed = self.apply { $0.movedDown() }
            if !changed {
                self.current = nil
            } else {
                self.score += 1
            }

        case KeyBindings.rotateLeft:
            _ = self.apply { $0.rotatedLeft() }

        case KeyBindings.rotateRight:
            _ = self.apply { $0.rotatedRight() }

        case KeyBindings.pause:
            self.isGamePaused = true

        case KeyBindings.quit:
            self.run(self.soundPositive)
            if let newScene = SKScene(fileNamed: "Menu") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }

        case KeyBindings.fullscreen:
            if self.view?.isInFullScreenMode ?? false {
                self.view?.exitFullScreenMode()
            } else {
                self.view?.enterFullScreenMode(NSScreen.main!)
            }

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

        if let completed = self.completed {
            board.drop(rows: completed)
            self.score(rows: completed)
            self.completed = nil
            return
        }

        if self.current == nil {
            self.completed = board.completedRows()
            self.current = self.next?.with(position: board.startPosition)
            self.next = Tetromino(using: &random)
            self.waitFrame = 0
            return
        }

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
