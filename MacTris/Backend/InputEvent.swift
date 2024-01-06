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
    func inputDown(id: Input)
    func inputUp(id: Input)
}

extension InputEventResponder {
    func input(event: InputEvent) {
        if event.isDown {
            self.inputDown(id: event.id)
        } else {
            self.inputUp(id: event.id)
        }
    }
}
