//
//  Game.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameController

class Game: SceneBase {

    private enum State {
        case running
        case paused
        case gameover
    }

    let options: TetrisOptions = UserDefaults.standard.tetrisOptions

    private var tetris: Tetris?
    private var animation: TetrisAnimation?

    private var pauseNode: SKNode?
    private var gameOverNode: SKNode?
    private var board: SKTileMapNode?
    private var preview: SKTileMapNode?
    private var labelLevel: SKLabelNode?
    private var labelLines: SKLabelNode?
    private var labelScore: SKLabelNode?
    private var labelTime: SKLabelNode?

    private var events: Set<Input> = Set()
    private var waitFramesForUpdate: Int = 0
    private var waitFramesForKeyRepeat: Int = 0
    private var keyRepeatIsInitial: Bool = false
    private var duration: TimeInterval = 0

    private var frameRateStabilizer = FrameRateStabilizer(desiredFps: 60)

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

                guard let board = self.tetris else {
                    return
                }

                if let label = self.childNode(withName: "//labelFinalScoreTitle") as? SKLabelNode {
                    if let hiscores = try? Hiscore(contentsOfUrl: Hiscore.url, key: Secrets.hiscoreKey), hiscores.isHighscore(score: Hiscore.Score(name: "", value: board.score)) {
                        label.text = NSLocalizedString("GameFinishedNewHiscore", comment: "New hiscore")
                    } else {
                        label.text = NSLocalizedString("GameFinishedYourScore", comment: "No new hiscore")
                    }
                }

