//
//  SkScene+Transition.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 07.01.24.
//

import Foundation
import SpriteKit

extension SKScene {
    func transitionToGame (level: Int) {
        if let newScene = SKScene(fileNamed: "Game") as? Game {
            newScene.scaleMode = self.scaleMode
            newScene.level = level
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        }
    }

    func transitionToScores (score: Int? = nil) {
        if let newScene = SKScene(fileNamed: "Scores") as? Scores {
            newScene.scaleMode = self.scaleMode
            newScene.score = score
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        }
    }

    func transitionToSettings () {
        if let newScene = SKScene(fileNamed: "Settings") {
            newScene.scaleMode = self.scaleMode
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        }
    }

    func transitionToMenu () {
        if let newScene = SKScene(fileNamed: "Menu") {
            newScene.scaleMode = self.scaleMode
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        }
    }
}
