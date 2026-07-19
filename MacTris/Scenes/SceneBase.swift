//
//  SceneBase.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 08.01.24.
//

import SpriteKit

/// Base class for all SpriteKit scenes in the game. Provides common functionality
/// for input handling (keyboard and controller), scene transitions, and observer
/// management for notification center events.
class SceneBase: SKScene {

    private var observers: [NSObjectProtocol] = []
    private var eventMonitor: Any?

    /// The input mapper to translate raw keyboard/gamepad events into game actions.
    var inputMapper: InputMapper?
    /// The sound effect player.
    var audioFxPlayer: AudioFxPlayer?
    /// The background music player.
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
                    self?.input(down: event)
                }
            },
            NotificationCenter.default.addObserver(forName: InputEvent.inputUpNotification, object: nil, queue: .main) { [weak self] notification in
                if let event = notification.object as? InputEvent {
                    self?.input(up: event)
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
               let keyEvent = NSEvent.keyEvent(with: .keyDown,
                                               location: event.locationInWindow,
                                               modifierFlags: event.modifierFlags,
                                               timestamp: event.timestamp,
                                               windowNumber: event.windowNumber,
                                               context: nil,
                                               characters: "",
                                               charactersIgnoringModifiers: "",
                                               isARepeat: false,
                                               keyCode: event.keyCode) {
                self.keyDown(with: keyEvent)
            } else if let keyEvent = NSEvent.keyEvent(with: .keyUp,
                                                      location: event.locationInWindow,
                                                      modifierFlags: event.modifierFlags,
                                                      timestamp: event.timestamp,
                                                      windowNumber: event.windowNumber,
                                                      context: nil,
                                                      characters: "",
                                                      charactersIgnoringModifiers: "",
                                                      isARepeat: false,
                                                      keyCode: event.keyCode) {
                self.keyUp(with: keyEvent)
            }
            return event
        }
        return event
    }

    /// Cleans up notification observers and event monitors when leaving the scene.
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
            self.input(down: $0)
        }
    }

    override func keyUp(with event: NSEvent) {
        self.inputMapper?.translate(event: event).forEach {
            self.input(up: $0)
        }
    }

    /// Called when a game controller connects. Override in subclasses.
    func controllerDidConnect() {
    }

    /// Called when a game controller disconnects. Override in subclasses.
    func controllerDidDisconnect() {
    }

    /// Called when the window enters full-screen mode. Override in subclasses.
    func didEnterFullScreen() {
    }

    /// Called when the window exits full-screen mode. Override in subclasses.
    func didExitFullScreen() {
    }

    /// Called when the window resigns key status. Override in subclasses.
    func didResignKey() {
    }

    /// Called when an input event is pressed. Override in subclasses.
    func input(down event: InputEvent) {
    }

    /// Called when an input event is released. Override in subclasses.
    func input(up event: InputEvent) {
    }

    /// Transitions to a new scene, passing along the input mapper, audio fx player,
    /// and music player. An optional configuration closure can customize the new scene before presentation.
    func transition<T: SceneBase>(to type: T.Type, configureScene: ((T) -> Void)? = nil) {
        let name = String(describing: T.self)
        if let newScene = SKScene(fileNamed: name) as? T {
            newScene.scaleMode = self.scaleMode
            newScene.inputMapper = self.inputMapper
            newScene.audioFxPlayer = self.audioFxPlayer
            newScene.musicPlayer = self.musicPlayer
            configureScene?(newScene)
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        } else {
            fatalError("Failed to transition to \(name).sks")
        }
    }
}
