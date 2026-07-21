//
//  SceneBase.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 08.01.24.
//

import SpriteKit

/// Base class for all SpriteKit scenes in the game. Provides common functionality
/// for input handling, scene transitions, and lifecycle hooks.
class SceneBase: SKScene {

    private var eventMonitor: Any?

    /// The input mapper to translate raw keyboard/gamepad events into game actions.
    var inputMapper: InputMapper?
    /// The sound effect player.
    var audioFxPlayer: AudioFxPlayer?
    /// The background music player.
    var musicPlayer: MusicPlayer?
    /// Shared access to persisted game settings.
    var gameSettings: GameSettings?

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged, handler: eventFlagsChanged(event:))
    }

    func eventFlagsChanged(event: NSEvent) -> NSEvent {
        self.inputMapper?.translate(event: event).forEach { inputEvent in
            if inputEvent.isDown {
                self.input(down: inputEvent)
            } else {
                self.input(up: inputEvent)
            }
        }
        return event
    }

    /// Cleans up the event monitor when leaving the scene.
    override func willMove(from view: SKView) {
        super.willMove(from: view)

        if let monitor = self.eventMonitor {
            NSEvent.removeMonitor(monitor)
            self.eventMonitor = nil
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
            newScene.gameSettings = self.gameSettings
            configureScene?(newScene)
            self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
        } else {
            fatalError("Failed to transition to \(name).sks")
        }
    }
}
