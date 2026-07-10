//
//  SKTileMapNode+Animation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.07.26.
//

import SpriteKit

struct BounceCenter: OptionSet {
    let rawValue: Int

    static let horizontal = BounceCenter(rawValue: (1 << 0))
    static let vertical = BounceCenter(rawValue: (1 << 1))
    static let none: BounceCenter = []
    static let both: BounceCenter = [.horizontal, .vertical]
}

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
    func bounce(center: BounceCenter = .both) {
        self.removeAction(forKey: SKNode.bounceAnimationName)

        var offset: CGPoint = .zero
        if center.contains(.horizontal) {
            offset.x += self.frame.size.width / 2
        }

        if center.contains(.vertical) {
            offset.x += self.frame.size.height / 2
        }

        self.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.5, duration: 0.15),
                    SKAction.moveBy(x: -offset.x * 0.5, y: -offset.y * 0.5, duration: 0.15)
                ]),
                SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.15),
                    SKAction.moveBy(x: offset.x * 0.5, y: offset.y * 0.5, duration: 0.15)
                ])
            ]),
            withKey: SKNode.bounceAnimationName
        )
    }
}
