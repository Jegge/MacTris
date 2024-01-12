//
//  Game.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameplayKit
import GameController
import OSLog

class Game: SceneBase {

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
        public static var keyRepeatShiftInitial: Int = 6 // 16
        public static var keyRepeatShift: Int = 6
        public static let keyRepeatDrop: Int = 1
    }

    private struct Score {
        private static let baseScorePerLines = [40, 100, 300, 1200]

        public static func lines(_ range: Range<Int>) -> Int {
            return Score.baseScorePerLines[range.count - 1]
        }

        public static let drop: Int = 1
    }

    private var random: RandomTetrominoShapeGenerator = SevenBagTetrominoShapeGenerator()
    private var current: Tetromino?
    private var completed: Range<Int>?
    private var linesToNextLevel: Int = 0
    private var board: Board = Board()

    private var framesToWait: Int = 0
    private var events: Set<Input> = Set()
    private var keyRepeatFrames: Int  = 0
    private var keyRepeatIsInitial: Bool = false
    private var lastUpdate: TimeInterval = 0
    private var dropSteps: Int = 0

    private var numberFormatter = NumberFormatter()
    private var dateFormatter = DateComponentsFormatter()

    private var state: State = .running {
        didSet {
            switch state {
            case .running:
                self.childNode(withName: "pause")?.isHidden = true
                self.childNode(withName: "gameOver")?.isHidden = true

            case .paused:
                self.childNode(withName: "pause")?.isHidden = false
                self.childNode(withName: "gameOver")?.isHidden = true

            case .gameover:
                self.childNode(withName: "pause")?.isHidden = true
                self.childNode(withName: "gameOver")?.isHidden = false

                if let label = self.childNode(withName: "//labelFinalScoreTitle") as? SKLabelNode {
                    if let hiscores = try? Hiscore(contentsOfUrl: Hiscore.url, key: Secrets.hiscoreKey), hiscores.isHighscore(score: Hiscore.Score(name: "", value: self.score)) {
                        label.text = "New hiscore!"
                    } else {
                        label.text = "Your score:"
                    }
                }

                (self.childNode(withName: "//labelFinalScoreValue") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.score)

                AudioPlayer.playFxGameOver()
            }
        }
    }

    private var duration: TimeInterval = 0 {
        didSet {
            (self.childNode(withName: "//labelTime") as? SKLabelNode)?.text = self.dateFormatter.string(from: self.duration)
        }
    }

    private var lines: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelLines") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.lines)
        }
    }

    private var score: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelScore") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.score)
        }
    }

    private var next: Tetromino? {
        didSet {
            if let preview = self.childNode(withName: "//preview") as? SKTileMapNode {
                preview.clear()
                if let tetromino = self.next {
                    preview.draw(tetronimo: tetromino.with(position: (2, 1)), appearance: self.appearance)
                }
            }
        }
    }

    var level: Int = 0 {
        didSet {
            (self.childNode(withName: "//labelLevel") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.level)
        }
    }

    var randomGeneratorMode: RandomGeneratorMode = .sevenBag {
        didSet {
            self.random = self.randomGeneratorMode.createGenerator()
        }
    }

    var appearance: Appearance = .plain

    var autoShift: AutoShift = .modern {
        didSet {
            FrameCount.keyRepeatShiftInitial = self.autoShift.delays.initial
            FrameCount.keyRepeatShift = self.autoShift.delays.repeating
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
            self.linesToNextLevel += 10
            Logger.game.info("Reached level \(self.level), lines to next level \(self.linesToNextLevel)")
        }

        if range.count > 3 {
            AudioPlayer.playFxQuadSuccess()
        } else {
            AudioPlayer.playFxSuccess()
        }
    }

    private func updateInstructions () {
        if let label = self.childNode(withName: "//labelQuitInstructions") as? SKLabelNode {
            if GCController.controllers().isEmpty {
                label.text = "— \(InputMapper.shared.describeIdForKeyboard(.menu)) to quit —"
            } else {
                label.text = "— \(InputMapper.shared.describeIdForController(.menu)) to quit —"
            }
        }

        if let label = self.childNode(withName: "//labelPauseInstructions") as? SKLabelNode {
            if GCController.controllers().isEmpty {
                label.text = "— \(InputMapper.shared.describeIdForKeyboard(.menu)) to pause —"
            } else {
                label.text = "— \(InputMapper.shared.describeIdForController(.menu)) to pause —"
            }
        }

        if let label = self.childNode(withName: "//labelGameOverInstructions") as? SKLabelNode {
            if GCController.controllers().isEmpty {
                label.text = "— \(InputMapper.shared.describeIdForKeyboard(.select)) to continue —"
            } else {
                label.text = "— \(InputMapper.shared.describeIdForController(.select)) to continue —"
            }
        }

        if let label = self.childNode(withName: "//labelResumeInstructions") as? SKLabelNode {
            if GCController.controllers().isEmpty {
                label.text = "— \(InputMapper.shared.describeIdForKeyboard(.select)) to resume —"
            } else {
                label.text = "— \(InputMapper.shared.describeIdForController(.select)) to resume —"
            }
        }
    }

    override func didMove (to view: SKView) {
        super.didMove(to: view)

        self.enumerateChildNodes(withName: "//frame") { (node: SKNode, _) in
            (node as? SKSpriteNode)?.centerRect = CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2)
        }

        self.numberFormatter.numberStyle = .decimal

        self.dateFormatter.unitsStyle = .positional
        self.dateFormatter.allowedUnits = [.hour, .minute, .second]
        self.dateFormatter.zeroFormattingBehavior = [.pad, .dropLeading]

        self.score = 0
        self.lines = 0
        self.duration = 0
        self.linesToNextLevel = min(self.level * 10 + 10, max(100, self.level * 10 - 50))

        self.board = Board()
        self.next = Tetromino(shape: random.next())
        self.current = Tetromino(shape: random.next(), rotation: 0, position: board.spawnPosition())

        self.framesToWait = FrameCount.gravity(level: self.level)
        self.state = .running

        self.updateInstructions()

        Logger.game.info("Begin game: RNG: \(self.randomGeneratorMode), DAS: \(self.autoShift)")
        Logger.game.info("Starting level \(self.level), lines to next level \(self.linesToNextLevel)")
    }

    override func controllerDidConnect() {
        self.updateInstructions()
    }

    override func controllerDidDisconnect() {
        self.updateInstructions()
        if self.state == .running {
            self.state = .paused
            AudioPlayer.playFxPositive()
        }
    }

    override func update (_ currentTime: TimeInterval) {

        let delta = self.lastUpdate > 0 ? currentTime - self.lastUpdate : 0
        self.lastUpdate = currentTime

        if self.state != .running {
            return
        }

        self.duration += delta

        if self.keyRepeatFrames > 0 {
            self.keyRepeatFrames -= 1
        } else {
            if self.completed == nil, let current = self.current {
                if self.events.contains(.shiftLeft) {
                    if !self.board.collides(tetronimo: current.shiftedLeft()) {
                        self.current = current.shiftedLeft()
                        AudioPlayer.playFxShift()
                    }
                    self.keyRepeatFrames = self.keyRepeatIsInitial ? FrameCount.keyRepeatShiftInitial : FrameCount.keyRepeatShift
                    self.keyRepeatIsInitial = false
                } else if self.events.contains(.shiftRight) {
                    if !self.board.collides(tetronimo: current.shiftedRight()) {
                        self.current = current.shiftedRight()
                        AudioPlayer.playFxShift()
                    }
                    self.keyRepeatFrames = self.keyRepeatIsInitial ? FrameCount.keyRepeatShiftInitial : FrameCount.keyRepeatShift
                    self.keyRepeatIsInitial = false
                } else if self.events.contains(.softDrop) {
                    if !self.board.collides(tetronimo: current.dropped()) {
                        self.current = current.dropped()
                        self.dropSteps += 1
                    } else {
                        self.board.lock(tetronimo: self.current)
                        AudioPlayer.playFxDrop()
                        self.score += self.dropSteps * Score.drop
                        self.dropSteps = 0
                        self.current = nil
                    }
                    self.keyRepeatFrames = FrameCount.keyRepeatDrop
                }
            }

            if self.completed == nil, let current = self.current {
                if self.events.contains(.rotateLeft) {
                    if !self.board.collides(tetronimo: current.rotatedLeft()) {
                        self.current = current.rotatedLeft()
                        AudioPlayer.playFxRotate()
                    }
                    self.events.remove(.rotateLeft)
                } else if self.events.contains(.rotateRight) {
                    if !self.board.collides(tetronimo: current.rotatedRight()) {
                        self.current = current.rotatedRight()
                        AudioPlayer.playFxRotate()
                    }
                    self.events.remove(.rotateRight)
                }
            }
        }

        if self.framesToWait > 0 {
            self.framesToWait -= 1
        } else if let completed = self.completed {
            if board.dissolve(rows: completed) {
                board.drop(rows: completed)
                self.score(rows: completed)
                self.completed = board.lowestCompletedRows()
                self.framesToWait = FrameCount.spawn
            } else {
                self.framesToWait = FrameCount.dissolve
            }
        } else if self.current == nil {
            self.completed = board.lowestCompletedRows()
            if self.completed == nil {
                self.current = self.next?.with(position: board.spawnPosition())
                self.next = Tetromino(shape: random.next())
                self.framesToWait = FrameCount.spawn
                self.keyRepeatFrames = FrameCount.keyRepeatShiftInitial

                if let current = self.current, board.collides(tetronimo: current) {
                    Logger.game.info("Stacked out!")
                    self.state = .gameover
                }
            }
        } else if !self.board.collides(tetronimo: current!.dropped()) { // let changed = self.board.apply(tetromino: self.current!, change: { $0.dropped() }) {
            self.current = self.current?.dropped()
            self.framesToWait = FrameCount.gravity(level: self.level)
        } else {
            self.board.lock(tetronimo: self.current)
            AudioPlayer.playFxDrop()
            self.score += self.dropSteps * Score.drop
            self.dropSteps = 0
            self.current = nil
            self.framesToWait = FrameCount.gravity(level: self.level)
        }

        (self.childNode(withName: "//board") as? SKTileMapNode)?.update(board: self.board.with(tetronimo: self.current), appearance: self.appearance)
    }

    override func keyDown (with event: NSEvent) {
        if event.isARepeat {
            return
        }
        InputMapper.shared.translate(event: event).forEach {
            self.inputDown(event: $0)
        }
    }

    override func keyUp (with event: NSEvent) {
        InputMapper.shared.translate(event: event).forEach {
            self.inputUp(event: $0)
        }
    }

    override func inputDown (event: InputEvent) {
        switch self.state {
        case .gameover:
            if event.id == .select {
                AudioPlayer.playFxPositive()
                self.transitionToScores(score: self.score)
            }

        case .paused:
            switch event.id {
            case .menu:
                AudioPlayer.playFxPositive()
                self.transitionToScores(score: self.score)

            case .select:
                AudioPlayer.playFxPositive()
                self.state = .running
                self.events.removeAll()

            default:
                break
            }

        case .running:
            switch event.id {
            case Input.shiftLeft:
                self.keyRepeatFrames = 0
                self.keyRepeatIsInitial = true
                self.events.insert(event.id)

            case Input.shiftRight:
                self.keyRepeatFrames = 0
                self.keyRepeatIsInitial = true
                self.events.insert(event.id)

            case Input.softDrop:
                self.keyRepeatFrames = 0
                self.keyRepeatIsInitial = true
                self.events.insert(event.id)

            case Input.rotateLeft:
                self.events.insert(event.id)

            case Input.rotateRight:
                self.events.insert(event.id)

            case Input.menu:
                self.state = .paused
                AudioPlayer.playFxPositive()

            default:
                break
            }
        }
    }

    override func inputUp (event: InputEvent) {
        self.events.remove(event.id)
    }
}
