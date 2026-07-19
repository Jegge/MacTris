//
//  TetrisGame.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 18.07.26.
//

import Foundation

protocol EffectDelegate: AnyObject {
    func play(fx: AudioFx)
    func shakeBoard()
    func gameOver()
}

class TetrisGame {

    init(tetris: Tetris, effects: EffectDelegate?) {
        self.tetris = tetris
        self.waitFramesForUpdate = tetris.options.gravity(level: self.tetris.level)
        self.effects = effects
    }

    let tetris: Tetris
    weak var effects: EffectDelegate?

    private var frameRateStabilizer: FrameRateStabilizer = FrameRateStabilizer(desiredFps: 60)
    private var animation: TetrisAnimation?
    private var events: Set<Input> = Set()
    private var waitFramesForUpdate: Int = 0
    private var waitFramesForKeyRepeat: Int = 0
    private var keyRepeatIsInitial: Bool = false

    private(set) var duration: TimeInterval = 0

    var grid: Tetris.Grid {
        self.animation?.grid ?? self.tetris.grid
    }

    func update(_ currentTime: TimeInterval) {
        self.frameRateStabilizer.update(currentTime) { delta in
            self.duration += delta

            if self.animation == nil, self.tetris.current != nil {
                if self.waitFramesForKeyRepeat > 0 {
                    self.waitFramesForKeyRepeat -= 1
                } else {
                    self.handleInput()
                }
            }

            if self.waitFramesForUpdate > 0 {
                self.waitFramesForUpdate -= 1
            } else {
                self.updateFrame()
            }
        }
    }

    private func handleInput() {
        if self.tetris.options.hardDrop && self.events.contains(.hardDrop) {
            self.tetris.hardDrop()
            self.effects?.shakeBoard()
            self.effects?.play(fx: .lock)
            self.events.remove(.hardDrop) // user need to press the key intentionally again for the next piece
            self.waitFramesForUpdate = self.tetris.options.gravity(level: self.tetris.level)
        } else if self.events.contains(.softDrop) {
            if !self.tetris.softDrop(manual: true) {
                self.effects?.play(fx: .lock)
                self.events.remove(.softDrop) // user needs to press the key intentionally again for the next piece
            }
            self.waitFramesForKeyRepeat = TetrisOptions.Frames.keyRepeatDrop
        } else if self.events.contains(.shiftLeft) {
            if self.tetris.shift(.left) {
                self.effects?.play(fx: .shift)
            }
            self.waitFramesForKeyRepeat = self.tetris.options.keyRepeatShift(initial: self.keyRepeatIsInitial)
            self.keyRepeatIsInitial = false
        } else if self.events.contains(.shiftRight) {
            if self.tetris.shift(.right) {
                self.effects?.play(fx: .shift)
            }
            self.waitFramesForKeyRepeat = self.tetris.options.keyRepeatShift(initial: self.keyRepeatIsInitial)
            self.keyRepeatIsInitial = false
        } else if self.events.contains(.rotateCounterClockwise) {
            if self.tetris.rotate(.counterClockwise) {
                self.effects?.play(fx: .rotate)
            }
            self.events.remove(.rotateCounterClockwise)
        } else if self.events.contains(.rotateClockwise) {
            if self.tetris.rotate(.clockwise) {
                self.effects?.play(fx: .rotate)
            }
            self.events.remove(.rotateClockwise)
        }
    }

    private func updateFrame() {
        // first play any special board animations
        if let animation = self.animation as? DissolveLinesAnimation {
            animation.next()
            if animation.finished {
                self.animation = nil
                self.waitFramesForUpdate = self.tetris.options.spawn(stackHeight: tetris.stackHeight)
            } else {
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            }
        } else if let animation = self.animation as? StackOutAnimation {
            animation.next()
            if animation.finished {
                self.effects?.gameOver()
            } else {
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            }
        } else if self.tetris.current == nil { // then handle all actions if there is no tetronimo in game
            if let lines = self.tetris.lowestCompletedLines {
                self.animation = DissolveLinesAnimation(grid: self.tetris.grid, lines: lines)
                self.tetris.clear(lines: lines)
                self.effects?.play(fx: lines.count > 3 ? .quadSuccess : .success)
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            } else if !self.tetris.spawn() {
                self.animation = StackOutAnimation(grid: self.tetris.grid, fillAmountPerStep: 15)
                self.effects?.play(fx: .gameOver)
                self.waitFramesForUpdate = TetrisOptions.Frames.animation
            } else {
                self.waitFramesForUpdate = self.tetris.options.gravity(level: self.tetris.level)
                self.waitFramesForKeyRepeat = self.tetris.options.keyRepeatShift(initial: true)
            }
            return
        } else if self.tetris.softDrop(manual: false) { // otherwise, handle gravity
            self.waitFramesForUpdate = self.tetris.options.gravity(level: tetris.level)
        } else {
            self.effects?.play(fx: .lock)
            self.waitFramesForUpdate = self.tetris.options.gravity(level: tetris.level)
        }
    }

    func input(down id: Input) {
        switch id {
        case Input.shiftLeft:
            self.waitFramesForKeyRepeat = 0
            self.keyRepeatIsInitial = true
            self.events.insert(id)

        case Input.shiftRight:
            self.waitFramesForKeyRepeat = 0
            self.keyRepeatIsInitial = true
            self.events.insert(id)

        case Input.softDrop:
            self.waitFramesForKeyRepeat = 0
            self.events.insert(id)

        case Input.hardDrop:
            self.waitFramesForKeyRepeat = 0
            self.events.insert(id)

        case Input.rotateCounterClockwise:
            self.events.insert(id)

        case Input.rotateClockwise:
            self.events.insert(id)

        default:
            break
        }
    }

    func input(up id: Input) {
        self.events.remove(id)
    }

    func inputClear() {
        self.events.removeAll()
    }
}
