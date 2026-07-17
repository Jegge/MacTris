//
//  ViewController.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import SpriteKit
import GameController
import OSLog

class ViewController: NSViewController {
    @IBOutlet var skView: SKView!

    private var controllerDidConnectObserver: Any?
    private var controllerDidDisconnectObserver: Any?
    private var didEnterFullScreenObserver: Any?
    private var didExitFullScreenObserver: Any?

    let inputMapper = InputMapper(keyboardBindings: UserDefaults.standard.keyboardBindings)
    let audioFxPlayer = AudioFxPlayer(volume: UserDefaults.standard.fxVolume)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            if let scene = SKScene(fileNamed: "Menu") as? SceneBase {
                scene.inputMapper = self.inputMapper
                scene.audioFxPlayer = self.audioFxPlayer
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true
            view.preferredFramesPerSecond = 60
            #if DEBUG
            view.showsFPS = true
            #endif
        }

        self.controllerDidConnectObserver = NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] notification in
            guard let controller = notification.object as? GCController else {
                Logger.input.info("Controller connection failed.")
                return
            }

            Logger.input.info("Controller \(controller.vendorName ?? "Unknown Controller Vendor", privacy: .public) did connect.")
            controller.microGamepad?.valueChangedHandler = nil
            controller.extendedGamepad?.valueChangedHandler = { [weak self] (gamepad: GCExtendedGamepad, element: GCControllerElement) in
                self?.inputMapper.translate(gamepad: gamepad, element: element).forEach {
                    $0.postNotification()
                }
            }
        }

        self.controllerDidDisconnectObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            let name = (notification.object as? GCController)?.vendorName ?? "Unknown Controller Vendor"
            Logger.input.info("Controller \(name, privacy: .public) did disconnect.")
        }

        self.didEnterFullScreenObserver = NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { _ in
            NSCursor.hide()
        }

        self.didExitFullScreenObserver = NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { _ in
            NSCursor.unhide()
        }
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
    }
}
