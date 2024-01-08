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

    static let inputDownNotification: NSNotification.Name = NSNotification.Name("InputEventInputDown")
    static let inputUpNotification: NSNotification.Name = NSNotification.Name("InputEventInputUp")

    func postNotification () {
        NotificationCenter.default.post(Notification(name: self.isDown ? InputEvent.inputDownNotification : InputEvent.inputUpNotification, object: self, userInfo: nil))
    }
}

extension InputEvent: CustomStringConvertible {
    var description: String {
        return "\(isDown ? "↓" : "↑")\(id)"
    }
}
