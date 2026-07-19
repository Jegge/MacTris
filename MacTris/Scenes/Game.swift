//
//  Game.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameController

enum GameState {
    case running
    case paused
    case gameover
}

protocol GameStateMachineDelegate: AnyObject {
    func enter(state: GameState)
    func leave(state: GameState)
}

final class GameStateMachine {

    init(initialState: GameState?, transitions: [(oldState: GameState, newState: GameState)]) {
        self.current = initialState
        self.transitions = transitions
    }

    weak var delegate: GameStateMachineDelegate?
    private(set) var current: GameState?
    private(set) var transitions: [(oldState: GameState, newState: GameState)]

    func transition(to newState: GameState) {
        guard transitions.contains(where: { $0.oldState == self.current && $0.newState == newState }) else {
            return
        }

        if let oldState = self.current {
            self.delegate?.leave(state: oldState)
        }
        self.current = newState
        self.delegate?.enter(state: newState)
    }
}

class Game: SceneBase {
    lazy var gameSession: GameSession = {
        GameSession(tetris: Tetris(options: UserDefaults.standard.tetrisOptions), effects: self)
    }()

    let state = GameStateMachine(initialState: .running, transitions: [
            (.running, .paused),
            (.running, .gameover),
            (.paused, .running)
        ])
    let visualOptions: VisualOptions = UserDefaults.standard.visualOptions

    private var pauseNode: SKNode?
    private var gameOverNode: SKNode?
    private var board: SKTileMapNode?
    private var preview: SKTileMapNode?
    private var labelLevel: SKLabelNode?
    private var labelLines: SKLabelNode?
    private var labelScore: SKLabelNode?
    private var labelTime: SKLabelNode?

    private var numberFormatter = NumberFormatter()
    private var dateFormatter = DateComponentsFormatter()

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

        self.updateInstructions()
        self.labelLevel?.text = self.numberFormatter.string(for: self.gameSession.tetris.level) ?? ""

        self.state.delegate = self
    }

    override func controllerDidConnect() {
        self.updateInstructions()
    }

    override func controllerDidDisconnect() {
        self.updateInstructions()
        self.state.transition(to: .paused)
    }

    override func didResignKey() {
        self.state.transition(to: .paused)
    }

    override func update(_ currentTime: TimeInterval) {
        guard self.state.current == .running else {
            return
        }

        self.gameSession.update(currentTime)

        self.board?.draw(grid: self.gameSession.grid, appearance: self.visualOptions.appearance)
        self.labelLevel?.set(text: self.numberFormatter.string(for: self.gameSession.tetris.level) ?? "", animated: self.visualOptions.animations)
        self.labelLines?.set(text: self.numberFormatter.string(for: self.gameSession.tetris.lines) ?? "", animated: self.visualOptions.animations)
        self.labelScore?.set(text: self.numberFormatter.string(for: self.gameSession.tetris.score) ?? "", animated: self.visualOptions.animations)
        self.labelTime?.text = self.dateFormatter.string(from: self.gameSession.duration)
        self.preview?.draw(tetromino: self.gameSession.tetris.next.with(position: Point(2, 1)), appearance: self.visualOptions.appearance)
    }

    override func input(down event: InputEvent) {
        if event.isARepeat {
            return
        }

        switch (self.state.current, event.id) {

        case (.gameover, .select):
            self.audioFxPlayer?.play(.positive)
            self.transition(to: Scores.self) {
                $0.score = self.gameSession.tetris.score
            }

        case (.paused, .menu):
            self.audioFxPlayer?.play(.positive)
            self.transition(to: Scores.self) {
                $0.score = self.gameSession.tetris.score
            }

        case (.paused, .select):
            self.state.transition(to: .running)

        case(.running, .menu):
            self.state.transition(to: .paused)

        case(.running, let id):
            self.gameSession.input(down: id)

        default:
            break
        }
    }

    override func input(up event: InputEvent) {
        self.gameSession.input(up: event.id)
    }
}

extension Game: EffectDelegate {
    func play(fx: AudioFx) {
        self.audioFxPlayer?.play(fx)
    }

    func shakeBoard() {
        self.board?.shake()
    }

    func gameOver() {
        self.state.transition(to: .gameover)
    }
}

extension Game: GameStateMachineDelegate {
    func enter(state: GameState) {
        switch state {
        case .running:
            self.audioFxPlayer?.play(.positive)
            self.pauseNode?.isHidden = true
            self.gameOverNode?.isHidden = true
            self.gameSession.inputClear()

        case .paused:
            self.audioFxPlayer?.play(.positive)
            self.pauseNode?.isHidden = false
            self.gameOverNode?.isHidden = true

        case .gameover:
            self.pauseNode?.isHidden = true
            self.gameOverNode?.isHidden = false

            if let label = self.childNode(withName: "//labelFinalScoreTitle") as? SKLabelNode {
                if let hiscores = try? Hiscore(contentsOfUrl: Hiscore.url, key: Secrets.hiscoreKey), hiscores.isHighscore(score: Hiscore.Score(name: "", value: self.gameSession.tetris.score)) {
                    label.text = NSLocalizedString("GameFinishedNewHiscore", comment: "New hiscore")
                } else {
                    label.text = NSLocalizedString("GameFinishedYourScore", comment: "No new hiscore")
                }
            }

            (self.childNode(withName: "//labelFinalScoreValue") as? SKLabelNode)?.text = self.numberFormatter.string(for: self.gameSession.tetris.score)
        }
    }

    func leave(state: GameState) {
    }
}
