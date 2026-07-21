//
//  StateMachineTests.swift
//  MacTrisTests
//
//  Created by Sebastian Boettcher on 22.07.26.
//

import Testing
@testable import MacTris

private class TestDelegate: StateMachineDelegate {
    typealias State = Int

    var willLeave: [Int] = []
    var didEnter: [Int] = []
    var capturedMachine: StateMachine<Int>?

    func stateMachine(_ stateMachine: StateMachine<Int>, willLeave state: Int) {
        willLeave.append(state)
        capturedMachine = stateMachine
    }

    func stateMachine(_ stateMachine: StateMachine<Int>, didEnter state: Int) {
        didEnter.append(state)
        capturedMachine = stateMachine
    }
}

struct StateMachineTests {

    @Test func testInitialStateSet() async throws {
        let machine = StateMachine<Int>(initialState: 1, transitions: [])
        #expect(machine.current == 1)
    }

    @Test func testValidTransition() async throws {
        let delegate = TestDelegate()
        let machine = StateMachine<Int>(initialState: 1, transitions: [(1, 2), (2, 3)])
        machine.delegate = delegate

        #expect(machine.transitions.count == 2)
        #expect(machine.transitions[0].oldState == 1)
        #expect(machine.transitions[0].newState == 2)
        #expect(machine.transitions[1].oldState == 2)
        #expect(machine.transitions[1].newState == 3)

        #expect(machine.transition(to: 2))
        #expect(machine.current == 2)

        #expect(delegate.capturedMachine === machine)
        #expect(delegate.willLeave == [1])
        #expect(delegate.didEnter == [2])
    }

    @Test func testInvalidTransition() async throws {
        let delegate = TestDelegate()
        let machine = StateMachine<Int>(initialState: 1, transitions: [(1, 2), (2, 3)])
        machine.delegate = delegate
        #expect(!machine.transition(to: 3))
        #expect(machine.current == 1)

        #expect(delegate.capturedMachine == nil)
        #expect(delegate.willLeave.isEmpty)
        #expect(delegate.didEnter.isEmpty)
    }

    @Test func testTransitionToSameState() async throws {
        let delegate = TestDelegate()
        let machine = StateMachine<Int>(initialState: 1, transitions: [(1, 1)])
        machine.delegate = delegate

        #expect(machine.transition(to: 1))
        #expect(machine.current == 1)
        #expect(delegate.willLeave == [1])
        #expect(delegate.didEnter == [1])
    }
}
