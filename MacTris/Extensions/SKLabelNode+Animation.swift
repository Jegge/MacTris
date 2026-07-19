//
//  SKLabelNode+Animation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.07.26.
//

import SpriteKit

extension SKLabelNode {
    /// Sets the label text and optionally plays a bounce animation if the text changed.
    func set(text: String, animated: Bool) {
        if self.text == text {
            return
        }
        self.text = text
        if animated {
            self.bounce(direction: .horizontal)
        }
    }
}
