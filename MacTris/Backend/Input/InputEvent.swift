//
//  InputEvent.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 03.01.24.
//
import Foundation

/// Represents a single input event (key press or release) along with its
/// source and whether it is a repeat.
struct InputEvent: Equatable {

    init(id: Input, isDown: Bool, source: InputSource, isARepeat: Bool = false) {
        self.id = id
        self.isDown = isDown
        self.source = source
        self.isARepeat = isARepeat
    }

    /// The abstract game action.
    let id: Input
    /// `true` if the key/button was pressed, `false` if released.
    let isDown: Bool
    /// Which device generated the event.
    let source: InputSource
    /// `true` if this is a repeating key event (keyboard auto-repeat).
    let isARepeat: Bool

    static let inputDownNotification: NSNotification.Name = NSNotification.Name("InputEventInputDown")
    static let inputUpNotification: NSNotification.Name = NSNotification.Name("InputEventInputUp")

    func postNotification() {
        NotificationCenter.default.post(Notification(name: self.isDown ? InputEvent.inputDownNotification : InputEvent.inputUpNotification, object: self, userInfo: nil))
    }
}

extension InputEvent: CustomStringConvertible {
    var description: String {
        return "\(isDown ? "↓" : "↑")\(id)\(isARepeat ? " (repeated)" : "")"
    }
}
