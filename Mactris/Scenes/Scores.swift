//
//  Hiscores.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit

class Scores: SKScene {

    public var score: Int?
    private var index: Int?

    private var hiscores: Hiscore = Hiscore()

    private func update () {
        for (index, score) in hiscores.scores.enumerated() {
            guard let value = self.childNode(withName: "labelScore\(index)") as? SKLabelNode,
                  let name = self.childNode(withName: "labelName\(index)") as? SKLabelNode,
                  let number = self.childNode(withName: "labelIndex\(index)") as? SKLabelNode
            else {
                continue
            }

            name.text = score.name
            name.fontColor = self.index == index ? NSColor(named: "MenuHilite") :  NSColor(named: "MenuDefault")

            value.text = String(format: "%10d", score.value)
            value.fontColor = self.index == index ? NSColor(named: "MenuHilite") :  NSColor(named: "MenuDefault")

            number.fontColor = self.index == index ? NSColor(named: "MenuHilite") :  NSColor(named: "MenuDefault")
        }
    }

    override func didMove(to view: SKView) {
        do {
            self.hiscores = try Hiscore(contentsOfUrl: Hiscore.url)
        } catch {
            print("Failed to load hiscores: \(error)")
            self.hiscores = Hiscore()
        }

        if let score = self.score {
            self.index = self.hiscores.insert(score: Hiscore.Score(name: "", value: score))
        }

        self.update()
    }

    override func keyDown(with event: NSEvent) {
        if let index = self.index {
            switch event.keyCode {
            case KeyBindings.enter:
                self.index = nil

                do {
                    try self.hiscores.write(to: Hiscore.url)
                } catch {
                    print("Failed to save hiscores: \(error)")
                }

            case KeyBindings.backspace:
                self.hiscores.rename(at: index, to: String(self.hiscores.name(at: index).dropLast()))
                self.update()

            default:
                if let characters = event.characters {
                    self.hiscores.rename(at: index, to: self.hiscores.name(at: index) + characters)
                    self.update()
                }
            }
        } else {
            if let newScene = SKScene(fileNamed: "Menu") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
        }
    }
}
