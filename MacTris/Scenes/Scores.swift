//
//  Scores.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit

class Scores: SKScene {

    public var score: Int?  // = 234566
    private var index: Int?
    private var hiscores: Hiscore = Hiscore()

    private func update () {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        for (index, score) in hiscores.scores.enumerated() {
            guard let value = self.childNode(withName: "//labelScore\(index)") as? SKLabelNode,
                  let name = self.childNode(withName: "//labelName\(index)") as? SKLabelNode,
                  let number = self.childNode(withName: "//labelIndex\(index)") as? SKLabelNode
            else {
                continue
            }

            name.text = score.name
            value.text =  formatter.string(for: score.value)

            if self.index == index {
                name.fontColor = NSColor(named: "MenuHilite")
                value.fontColor = NSColor(named: "MenuHilite")
                number.fontColor = NSColor(named: "MenuHilite")
                if let cursor = self.childNode(withName: "cursor") {
                    cursor.position = CGPoint(x: name.frame.maxX + 2, y: name.position.y + cursor.frame.height / 2)
                }
            } else {
                name.fontColor = NSColor(named: "MenuDefault")
                value.fontColor = NSColor(named: "MenuDefault")
                number.fontColor = NSColor(named: "MenuDefault")
            }
        }
    }

    private func enterText (at index: Int, forEvent event: NSEvent) {
        switch event.keyCode {
        case KeyCode.return.rawValue:
            if !self.hiscores.name(at: index).isEmpty {
                AudioPlayer.playFxPositive()
                self.index = nil

                self.childNode(withName: "cursor")?.removeFromParent()
                self.childNode(withName: "menuBack")?.isHidden = false
                self.childNode(withName: "labelBack")?.isHidden = false

                do {
                    try self.hiscores.write(to: Hiscore.url)
                } catch {
                    print("Failed to save hiscores: \(error)")
                }
            } else {
                AudioPlayer.playFxNegative()
            }

        case KeyCode.delete.rawValue:
            if !self.hiscores.name(at: index).isEmpty {
                AudioPlayer.playFxSelect()
                self.hiscores.rename(at: index, to: String(self.hiscores.name(at: index).dropLast()))
                self.update()
            } else {
                AudioPlayer.playFxNegative()
            }

        default:
            if let character = event.characters?.first, character.isLetter || character.isNumber, self.hiscores.name(at: index).count < Hiscore.nameLength {
                AudioPlayer.playFxSelect()
                self.hiscores.rename(at: index, to: self.hiscores.name(at: index).appending("\(character)"))
                self.update()
            } else {
                AudioPlayer.playFxNegative()
            }
        }
    }

    override func didMove(to view: SKView) {
        guard let cursor = self.childNode(withName: "cursor") else {
            return
        }

        do {
            self.hiscores = try Hiscore(contentsOfUrl: Hiscore.url)
        } catch {
            print("Failed to load hiscores: \(error)")
            self.hiscores = Hiscore()
        }

        if let score = self.score {
            self.index = self.hiscores.insert(score: Hiscore.Score(name: "", value: score))
        }

        if self.index != nil {
            self.childNode(withName: "menuBack")?.isHidden = true
            self.childNode(withName: "labelBack")?.isHidden = true
            cursor.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 0.25),
                SKAction.fadeAlpha(to: 0.25, duration: 0.25)
            ])))
        } else {
            cursor.removeFromParent()
        }

        self.update()
    }

    override func keyDown(with event: NSEvent) {
        if let index = self.index {
            self.enterText(at: index, forEvent: event)
        } else {
            for inputEvent in InputMapper.shared.translate(nsEvent: event) {
                self.inputDown(event: inputEvent.id)
            }
        }
    }
}

extension Scores: InputEventResponder {
    func inputDown(event: Input) {
         if self.index == nil && (event == Input.menu || event == Input.select) {
            AudioPlayer.playFxPositive()
            if let newScene = SKScene(fileNamed: "Menu") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
        }
    }

    func inputUp(event: Input) {
    }
}
