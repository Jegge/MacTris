//
//  Game.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameplayKit
import OSLog

class Game: SKScene {

    private enum State {
        case running
        case paused
        case gameover
    }

    private struct FrameCount {
        private static let gravityPerLevel: [Int] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]

        public static func gravity (level: Int) -> Int {
            return level < FrameCount.gravityPerLevel.count ? FrameCount.gravityPerLevel[level] : 1
        }
        public static let dissolve: Int = 4
        public static let spawn: Int = 16
        public static let keyRepeat: Int = 6
    }

    private struct Score {
        private static let baseScorePerLines = [40, 100, 300, 1200]

        public static func lines(_ range: Range<Int>) -> Int {
            return Score.baseScorePerLines[range.count - 1]
        }

        public static let drop: Int = 1
    }

    private var random: RandomTetrominoGenerator = RandomTetrominoGenerator()
    private var current: Tetromino?
    private var completed: Range<Int>?
    private var linesToNextLevel: Int = 0

    private var framesToWait: Int = 0
    private var events: Set<Input> = Set()
    private var keyRepeatFrames = 0
    private var anyKeyEnabled = false

    private var numberFormatter = NumberFormatter()

    private var state: State = .running {
        didSet {
            switch state {
            case .running:
                self.childNode(withName: "pause")?.isHidden = true
                self.childNode(withName: "gameOver")?.isHidden = true
                self.anyKeyEnabled = false

            case .paused:
                self.childNode(withName: "pause")?.isHidden = false
                self.childNode(withName: "gameOver")?.isHidden = true
                self.anyKeyEnabled = false
            case .gameover:
                self.childNode(withName: "pause")?.isHidden = true
                self.childNode(withName: "gameOver")?.isHidden = false

                if let label = self.childNode(withName: "//labelFinalScore") as? SKLabelNode {
                    if let hiscores = try? Hiscore(contentsOfUrl: Hiscore.url), hiscores.isHighscore(score: Hiscore.Score(name: "", value: self.score)) {
                        label.text = "New hiscore: \(self.score)"
                    } else {
                        label.text = "Your score: \(self.score)"
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.anyKeyEnabled = true
                }

                AudioPlayer.playFxGameOver()
            }
        }
    }

    private var lines: Int = 0 {
        didSet {
            (self.childNode(withName: "labelLines") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.lines)
        }
    }

    private var score: Int = 0 {
        didSet {
            (self.childNode(withName: "labelScore") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.score)
        }
    }

    public var level: Int = 0 {
        didSet {
            (self.childNode(withName: "labelLevel") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.level)
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
        let score = Score.lines(range) * (self.level + 1)
        self.score += score
        self.lines += range.count

        Logger.game.info("Completed \(range.count) lines at level \(self.level): \(score) points")

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

        self.numberFormatter.numberStyle = .decimal

        self.score = 0
        self.lines = 0
        self.linesToNextLevel = min(self.level * 10 + 10, max(100, self.level * 10 - 50))
        self.next = random.next().with(position: (2, 2))
        self.current = board.setStartPosition(for: random.next())

        board.clear()

        self.framesToWait = FrameCount.gravity(level: self.level)
        self.state = .running

        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { _ in
            if self.state == .running {
                self.state = .paused
            }
        }
    }

    override func keyDown (with event: NSEvent) {
        if event.isARepeat {
            return
        }
        InputMapper.shared.translate(event: event).forEach {
            self.inputDown(id: $0.id)
        }
    }

    override func keyUp (with event: NSEvent) {
        InputMapper.shared.translate(event: event).forEach {
            self.inputUp(id: $0.id)
        }
    }

    override func update (_ currentTime: TimeInterval) {
        if self.state != .running {
            return
        }

        guard let board = self.childNode(withName: "board") as? SKTileMapNode else {
            return
        }

        if self.completed == nil, let current = self.current {
            if self.keyRepeatFrames > 0 {
                self.keyRepeatFrames -= 1
            } else if self.events.contains(Input.moveLeft) {
                if let changed = board.apply(tetromino: current, change: { $0.movedLeft() }) {
                    self.current = changed
                    AudioPlayer.playFxTranslation()
                }
                self.keyRepeatFrames = FrameCount.keyRepeat
            } else if self.events.contains(Input.moveRight) {
                if let changed = board.apply(tetromino: current, change: { $0.movedRight() }) {
                    self.current = changed
                    AudioPlayer.playFxTranslation()
                }
                self.keyRepeatFrames = FrameCount.keyRepeat
            } else if self.events.contains(Input.softDrop) {
                if let changed = board.apply(tetromino: current, change: { $0.movedDown() }) {
                    self.current = changed
                    self.score += Score.drop
                } else {
                    self.current = nil
                    if board.stackedTooHigh(tetromino: current) {
                        self.state = .gameover
                        return
                    }
                }
                self.keyRepeatFrames = FrameCount.keyRepeat
            } else if self.events.contains(Input.rotateLeft) {
                if let changed = board.apply(tetromino: current, change: { $0.rotatedLeft() }) {
                    self.current = changed
                    AudioPlayer.playFxRotation()
                }
                self.events.remove(Input.rotateLeft)
            } else if self.events.contains(Input.rotateRight) {
                if let changed = board.apply(tetromino: current, change: { $0.rotatedRight() }) {
                    self.current = changed
                    AudioPlayer.playFxRotation()
                }
                self.events.remove(Input.rotateRight)
            }
        }

        if self.framesToWait > 0 {
            self.framesToWait -= 1
        } else if let completed = self.completed {
            if board.dissolve(rows: completed) {
                board.drop(rows: completed)
                self.score(rows: completed)
                self.completed = board.completedRows()
                self.framesToWait = FrameCount.spawn
            } else {
                self.framesToWait = FrameCount.dissolve
            }
        } else if self.current == nil {
            self.completed = board.completedRows()
            self.current =  board.setStartPosition(for: self.next)
            self.next = random.next().with(position: (2, 2))
            self.framesToWait = FrameCount.spawn
            self.events.removeAll()
            self.keyRepeatFrames = 0
        } else if let changed = board.apply(tetromino: self.current!, change: { $0.movedDown() }) {
            self.current = changed
            self.framesToWait = FrameCount.gravity(level: self.level)
        } else {
            if let current = self.current, board.stackedTooHigh(tetromino: current) {
                self.state = .gameover
            }
            self.current = nil
            self.framesToWait = FrameCount.gravity(level: self.level)
        }
    }
}

extension Game: InputEventResponder {
    func inputDown(id: Input) {
        switch self.state {
        case .gameover:
            if self.anyKeyEnabled {
                AudioPlayer.playFxPositive()
                if let newScene = SKScene(fileNamed: "Scores") as? Scores {
                    newScene.scaleMode = .aspectFit
                    newScene.score = self.score
                    self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
                }
            }

        case .paused:
            if id == Input.menu {
                AudioPlayer.playFxPositive()
                if let newScene = SKScene(fileNamed: "Scores") as? Scores {
                    newScene.scaleMode = .aspectFit
                    newScene.score = self.score
                    self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
                }
            } else {
                AudioPlayer.playFxSelect()
                self.state = .running
            }

        case .running:
            switch id {
            case Input.moveLeft:
                self.keyRepeatFrames = 0
                self.events.insert(id)

            case Input.moveRight:
                self.keyRepeatFrames = 0
                self.events.insert(id)

            case Input.softDrop:
                self.keyRepeatFrames = 0
                self.events.insert(id)

            case Input.rotateLeft:
                self.events.insert(id)

            case Input.rotateRight:
                self.events.insert(id)

            case Input.menu:
                AudioPlayer.playFxSelect()
                self.state = .paused

            default:
                break
            }
        }
    }

    func inputUp(id: Input) {
        self.events.remove(id)
    }
}
