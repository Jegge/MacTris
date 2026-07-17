//
//  SceneBase.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 08.01.24.
//

import SpriteKit

class SceneBase: SKScene {

    private var observers: [NSObjectProtocol] = []
    private var eventMonitor: Any?

    var inputMapper: InputMapper?
    var audioFxPlayer: AudioFxPlayer?
    var musicPlayer: MusicPlayer?

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

        self.observers = [
            NotificationCenter.default.addObserver(forName: InputEvent.inputDownNotification, object: nil, queue: .main) { [weak self] notification in
                if let event = notification.object as? InputEvent {
                    self?.inputDown(event: event)
                }
            },
            NotificationCenter.default.addObserver(forName: InputEvent.inputUpNotification, object: nil, queue: .main) { [weak self] notification in
                if let event = notification.object as? InputEvent {
                    self?.inputUp(event: event)
                }
            },
            NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] _ in
                self?.controllerDidConnect()
            },
            NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] _ in
                self?.controllerDidDisconnect()
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { [weak self] _ in
                self?.didEnterFullScreen()
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { [weak self] _ in
                self?.didExitFullScreen()
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: .main) { [weak self] _ in
                self?.didResignKey()
            }
        ]

        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: eventFlagsChanged(event:))
    }

    func eventFlagsChanged(event: NSEvent) -> NSEvent {
        for (keyCode, flag) in self.keyCodesToModifierFlags where event.keyCode == keyCode.rawValue {
            if event.modifierFlags.contains(flag),
               let keyEvent = NSEvent.keyEvent(with: .keyDown, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: event.keyCode) {
                self.keyDown(with: keyEvent)
            } else if let keyEvent = NSEvent.keyEvent(with: .keyUp, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: event.keyCode) {
                self.keyUp(with: keyEvent)
            }
            return event
        }
        return event
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)

        self.observers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        self.observers.removeAll()

        if let monitor = self.eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    override func keyDown(with event: NSEvent) {
        self.inputMapper?.translate(event: event).forEach {
            self.inputDown(event: $0)
        }
    }

    override func keyUp(with event: NSEvent) {
        self.inputMapper?.translate(event: event).forEach {
            self.inputUp(event: $0)
        }
    }

    func controllerDidConnect() {
    }

    func controllerDidDisconnect() {
    }

    func didEnterFullScreen() {
    }

    func didExitFullScreen() {
    }

    func didResignKey() {
    }

    func inputDown(event: InputEvent) {
    }

    func inputUp(event: InputEvent) {
    }

    func transition<T: SceneBase>(to type: T.Type, configureScene: ((T) -> Void)? = nil) {
        let name = String(describing: T.self)
        if let newScene = SKScene(fileNamed: name) as? T {
            newScene.scaleMode = self.scaleMode
            newScene.inputMapper = self.inputMapper
            newScene.audioFxPlayer = self.audioFxPlayer
            configureScene?(newScene)
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        } else {
            fatalError("Failed to transition to \(name).sks")
        }
    }
}
