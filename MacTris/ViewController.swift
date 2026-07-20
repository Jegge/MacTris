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

    /// Shared input mapper bound to the user's keyboard preferences.
    let inputMapper = InputMapper(keyboardBindings: UserDefaults.standard.keyboardBindings)
    /// Shared sound effect player.
    let audioFxPlayer = AudioFxPlayer(volume: UserDefaults.standard.fxVolume)
    /// Shared background music player.
    let musicPlayer = MusicPlayer(volume: UserDefaults.standard.musicVolume)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.musicPlayer.play(mp3: "Korobeiniki")

        if let view = self.skView {
            if let scene = SKScene(fileNamed: "Menu") as? SceneBase {
                scene.inputMapper = self.inputMapper
                scene.audioFxPlayer = self.audioFxPlayer
                scene.musicPlayer = self.musicPlayer
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 60
            #if DEBUG
            view.showsFPS = true
            #endif
        }

        self.observers = [
            NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] notification in
                guard let controller = notification.object as? GCController else {
                    Logger.input.info("Controller connection failed.")
                    return
                }

                Logger.input.info("Controller \(controller.vendorName ?? "Unknown Controller Vendor", privacy: .public) did connect.")

                if let gamepad = controller.extendedGamepad {
                    gamepad.valueChangedHandler = { [weak self] (gamepad: GCExtendedGamepad, element: GCControllerElement) in
                        self?.inputMapper.translate(gamepad: gamepad, element: element).forEach {
                            $0.postNotification()
                        }
                    }
                } else if let gamepad = controller.microGamepad {
                    gamepad.allowsRotation = true
                    gamepad.valueChangedHandler = { [weak self] (gamepad: GCMicroGamepad, element: GCControllerElement) in
                        self?.inputMapper.translate(gamepad: gamepad, element: element).forEach {
                            $0.postNotification()
                        }
                    }
                } else {
                    Logger.input.warning("Controller is not supported: neither an extended nor a micro gamepad.")
                }
            },
            NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { notification in
                Logger.input.info("Controller \((notification.object as? GCController)?.vendorName ?? "Unknown Controller Vendor", privacy: .public) did disconnect.")
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { _ in
                NSCursor.hide()
            },
            NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { _ in
                NSCursor.unhide()
            }
        ]
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let view = self.skView {
            if UserDefaults.standard.fullscreen != view.isInFullScreenMode {
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
