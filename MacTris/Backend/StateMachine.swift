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

    init(initialState: State?, transitions: [(oldState: State, newState: State)]) {
        self.current = initialState
        self.transitions = transitions
    }

    private(set) var current: State?
    private(set) var transitions: [(oldState: State, newState: State)]

    weak var delegate: (any StateMachineDelegate<State>)?

    func transition(to newState: State) {
        guard transitions.contains(where: { $0.oldState == current && $0.newState == newState }) else {
            return
        }

        if let oldState = current {
            delegate?.stateMachine(self, willLeave: oldState)
        }
        current = newState
        delegate?.stateMachine(self, didEnter: newState)
    }
}
