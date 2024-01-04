//
//  Game.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameplayKit

class Game: SKScene {

    private struct FrameCount {
        private static let framesToDropPerLevel: [Int] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]

        public static func drop(level: Int) -> Int {
            return level < FrameCount.framesToDropPerLevel.count ? FrameCount.framesToDropPerLevel[level] : 1
        }
        public static let dissolve: Int = 4
        public static let spawn: Int = 16
    }

    private var soundSuccess = SKAction.playSoundFileNamed("Success.aiff", waitForCompletion: false)
    private var soundQuadSuccess = SKAction.playSoundFileNamed("QuadSuccess.aiff", waitForCompletion: false)
    private var soundGameOver = SKAction.playSoundFileNamed("GameOver.aiff", waitForCompletion: false)
    private var soundPositive = SKAction.playSoundFileNamed("Positive.aiff", waitForCompletion: false)
    private var soundSelect = SKAction.playSoundFileNamed("Select.aiff", waitForCompletion: false)
    private var soundMovement = SKAction.playSoundFileNamed("Movement.aiff", waitForCompletion: false)

    private let baseScorePerLines = [40, 100, 300, 1200]

    private var random: RandomTetrominoGenerator = RandomTetrominoGenerator()
    private var current: Tetromino?
    private var completed: Range<Int>?

    private var framesToWait: Int = 0
    private var keysDown: Set<UInt16> = Set()

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
        self.next = random.next().with(position: (2, 2))
        self.current = random.next().with(position: board.startPosition)

        board.clear()

        self.framesToWait = FrameCount.drop(level: self.level)
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

    override func keyDown(with event: NSEvent) {

        if self.isGameOver {
            if event.keyCode == KeyBindings.quit {
                self.run(self.soundPositive)
                if let newScene = SKScene(fileNamed: "Scores") as? Scores {
                    newScene.scaleMode = .aspectFit
                    newScene.score = self.score
                    self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
                }
            }
            return
        }

        if self.isGamePaused {
            self.isGamePaused = false
            return
        }

        switch event.keyCode {
        case KeyBindings.moveLeft:
            self.keysDown.insert(event.keyCode)

        case KeyBindings.moveRight:
            self.keysDown.insert(event.keyCode)

        case KeyBindings.softDrop:
            self.keysDown.insert(event.keyCode)

        case KeyBindings.rotateLeft:
            self.keysDown.insert(event.keyCode)

        case KeyBindings.rotateRight:
            self.keysDown.insert(event.keyCode)

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

    override func keyUp(with event: NSEvent) {
        self.keysDown.remove(event.keyCode)
    }

    override func update(_ currentTime: TimeInterval) {

        if self.isGamePaused || self.isGameOver {
            return
        }

        if self.completed == nil {
            for keyCode in self.keysDown {
                switch keyCode {
                case KeyBindings.moveLeft:
                    if self.apply(change: { $0.movedLeft() }) {
                        self.run(self.soundMovement)
                    }

                case KeyBindings.moveRight:
                    if self.apply(change: { $0.movedRight() }) {
                        self.run(self.soundMovement)
                    }

                case KeyBindings.softDrop:
                    if self.apply(change: { $0.movedDown() }) {
                        // self.run(self.soundMovement)
                        self.score += 1
                    } else {
                        self.current = nil
                    }

                case KeyBindings.rotateLeft:
                    if self.apply(change: { $0.rotatedLeft() }) {
                        self.run(self.soundMovement)
                    }

                case KeyBindings.rotateRight:
                    if self.apply(change: { $0.rotatedRight() }) {
                        self.run(self.soundMovement)
                    }
                default:
                    break
                }
            }
            self.keysDown.removeAll()
        }

        if self.framesToWait > 0 {
            self.framesToWait -= 1
            return
        }

        guard let board = self.childNode(withName: "//board") as? SKTileMapNode else {
            return
        }

        if let completed = self.completed {
            if board.dissolve(rows: completed) {
                board.drop(rows: completed)
                self.completed = nil
                self.framesToWait = FrameCount.spawn
            } else {
                self.framesToWait = FrameCount.dissolve
            }
            return
        }

        if self.current == nil {
            self.completed = board.completedRows()
            if let completed = self.completed {
                self.score(rows: completed)
            }
            self.current = self.next?.with(position: board.startPosition)
            self.next = random.next().with(position: (2, 2))
            self.framesToWait = FrameCount.spawn
            return
        }

        let changed = self.apply { $0.movedDown() }
        if !changed {
            if let maxRow = self.current?.points.map({$0.1}).max(), maxRow >= board.numberOfRows {
                self.isGameOver = true
            }
            self.current = nil
        }

        self.framesToWait = FrameCount.drop(level: self.level)
    }
}