                (self.childNode(withName: "//labelFinalScoreValue") as? SKLabelNode)?.text = self.numberFormatter.string(for: board.score)
            }
        }
    }

    private func updateInstructions() {
        let menuKey = GCController.controllers().isEmpty
            ? self.inputMapper?.describeIdForKeyboard(.menu)
            : self.inputMapper?.describeIdForController(.menu)

        let selectKey = GCController.controllers().isEmpty
            ? self.inputMapper?.describeIdForKeyboard(.select)
            : self.inputMapper?.describeIdForController(.select)

        if let label = self.childNode(withName: "//labelQuitInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionQuit", comment: "Has a string argument for the key"), menuKey ?? InputMapper.unknownCharacterDescription)
        }

        if let label = self.childNode(withName: "//labelPauseInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionPause", comment: "Has a string argument for the key"), menuKey ?? InputMapper.unknownCharacterDescription)
        }

        if let label = self.childNode(withName: "//labelGameOverInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionContinue", comment: "Has a string argument for the key"), selectKey ?? InputMapper.unknownCharacterDescription)
        }

        if let label = self.childNode(withName: "//labelResumeInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionResume", comment: "Has a string argument for the key"), selectKey ?? InputMapper.unknownCharacterDescription)
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
        self.tetris = Tetris(options: self.options)
        self.waitFramesForUpdate = self.options.gravity(level: self.options.startingLevel)
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
            self.audioFxPlayer?.play(.positive)
        }
    }

    override func didResignKey() {
        if self.state == .running {
            self.state = .paused
            self.audioFxPlayer?.play(.positive)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard self.state == .running, let tetris = self.tetris else {
            return
        }

        self.frameRateStabilizer.update(currentTime) { delta in
            self.duration += delta

            if self.animation == nil, tetris.current != nil {
                if self.waitFramesForKeyRepeat > 0 {
                    self.waitFramesForKeyRepeat -= 1
                } else {
                    self.handleInput(tetris)
                }
            }

            if self.waitFramesForUpdate > 0 {
                self.waitFramesForUpdate -= 1
            } else {
                self.updateFrame(tetris)
            }
        }

        self.board?.draw(grid: self.animation?.grid ?? tetris.grid, appearance: self.options.appearance)
        self.labelLevel?.set(text: self.numberFormatter.string(for: tetris.level) ?? "", animated: self.options.animations)
        self.labelLines?.set(text: self.numberFormatter.string(for: tetris.lines) ?? "", animated: self.options.animations)
        self.labelScore?.set(text: self.numberFormatter.string(for: tetris.score) ?? "", animated: self.options.animations)
        self.labelTime?.text = self.dateFormatter.string(from: self.duration)
        self.preview?.draw(tetromino: tetris.next.with(position: Point(2, 1)), appearance: self.options.appearance)
    }

    private func handleInput(_ tetris: Tetris) {
        if options.hardDrop && self.events.contains(.hardDrop) {
            tetris.hardDrop()
            if options.animations {
                self.board?.shake(direction: .both)
            }
            self.audioFxPlayer?.play(.lock)
            self.events.remove(.hardDrop) // user need to press the key intentionally again for the next piece
            self.waitFramesForUpdate = self.options.gravity(level: tetris.level)
        } else if self.events.contains(.softDrop) {
            if !tetris.softDrop(manual: true) {
                self.audioFxPlayer?.play(.lock)
                self.events.remove(.softDrop) // user needs to press the key intentionally again for the next piece
            }
            self.waitFramesForKeyRepeat = TetrisOptions.Frames.keyRepeatDrop
        } else if self.events.contains(.shiftLeft) {
            if tetris.shift(.left) {
                self.audioFxPlayer?.play(.shift)
            }
            self.waitFramesForKeyRepeat = self.options.keyRepeatShift(initial: self.keyRepeatIsInitial)
            self.keyRepeatIsInitial = false
        } else if self.events.contains(.shiftRight) {
            if tetris.shift(.right) {
                self.audioFxPlayer?.play(.shift)
            }
            self.waitFramesForKeyRepeat = self.options.keyRepeatShift(initial: self.keyRepeatIsInitial)
            self.keyRepeatIsInitial = false
        } else if self.events.contains(.rotateCounterClockwise) {
            if tetris.rotate(.counterClockwise) {
                self.audioFxPlayer?.play(.rotate)
            }
            self.events.remove(.rotateCounterClockwise)
        } else if self.events.contains(.rotateClockwise) {
            if tetris.rotate(.clockwise) {
                self.audioFxPlayer?.play(.rotate)
            }
            self.events.remove(.rotateClockwise)
        }
    }

    private func updateFrame(_ tetris: Tetris) {
        // first play any special board animations
        if let animation = self.animation as? DissolveLinesAnimation {
            animation.next()
            if animation.finished {
                self.animation = nil
                self.waitFramesForUpdate = self.options.spawn(stackHeight: tetris.stackHeight)
            } else {
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            }
        } else if let animation = self.animation as? StackOutAnimation {
            animation.next()
            if animation.finished {
                self.state = .gameover
            } else {
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            }
        } else if tetris.current == nil { // then handle all actions if there is no tetronimo in game
            if let lines = tetris.lowestCompletedLines {
                self.animation = DissolveLinesAnimation(grid: tetris.grid, lines: lines)
                tetris.clear(lines: lines)
                if lines.count > 3 {
                    self.audioFxPlayer?.play(.quadSuccess)
                } else {
                    self.audioFxPlayer?.play(.success)
                }
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            } else if !tetris.spawn() {
                self.animation = StackOutAnimation(grid: tetris.grid, fillAmountPerStep: 15)
                self.audioFxPlayer?.play(.gameOver)
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            } else {
                self.waitFramesForUpdate = self.options.gravity(level: tetris.level)
                self.waitFramesForKeyRepeat = self.options.keyRepeatShift(initial: true)
            }
            return
        } else if tetris.softDrop(manual: false) { // otherwise, handle gravity
            self.waitFramesForUpdate = self.options.gravity(level: tetris.level)
        } else {
            self.audioFxPlayer?.play(.lock)
            self.waitFramesForUpdate = self.options.gravity(level: tetris.level)
        }
    }

    override func inputDown(event: InputEvent) {
        if event.isARepeat {
            return
        }

        switch self.state {
        case .gameover:
            if event.id == .select {
                self.audioFxPlayer?.play(.positive)
                self.transition(to: Scores.self) {
                    $0.score = self.tetris?.score ?? 0
                }
            }

        case .paused:
            switch event.id {
            case .menu:
                self.audioFxPlayer?.play(.positive)
                self.transition(to: Scores.self) {
                    $0.score = self.tetris?.score ?? 0
                }

            case .select:
                self.audioFxPlayer?.play(.positive)
                self.state = .running
                self.events.removeAll()

            default:
                break
            }

        case .running:
            switch event.id {
            case Input.shiftLeft:
                self.waitFramesForKeyRepeat = 0
                self.keyRepeatIsInitial = true
                self.events.insert(event.id)

            case Input.shiftRight:
                self.waitFramesForKeyRepeat = 0
                self.keyRepeatIsInitial = true
                self.events.insert(event.id)

            case Input.softDrop:
                self.waitFramesForKeyRepeat = 0
                self.events.insert(event.id)

            case Input.hardDrop:
                self.waitFramesForKeyRepeat = 0
                self.events.insert(event.id)

            case Input.rotateCounterClockwise:
                self.events.insert(event.id)

            case Input.rotateClockwise:
                self.events.insert(event.id)

            case Input.menu:
                self.state = .paused
                self.audioFxPlayer?.play(.positive)

            default:
                break
            }
        }
    }

    override func inputUp(event: InputEvent) {
        self.events.remove(event.id)
    }
}
