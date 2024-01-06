//
//  InputEvent.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import GameController

struct InputEvent: Equatable {
    let id: Input
    let isDown: Bool
}

protocol InputEventResponder {
    func inputDown(event: InputEvent)
    func inputUp(event: InputEvent)
}

extension InputEventResponder {
    func input(event: InputEvent) {
        if event.isDown {
            self.inputDown(event: event)
        } else {
            self.inputUp(event: event)
        }
    }
}
