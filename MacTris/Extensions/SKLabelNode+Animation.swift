//
//  SKLabel+Animation.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 10.07.26.
//

import SpriteKit

extension SKLabelNode {
    func setText(_ text: String, animated: Bool) {
        if self.text == text {
            return
        }
        self.text = text
        if animated {
            self.bounce()
        }
    }
}
