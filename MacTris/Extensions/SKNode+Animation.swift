//
//  SKNode+Animation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.07.26.
//

import SpriteKit

struct AnimationDirection: OptionSet {
    let rawValue: Int

    static let horizontal = AnimationDirection(rawValue: (1 << 0))
    static let vertical = AnimationDirection(rawValue: (1 << 1))
    static let both: AnimationDirection = [.horizontal, .vertical]
}

extension SKNode {
    private static let shakeAnimationName = "shakeAnimation"

    func shake(direction: AnimationDirection = .both, intensity: CGFloat = 1.0) {
        if self.action(forKey: SKNode.shakeAnimationName) != nil {
            return
        }

        var offset: CGPoint = .zero
        if direction.contains(.horizontal) {
            offset.x = CGFloat.random(in: -1.2...1.2)
        }

        if direction.contains(.vertical) {
            offset.y = CGFloat.random(in: -1.2...1.2)
        }

        self.run(
            SKAction.sequence([
                SKAction.moveBy(x: 30 * offset.x * intensity, y: 30 * offset.y * intensity, duration: 0.02),
                SKAction.moveBy(x: -60 * offset.x * intensity, y: -60 * offset.y * intensity, duration: 0.02),
                SKAction.moveBy(x: 40 * offset.x * intensity, y: 40 * offset.y * intensity, duration: 0.02),
                SKAction.moveBy(x: -10 * offset.x * intensity, y: -10 * offset.y * intensity, duration: 0.02)
            ]),
            withKey: SKNode.shakeAnimationName
        )
    }

    private static let bounceAnimationName = "bounceAnimation"

    func bounce(direction: AnimationDirection = .both) {
        if self.action(forKey: SKNode.bounceAnimationName) != nil {
            return
        }

        var offset: CGPoint = .zero
        if direction.contains(.horizontal) {
            offset.x += self.frame.size.width / 2
        }

        if direction.contains(.vertical) {
            offset.y += self.frame.size.height / 2
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
