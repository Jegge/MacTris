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

    private var tetris: Tetris?
    private var completed: Range<Int>?

    private var framesToWait: Int = 0
    private var events: Set<Input> = Set()
    private var keyRepeatFrames: Int  = 0
    private var keyRepeatIsInitial: Bool = false
    private var lastUpdate: TimeInterval = 0

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

                AudioPlayer.playFxGameOver()
            }
        }
    }

    var startingLevel: Int = 0
    var randomGeneratorMode: RandomGeneratorMode = .sevenBag
    var appearance: Appearance = .plain
    var autoShift: AutoShift = .modern {
        didSet {
            FrameCount.keyRepeatShiftInitial = self.autoShift.delays.initial
            FrameCount.keyRepeatShift = self.autoShift.delays.repeating
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

        Logger.game.info("Begin game: RNG: \(self.randomGeneratorMode, privacy: .public), DAS: \(self.autoShift, privacy: .public)")

        self.tetris = Tetris(random: self.randomGeneratorMode.createGenerator(), startingLevel: self.startingLevel)
        self.framesToWait = FrameCount.gravity(level: self.startingLevel)
        self.state = .running

        self.updateInstructions()
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

        guard let tetris = self.tetris else {
            return
        }

        tetris.addDuration(delta)

        if self.keyRepeatFrames > 0 {
            self.keyRepeatFrames -= 1
        } else if self.completed == nil, tetris.current != nil {
            if self.events.contains(.shiftLeft) {
                if tetris.shiftLeft() {
                    AudioPlayer.playFxShift()
                }
                self.keyRepeatFrames = self.keyRepeatIsInitial ? FrameCount.keyRepeatShiftInitial : FrameCount.keyRepeatShift
                self.keyRepeatIsInitial = false
            } else if self.events.contains(.shiftRight) {
                if tetris.shiftRight() {
                    AudioPlayer.playFxShift()
                }
                self.keyRepeatFrames = self.keyRepeatIsInitial ? FrameCount.keyRepeatShiftInitial : FrameCount.keyRepeatShift
                self.keyRepeatIsInitial = false
            } else if self.events.contains(.softDrop) {
                if !tetris.softDrop(manual: true) {
                    AudioPlayer.playFxLock()
                }
                self.keyRepeatFrames = FrameCount.keyRepeatDrop
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

        if self.framesToWait > 0 {
            self.framesToWait -= 1
        } else if let completed = self.completed {
            if tetris.dissolve(completed: completed) {
                if completed.count > 3 {
                    AudioPlayer.playFxQuadSuccess()
                } else {
                    AudioPlayer.playFxSuccess()
                }
                self.completed = tetris.lowestCompletedLines
                self.framesToWait = FrameCount.spawn
            } else {
                self.framesToWait = FrameCount.dissolve
            }
        } else if tetris.current == nil {
            self.completed = tetris.lowestCompletedLines
            if self.completed == nil {
                if !tetris.spawn() {
                    self.state = .gameover
                }
                self.framesToWait = FrameCount.gravity(level: tetris.level)
                self.keyRepeatFrames = FrameCount.keyRepeatShiftInitial
            }
        } else if tetris.softDrop(manual: false) {
            self.framesToWait = FrameCount.gravity(level: tetris.level)
        } else {
            AudioPlayer.playFxLock()
            self.framesToWait = FrameCount.gravity(level: tetris.level)
        }

        (self.childNode(withName: "//board") as? SKTileMapNode)?.draw(board: tetris.board, appearance: self.appearance)
        (self.childNode(withName: "//labelLevel") as? SKLabelNode)?.text = self.numberFormatter.string(for: tetris.level)
        (self.childNode(withName: "//labelLines") as? SKLabelNode)?.text = self.numberFormatter.string(for: tetris.lines)
        (self.childNode(withName: "//labelScore") as? SKLabelNode)?.text = self.numberFormatter.string(for: tetris.score)
        (self.childNode(withName: "//labelTime") as? SKLabelNode)?.text = self.dateFormatter.string(from: tetris.duration)
        (self.childNode(withName: "//preview") as? SKTileMapNode)?.draw(tetronimo: tetris.next.with(position: (2, 1)), appearance: self.appearance)
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
                self.keyRepeatIsInitial = true
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

    override func inputUp (event: InputEvent) {
        self.events.remove(event.id)
    }
}
