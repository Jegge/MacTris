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
        private static let gravityPerLevel: [Int] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]

        public static func gravity (level: Int) -> Int {
            return level < FrameCount.gravityPerLevel.count ? FrameCount.gravityPerLevel[level] : 1
        }
        public static let dissolve: Int = 4
        public static let spawn: Int = 16
    }

    private static let baseScorePerLines = [40, 100, 300, 1200]

    private var random: RandomTetrominoGenerator = RandomTetrominoGenerator()
    private var current: Tetromino?
    private var completed: Range<Int>?
    private var linesToNextLevel: Int = 0

    private var framesToWait: Int = 0
    private var keysDown: Set<UInt16> = Set()

    private var isGamePaused: Bool = false {
        didSet {
            self.childNode(withName: "pause")?.isHidden = !self.isGamePaused
            AudioPlayer.playFxSelect()
        }
    }

    private var isGameOver: Bool = false {
        didSet {
            if self.isGameOver {
                self.childNode(withName: "gameOver")?.isHidden = false

                if let label = self.childNode(withName: "//labelFinalScore") as? SKLabelNode {
                    if let hiscores = try? Hiscore(contentsOfUrl: Hiscore.url), hiscores.isHighscore(score: Hiscore.Score(name: "", value: self.score)) {
                        label.text = "New hiscore: \(self.score)"
                    } else {
                        label.text = "Your score: \(self.score)"
                    }
                }

                AudioPlayer.playFxGameOver()
            }
        }
    }

    private var lines: Int = 0 {
        didSet {
            (self.childNode(withName: "labelLines") as? SKLabelNode)?.text = String(format: "%3d", self.lines)
        }
    }

    private var score: Int = 0 {
        didSet {
            (self.childNode(withName: "labelScore") as? SKLabelNode)?.text = String(format: "%10d", self.score)
        }
    }

    public var level: Int = 0 {
        didSet {
            (self.childNode(withName: "labelLevel") as? SKLabelNode)?.text = String(format: "%3d", self.level)
        }
    }

    private var next: Tetromino? {
        didSet {
            if let preview = self.childNode(withName: "preview") as? SKTileMapNode {
                preview.clear()
                if let tetronimo = self.next {
                    preview.draw(tetronimo: tetronimo)
                }
            }
        }
    }

    private func score (rows range: Range<Int>) {
        let score = Game.baseScorePerLines[range.count - 1] * (self.level + 1)
        self.score += score
        self.lines += range.count

        self.linesToNextLevel -= range.count

        if self.linesToNextLevel <= 0 {
            self.level += 1
            self.linesToNextLevel += min(self.level * 10 + 10, max(100, self.level * 10 - 50))
        }

        if range.count > 3 {
            AudioPlayer.playFxQuadSuccess()
        } else {
            AudioPlayer.playFxSuccess()
        }
    }

    override func didMove (to view: SKView) {
        guard let board = self.childNode(withName: "board") as? SKTileMapNode else {
            return
        }

        self.score = 0
        self.lines = 0
        self.linesToNextLevel = min(self.level * 10 + 10, max(100, self.level * 10 - 50))
        self.next = random.next().with(position: (2, 2))
        self.current = random.next().with(position: board.startPosition)

        board.clear()

        self.framesToWait = FrameCount.gravity(level: self.level)
        self.isGameOver = false
    }

    override func keyDown (with event: NSEvent) {

        if self.isGameOver {
            if event.keyCode == KeyBindings.quit {
                AudioPlayer.playFxPositive()
                if let newScene = SKScene(fileNamed: "Scores") as? Scores {
                    newScene.scaleMode = .aspectFit
                    newScene.score = self.score
                    self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
                }
            }
            return
        }

        if self.isGamePaused {
            if event.keyCode == KeyBindings.quit {
                AudioPlayer.playFxPositive()
                if let newScene = SKScene(fileNamed: "Scores") as? Scores {
                    newScene.scaleMode = .aspectFit
                    newScene.score = self.score
                    self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
                }
            } else {
                self.isGamePaused = false
            }
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

        case KeyBindings.quit:
            self.isGamePaused = true

        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }

    override func keyUp (with event: NSEvent) {
        self.keysDown.remove(event.keyCode)
    }

    override func update (_ currentTime: TimeInterval) {

        if self.isGamePaused || self.isGameOver {
            return
        }

        guard let board = self.childNode(withName: "board") as? SKTileMapNode else {
            return
        }

        if self.completed == nil, let current = self.current {
            if let keyCode = self.keysDown.popFirst() {
                switch keyCode {
                case KeyBindings.moveLeft:
                    if let changed = board.apply(tetromino: current, change: { $0.movedLeft() }) {
                        self.current = changed
                        AudioPlayer.playFxTranslation()
                    }

                case KeyBindings.moveRight:
                    if let changed = board.apply(tetromino: current, change: { $0.movedRight() }) {
                        self.current = changed
                        AudioPlayer.playFxTranslation()
                    }

                case KeyBindings.softDrop:
                    if let changed = board.apply(tetromino: current, change: { $0.movedDown() }) {
                        self.current = changed
                        self.score += 1
                    } else {
                        self.current = nil
                        if board.stackedTooHigh(tetromino: current) {
                            self.isGameOver = true
                            return
                        }
                    }

                case KeyBindings.rotateLeft:
                    if let changed = board.apply(tetromino: current, change: { $0.rotatedLeft() }) {
                        self.current = changed
                        AudioPlayer.playFxRotation()
                    }

                case KeyBindings.rotateRight:
                    if let changed = board.apply(tetromino: current, change: { $0.rotatedRight() }) {
                        self.current = changed
                        AudioPlayer.playFxRotation()
                    }

                default:
                    break
                }
            }
        }

        if self.framesToWait > 0 {
            self.framesToWait -= 1
        } else if let completed = self.completed {
            self.score(rows: completed)
            if board.dissolve(rows: completed) {
                board.drop(rows: completed)
                self.completed = board.completedRows()
                self.framesToWait = FrameCount.spawn
            } else {
                self.framesToWait = FrameCount.dissolve
            }
        } else if self.current == nil {
            self.completed = board.completedRows()
            self.current = self.next?.with(position: board.startPosition)
            self.next = random.next().with(position: (2, 2))
            self.framesToWait = FrameCount.spawn
        } else if let changed = board.apply(tetromino: self.current!, change: { $0.movedDown() }) {
            self.current = changed
            self.framesToWait = FrameCount.gravity(level: self.level)
        } else {
            if let current = self.current, board.stackedTooHigh(tetromino: current) {
                self.isGameOver = true
            }
            self.current = nil
            self.framesToWait = FrameCount.gravity(level: self.level)
        }
    }
}
