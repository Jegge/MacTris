//
//  Game.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameController
import OSLog

class Game: SceneBase {

    private enum State {
        case running
        case paused
        case gameover
    }

    private struct FrameCount {
        init() {
            self.keyRepeatShiftInitial = 6
            self.keyRepeatShift = 6
        }

        init(options: TetrisOptions) {
            self.keyRepeatShiftInitial = options.autoShift.delays.initial
            self.keyRepeatShift = options.autoShift.delays.repeating
        }

        private static let gravityPerLevel: [Int] = [ 48, 43, 38, 33, 28, 23, 18, 13, 8, 6, 5, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]

        func gravity(level: Int) -> Int {
            return level < FrameCount.gravityPerLevel.count ? FrameCount.gravityPerLevel[level] : 1
        }

        func keyRepeatShift(initial: Bool) -> Int {
            return initial ? self.keyRepeatShiftInitial : self.keyRepeatShift
        }
        func spawn(stackHeight: Int) -> Int {
            return self.spawn + (stackHeight / 4)
        }

        let animation: Int = 4
        let spawn: Int = 16
        let keyRepeatShiftInitial: Int
        let keyRepeatShift: Int
        let keyRepeatDrop: Int = 1
    }

    var options: TetrisOptions = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true, autoShift: .nes, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)

    private var tetris: Tetris?
    private var boardAnimation: TetrisBoardAnimation?
    private var frameCount: FrameCount = FrameCount()

    private var pauseNode: SKNode?
    private var gameOverNode: SKNode?
    private var board: SKTileMapNode?
    private var preview: SKTileMapNode?
    private var labelLevel: SKLabelNode?
    private var labelLines: SKLabelNode?
    private var labelScore: SKLabelNode?
    private var labelTime: SKLabelNode?

    private var framesToWait: Int = 0
    private var events: Set<Input> = Set()
    private var keyRepeatFrames: Int  = 0
    private var keyRepeatIsInitial: Bool = false

    private var lastUpdate: TimeInterval = 0.0
    private let fixedFrameTime: TimeInterval = 1.0 / 60.0
    private var frameTimeAccumulator: TimeInterval = 0.0

    private var numberFormatter = NumberFormatter()
    private var dateFormatter = DateComponentsFormatter()

    private var state: State = .running {
        didSet {
            switch state {
            case .running:
                self.pauseNode?.isHidden = true
                self.gameOverNode?.isHidden = true

            case .paused:
                self.pauseNode?.isHidden = false
                self.gameOverNode?.isHidden = true

            case .gameover:
                self.pauseNode?.isHidden = true
                self.gameOverNode?.isHidden = false

                guard let tetris = self.tetris else {
                    return
                }

                if let label = self.childNode(withName: "//labelFinalScoreTitle") as? SKLabelNode {
                    if let hiscores = try? Hiscore(contentsOfUrl: Hiscore.url, key: Secrets.hiscoreKey), hiscores.isHighscore(score: Hiscore.Score(name: "", value: tetris.score)) {
                        label.text = "New hiscore!"
                    } else {
                        label.text = "Your score:"
                    }
                }

                (self.childNode(withName: "//labelFinalScoreValue") as? SKLabelNode)?.text = self.numberFormatter.string(for: tetris.score)
            }
        }
    }

    private func updateInstructions() {
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

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.pauseNode = self.childNode(withName: "pause")
        self.gameOverNode = self.childNode(withName: "gameOver")
        self.board = self.childNode(withName: "//board") as? SKTileMapNode
        self.preview = self.childNode(withName: "//preview") as? SKTileMapNode
        self.labelLevel = self.childNode(withName: "//labelLevel") as? SKLabelNode
        self.labelLines = self.childNode(withName: "//labelLines") as? SKLabelNode
        self.labelScore = self.childNode(withName: "//labelScore") as? SKLabelNode
        self.labelTime = self.childNode(withName: "//labelTime") as? SKLabelNode

        self.enumerateChildNodes(withName: "//frame") { (node: SKNode, _) in
            (node as? SKSpriteNode)?.centerRect = CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2)
        }

        self.numberFormatter.numberStyle = .decimal

        self.dateFormatter.unitsStyle = .positional
        self.dateFormatter.allowedUnits = [.hour, .minute, .second]
        self.dateFormatter.zeroFormattingBehavior = [.pad]

        Logger.game.info("Begin game with \(self.options, privacy: .public)")

        self.frameCount = FrameCount(options: self.options)
        self.tetris = Tetris(options: self.options)
        self.framesToWait = self.frameCount.gravity(level: self.options.startingLevel)
        self.state = .running

        self.updateInstructions()
        self.labelLevel?.text = self.numberFormatter.string(for: self.options.startingLevel) ?? ""
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

    override func didResignKey() {
        if self.state == .running {
            self.state = .paused
            AudioPlayer.playFxPositive()
        }
    }

    override func update(_ currentTime: TimeInterval) {

        let delta = self.lastUpdate > 0 ? currentTime - self.lastUpdate : 0
        self.lastUpdate = currentTime

        if self.state != .running {
            return
        }

        frameTimeAccumulator += delta
        frameTimeAccumulator = min(frameTimeAccumulator, fixedFrameTime * 5) // cap at 5 frames

        while frameTimeAccumulator >= fixedFrameTime {
            updateFrame(delta: fixedFrameTime)
            frameTimeAccumulator -= fixedFrameTime
        }
    }

    private func handleInput(_ tetris: Tetris) {
        if self.keyRepeatFrames > 0 {
            self.keyRepeatFrames -= 1
        } else if self.boardAnimation == nil, tetris.current != nil {
            if options.hardDrop && self.events.contains(.hardDrop) {
                tetris.hardDrop()
                if options.animations {
                    self.board?.shake(direction: .both)
                }
                AudioPlayer.playFxLock()
                self.events.remove(.hardDrop) // user need to press the key intentionally again for the next piece
                self.framesToWait = self.frameCount.gravity(level: tetris.level)
            } else if self.events.contains(.shiftLeft) {
                if tetris.shiftLeft() {
                    AudioPlayer.playFxShift()
                }
                self.keyRepeatFrames = self.frameCount.keyRepeatShift(initial: self.keyRepeatIsInitial)
                self.keyRepeatIsInitial = false
            } else if self.events.contains(.shiftRight) {
                if tetris.shiftRight() {
                    AudioPlayer.playFxShift()
                }
                self.keyRepeatFrames = self.frameCount.keyRepeatShift(initial: self.keyRepeatIsInitial)
                self.keyRepeatIsInitial = false
            } else if self.events.contains(.softDrop) {
                if !tetris.softDrop(manual: true) {
                    AudioPlayer.playFxLock()
                    self.events.remove(.softDrop) // user need to press the key intentionally again for the next piece
                }
                self.keyRepeatFrames = self.frameCount.keyRepeatDrop
            }

            if self.events.contains(.rotateCounterClockwise) {
                if tetris.rotateCounterClockwise() {
                    AudioPlayer.playFxRotate()
                }
                self.events.remove(.rotateCounterClockwise)
            } else if self.events.contains(.rotateClockwise) {
                if tetris.rotateClockwise() {
                    AudioPlayer.playFxRotate()
                }
                self.events.remove(.rotateClockwise)
            }
        }
    }

    private func handleAutomaticActions(_ tetris: Tetris) {
        if self.framesToWait > 0 {
            self.framesToWait -= 1
        } else if let animation = self.boardAnimation as? DissolveLinesAnimation {
            animation.next()
            if animation.finished {
                self.boardAnimation = nil
                self.framesToWait = self.frameCount.spawn(stackHeight: tetris.stackHeight)
            } else {
                self.framesToWait = self.frameCount.animation
            }
        } else if let animation = self.boardAnimation as? StackOutAnimation {
            animation.next()
            if animation.finished {
                self.state = .gameover
            } else {
                self.framesToWait = self.frameCount.animation
            }
        } else if tetris.current == nil {
            if let lines = tetris.lowestCompletedLines {
                self.boardAnimation = DissolveLinesAnimation(board: tetris.board, lines: lines)
                tetris.clear(lines: lines)
                if lines.count > 3 {
                    AudioPlayer.playFxQuadSuccess()
                } else {
                    AudioPlayer.playFxSuccess()
                }
                self.framesToWait = self.frameCount.animation
            } else if !tetris.spawn() {
                self.boardAnimation = StackOutAnimation(board: tetris.board, fillAmountPerStep: 15)
                AudioPlayer.playFxGameOver()
            } else {
                self.framesToWait = self.frameCount.gravity(level: tetris.level)
                self.keyRepeatFrames = self.frameCount.keyRepeatShiftInitial
            }
        } else if tetris.softDrop(manual: false) {
            self.framesToWait = self.frameCount.gravity(level: tetris.level)
        } else {
            AudioPlayer.playFxLock()
            self.framesToWait = self.frameCount.gravity(level: tetris.level)
        }
    }

    private func updateFrame(delta: TimeInterval) {
        guard let tetris = self.tetris else {
            return
        }

        tetris.addDuration(delta)

        self.handleInput(tetris)
        self.handleAutomaticActions(tetris)

        if let animation = self.boardAnimation {
            self.board?.draw(board: animation.board, appearance: self.options.appearance)
        } else {
            self.board?.draw(board: tetris.board, appearance: self.options.appearance)
        }

        self.labelLevel?.set(text: self.numberFormatter.string(for: tetris.level) ?? "", animated: self.options.animations)
        self.labelLines?.set(text: self.numberFormatter.string(for: tetris.lines) ?? "", animated: self.options.animations)
        self.labelScore?.set(text: self.numberFormatter.string(for: tetris.score) ?? "", animated: self.options.animations)
        self.labelTime?.text = self.dateFormatter.string(from: tetris.duration)
        self.preview?.draw(tetromino: tetris.next.with(position: (2, 1)), appearance: self.options.appearance)
    }

    override func keyDown(with event: NSEvent) {
        if event.isARepeat {
            return
        }
        InputMapper.shared.translate(event: event).forEach {
            self.inputDown(event: $0)
        }
    }

    override func keyUp(with event: NSEvent) {
        InputMapper.shared.translate(event: event).forEach {
            self.inputUp(event: $0)
        }
    }

    override func inputDown(event: InputEvent) {
        switch self.state {
        case .gameover:
            if event.id == .select {
                AudioPlayer.playFxPositive()
                self.transitionToScores(score: self.tetris?.score ?? 0)
            }

        case .paused:
            switch event.id {
            case .menu:
                AudioPlayer.playFxPositive()
                self.transitionToScores(score: self.tetris?.score ?? 0)

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
                self.events.insert(event.id)

            case Input.hardDrop:
                self.keyRepeatFrames = 0
                self.events.insert(event.id)

            case Input.rotateCounterClockwise:
                self.events.insert(event.id)

            case Input.rotateClockwise:
                self.events.insert(event.id)

            case Input.menu:
                self.state = .paused
                AudioPlayer.playFxPositive()

            default:
                break
            }
        }
    }

    override func inputUp(event: InputEvent) {
        self.events.remove(event.id)
    }
}
