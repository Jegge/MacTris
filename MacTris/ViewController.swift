//
//  ViewController.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameController
import OSLog

/// The main view controller. Sets up the SpriteKit view, initializes input
/// mapping, audio, music, and observes controller connect/disconnect and
/// full-screen events.
class ViewController: NSViewController {
    @IBOutlet var skView: SKView!

    private var observers: [NSObjectProtocol] = []

    /// Shared persisted game settings.
    let gameSettings = GameSettings(userDefaults: .standard)
    /// Shared input mapper bound to the user's keyboard preferences.
    lazy var inputMapper = InputMapper(keyboardBindings: self.gameSettings.keyboardBindings)
    /// Shared sound effect player.
    lazy var audioFxPlayer = AudioFxPlayer(volume: self.gameSettings.fxVolume)
    /// Shared background music player.
    lazy var musicPlayer = MusicPlayer(volume: self.gameSettings.musicVolume)

    private func notifyCurrentScene(_ action: (SceneBase) -> Void) {
        guard let scene = self.skView?.scene as? SceneBase else {
            return
        }
        action(scene)
    }

    private func configureObservers() {
        self.observers = [
            NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] notification in
                guard let controller = notification.object as? GCController else {
                    Logger.input.info("Controller connection failed.")
                    return
                }

                Logger.input.info("Controller \(controller.vendorName ?? "Unknown Controller Vendor", privacy: .public) did connect.")

                if let gamepad = controller.extendedGamepad {
                    gamepad.valueChangedHandler = { [weak self] (gamepad: GCExtendedGamepad, element: GCControllerElement) in
                        self?.inputMapper.translate(gamepad: gamepad, element: element).forEach { input in
                            self?.notifyCurrentScene { input.isDown ? $0.input(down: input) : $0.input(up: input) }
                        }
                    }
                } else if let gamepad = controller.microGamepad {
                    gamepad.allowsRotation = true
                    gamepad.valueChangedHandler = { [weak self] (gamepad: GCMicroGamepad, element: GCControllerElement) in
                        self?.inputMapper.translate(gamepad: gamepad, element: element).forEach { input in
                            self?.notifyCurrentScene { input.isDown ? $0.input(down: input) : $0.input(up: input) }
                        }
                    }
                } else {
                    Logger.input.warning("Controller is not supported: neither an extended nor a micro gamepad.")
                }
                self?.notifyCurrentScene { $0.controllerDidConnect() }
            },
            NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { notification in
                Logger.input.info("Controller \((notification.object as? GCController)?.vendorName ?? "Unknown Controller Vendor", privacy: .public) did disconnect.")
                self.notifyCurrentScene { $0.controllerDidDisconnect() }
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { _ in
                self.gameSettings.fullscreen = true
                NSCursor.hide()
                self.notifyCurrentScene { $0.didEnterFullScreen() }
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { _ in
                self.gameSettings.fullscreen = false
                NSCursor.unhide()
                self.notifyCurrentScene { $0.didExitFullScreen() }
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: .main) { _ in
                self.notifyCurrentScene { $0.didResignKey() }
            }
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.musicPlayer.play(mp3: "Korobeiniki")

        if let view = self.skView {
            if let scene = SKScene(fileNamed: "Menu") as? SceneBase {
                scene.inputMapper = self.inputMapper
                scene.audioFxPlayer = self.audioFxPlayer
                scene.musicPlayer = self.musicPlayer
                scene.gameSettings = self.gameSettings
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 60
            #if DEBUG
            view.showsFPS = true
            #endif
        }

        self.configureObservers()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let view = self.skView {
            if self.gameSettings.fullscreen != view.isInFullScreenMode {
                view.window?.toggleFullScreen(nil)
            }
        }
    }

    deinit {
        self.musicPlayer.stop()

        self.observers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        self.observers.removeAll()
    }
}
