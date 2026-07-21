//
//  InputEvent.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 03.01.24.
//
/// Represents a single input event (key or button press or release) along with its
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

}

extension InputEvent: CustomStringConvertible {
    var description: String {
        return "\(isDown ? "↓" : "↑")\(id)\(isARepeat ? " (repeated)" : "")"
    }
}
