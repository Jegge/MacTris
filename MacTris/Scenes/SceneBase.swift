//
//  InputEventScene.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 08.01.24.
//

import SpriteKit
import Foundation

class SceneBase: SKScene {

    private var inputDownObserver: NSObjectProtocol?
    private var inputUpObserver: NSObjectProtocol?
    private var controllerDidConnectObserver: NSObjectProtocol?
    private var controllerDidDisconnectObserver: NSObjectProtocol?
    private var didEnterFullScreenObserver: NSObjectProtocol?
    private var didExitFullScreenObserver: NSObjectProtocol?

    private var eventMonitor: Any?

    private let keyCodesToModifierFlags: [(keyCode: KeyCode, flag: NSEvent.ModifierFlags)] = [
        (keyCode: .command, flag: .command),
        (keyCode: .rightcommand, flag: .command),
        (keyCode: .option, flag: .option),
        (keyCode: .rightoption, flag: .option),
        (keyCode: .shift, flag: .shift),
        (keyCode: .rightshift, flag: .shift),
        (keyCode: .control, flag: .control),
        (keyCode: .rightcontrol, flag: .control),
        (keyCode: .capslock, flag: .capsLock)
    ]

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.inputDownObserver = NotificationCenter.default.addObserver(forName: InputEvent.inputDownNotification, object: nil, queue: .main) { [weak self] notification in
            if let event = notification.object as? InputEvent {
                self?.inputDown(event: event)
            }
        }

        self.inputUpObserver = NotificationCenter.default.addObserver(forName: InputEvent.inputUpNotification, object: nil, queue: .main) { [weak self] notification in
            if let event = notification.object as? InputEvent {
                self?.inputUp(event: event)
            }
        }

        self.controllerDidConnectObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in
            self?.controllerDidConnect()
        }

        self.controllerDidDisconnectObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
            self?.controllerDidDisconnect()
        }

        self.didEnterFullScreenObserver = NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { [weak self] _ in
            self?.didEnterFullScreen()
        }

        self.didExitFullScreenObserver = NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { [weak self] _ in
            self?.didExitFullScreen()
        }

        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: eventFlagsChanged(event:))
    }

    func eventFlagsChanged (event: NSEvent) -> NSEvent {
        for (keyCode, flag) in self.keyCodesToModifierFlags where event.keyCode == keyCode.rawValue {
            if event.modifierFlags.contains(flag) {
                self.keyDown(with: NSEvent.keyEvent(with: .keyDown, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: event.keyCode)!)
            } else {
                self.keyUp(with: NSEvent.keyEvent(with: .keyUp, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: event.keyCode)!)
            }
            return event
        }
        return event
    }

    override func willMove (from view: SKView) {
        super.willMove(from: view)

        if let observer = self.inputDownObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.inputUpObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.controllerDidConnectObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.controllerDidDisconnectObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.didEnterFullScreenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.didExitFullScreenObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let monitor = self.eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func controllerDidConnect () {
    }

    func controllerDidDisconnect () {
    }

    func didEnterFullScreen () {
    }

    func didExitFullScreen () {
    }

    func inputDown (event: InputEvent) {
    }

    func inputUp (event: InputEvent) {
    }
}
