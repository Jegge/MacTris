//
//  SKTileMapNode+Animation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.07.26.
//

import SpriteKit

extension SKNode {
    private static let shakeAnimationName = "shakeAnimation"

    func shake() {
        self.removeAction(forKey: SKNode.shakeAnimationName)
        self.run(
            SKAction.sequence([
                SKAction.moveBy(x: 30, y: 0, duration: 0.02),
                SKAction.moveBy(x: -60, y: 0, duration: 0.02),
                SKAction.moveBy(x: 40, y: 0, duration: 0.02),
                SKAction.moveBy(x: -10, y: 0, duration: 0.02)
            ]),
            withKey: SKNode.shakeAnimationName
        )
    }

    private static let bounceAnimationName = "bounceAnimation"

    func bounce() {
        self.removeAction(forKey: SKNode.bounceAnimationName)
        self.run(
            SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.15),
                SKAction.scale(to: 1.0, duration: 0.15)
            ]),
            withKey: SKNode.bounceAnimationName
        )
    }
}
