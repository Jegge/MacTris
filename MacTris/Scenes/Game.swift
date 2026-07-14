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

    var options: TetrisOptions = TetrisOptions(startingLevel: 0, appearance: .plain, animations: true, autoShift: .nes, randomGeneratorMode: .nes, wallKick: false, hardDrop: false)

    private var boardGame: TetrisBoard?
    private var boardAnimation: TetrisBoardAnimation?

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
    private var waitFramesForKeyRepeat: Int  = 0
    private var keyRepeatIsInitial: Bool = false

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

                guard let board = self.boardGame else {
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
            ? self.inputMapper.describeIdForKeyboard(.menu)
            : self.inputMapper.describeIdForController(.menu)

        let selectKey = GCController.controllers().isEmpty
            ? self.inputMapper.describeIdForKeyboard(.select)
            : self.inputMapper.describeIdForController(.select)

        if let label = self.childNode(withName: "//labelQuitInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionQuit", comment: "Has a string argument for the key"), menuKey)
        }

        if let label = self.childNode(withName: "//labelPauseInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionPause", comment: "Has a string argument for the key"), menuKey)
        }

        if let label = self.childNode(withName: "//labelGameOverInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionContinue", comment: "Has a string argument for the key"), selectKey)
        }

        if let label = self.childNode(withName: "//labelResumeInstructions") as? SKLabelNode {
            label.text = String(format: NSLocalizedString("GamePauseMenuInstructionResume", comment: "Has a string argument for the key"), selectKey)
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
        self.boardGame = TetrisBoard(options: self.options)
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
            self.fxPlayer.playPositive()
        }
    }

    override func didResignKey() {
        if self.state == .running {
            self.state = .paused
            self.fxPlayer.playPositive()
        }
    }

    override func update(_ currentTime: TimeInterval) {
        guard self.state == .running, let board = self.boardGame else {
            return
        }

        self.frameRateStabilizer.update(currentTime) { delta in
            board.addDuration(delta)

            if self.boardAnimation == nil, board.current != nil {
                if self.waitFramesForKeyRepeat > 0 {
                    self.waitFramesForKeyRepeat -= 1
                } else {
                    self.handleInput(board)
                }
            }

            if self.waitFramesForUpdate > 0 {
                self.waitFramesForUpdate -= 1
            } else {
                self.updateFrame(board)
            }
        }

        if let animation = self.boardAnimation {
            self.board?.draw(board: animation.board, appearance: self.options.appearance)
        } else {
            self.board?.draw(board: board.grid, appearance: self.options.appearance)
        }

        self.labelLevel?.set(text: self.numberFormatter.string(for: board.level) ?? "", animated: self.options.animations)
        self.labelLines?.set(text: self.numberFormatter.string(for: board.lines) ?? "", animated: self.options.animations)
        self.labelScore?.set(text: self.numberFormatter.string(for: board.score) ?? "", animated: self.options.animations)
        self.labelTime?.text = self.dateFormatter.string(from: board.duration)
        self.preview?.draw(tetromino: board.next.with(position: (2, 1)), appearance: self.options.appearance)
    }

    private func handleInput(_ board: TetrisBoard) {
        if options.hardDrop && self.events.contains(.hardDrop) {
            board.hardDrop()
            if options.animations {
                self.board?.shake(direction: .both)
            }
            self.fxPlayer.playLock()
            self.events.remove(.hardDrop) // user need to press the key intentionally again for the next piece
            self.waitFramesForUpdate = self.options.gravity(level: board.level)
        } else if self.events.contains(.softDrop) {
            if !board.softDrop(manual: true) {
                self.fxPlayer.playLock()
                self.events.remove(.softDrop) // user needs to press the key intentionally again for the next piece
            }
            self.waitFramesForKeyRepeat = TetrisOptions.Frames.keyRepeatDrop
        } else if self.events.contains(.shiftLeft) {
            if board.shiftLeft() {
                self.fxPlayer.playShift()
            }
            self.waitFramesForKeyRepeat = self.options.keyRepeatShift(initial: self.keyRepeatIsInitial)
            self.keyRepeatIsInitial = false
        } else if self.events.contains(.shiftRight) {
            if board.shiftRight() {
                self.fxPlayer.playShift()
            }
            self.waitFramesForKeyRepeat = self.options.keyRepeatShift(initial: self.keyRepeatIsInitial)
            self.keyRepeatIsInitial = false
        } else if self.events.contains(.rotateCounterClockwise) {
            if board.rotateCounterClockwise() {
                self.fxPlayer.playRotate()
            }
            self.events.remove(.rotateCounterClockwise)
        } else if self.events.contains(.rotateClockwise) {
            if board.rotateClockwise() {
                self.fxPlayer.playRotate()
            }
            self.events.remove(.rotateClockwise)
        }
    }

    private func updateFrame(_ board: TetrisBoard) {
        // first play any special board animations
        if let animation = self.boardAnimation as? DissolveLinesAnimation {
            animation.next()
            if animation.finished {
                self.boardAnimation = nil
                self.waitFramesForUpdate = self.options.spawn(stackHeight: board.stackHeight)
            } else {
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            }
        } else if let animation = self.boardAnimation as? StackOutAnimation {
            animation.next()
            if animation.finished {
                self.state = .gameover
            } else {
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            }
        } else if board.current == nil { // then handle all actions if there is no tetronimo in game
            if let lines = board.lowestCompletedLines {
                self.boardAnimation = DissolveLinesAnimation(board: board.grid, lines: lines)
                board.clear(lines: lines)
                if lines.count > 3 {
                    self.fxPlayer.playQuadSuccess()
                } else {
                    self.fxPlayer.playSuccess()
                }
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            } else if !board.spawn() {
                self.boardAnimation = StackOutAnimation(board: board.grid, fillAmountPerStep: 15)
                self.fxPlayer.playGameOver()
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            } else {
                self.waitFramesForUpdate = self.options.gravity(level: board.level)
                self.waitFramesForKeyRepeat = self.options.keyRepeatShift(initial: true)
            }
            return
        } else if board.softDrop(manual: false) { // otherwise, handle gravity
            self.waitFramesForUpdate = self.options.gravity(level: board.level)
        } else {
            self.fxPlayer.playLock()
            self.waitFramesForUpdate = self.options.gravity(level: board.level)
        }
    }

    override func inputDown(event: InputEvent) {
        if event.isARepeat {
            return
        }

        switch self.state {
        case .gameover:
            if event.id == .select {
                self.fxPlayer.playPositive()
                self.transitionToScores(score: self.boardGame?.score ?? 0)
            }

        case .paused:
            switch event.id {
            case .menu:
                self.fxPlayer.playPositive()
                self.transitionToScores(score: self.boardGame?.score ?? 0)

            case .select:
                self.fxPlayer.playPositive()
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
                self.fxPlayer.playPositive()

            default:
                break
            }
        }
    }

    override func inputUp(event: InputEvent) {
        self.events.remove(event.id)
    }
}
