//
//  StateMachine.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 19.07.26.
//

import Foundation

/// Delegate protocol for state machine lifecycle events.
protocol StateMachineDelegate<State>: AnyObject {
    associatedtype State: Equatable
    func stateMachine(_ stateMachine: StateMachine<State>, willLeave state: State)
    func stateMachine(_ stateMachine: StateMachine<State>, didEnter state: State)
}

/// A simple finite-state machine that only allows transitions defined at
/// initialization. Invalid transitions are silently ignored.
final class StateMachine<State: Equatable> {

    init(initialState: State, transitions: [(oldState: State, newState: State)]) {
        self.current = initialState
        self.transitions = transitions
    }

    private(set) var current: State
    private(set) var transitions: [(oldState: State, newState: State)]

    weak var delegate: (any StateMachineDelegate<State>)?

    /// Attempts to transition to the new state. Returns `false` if the transition is not defined.
    @discardableResult func transition(to newState: State) -> Bool {
        guard transitions.contains(where: { self.current == $0.oldState && $0.newState == newState }) else {
            return false
        }

        self.delegate?.stateMachine(self, willLeave: self.current)
        current = newState
        self.delegate?.stateMachine(self, didEnter: self.current)

        return true
    }
}
