//
//  ViewController.swift
//  Mactris
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

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            if let scene = SKScene(fileNamed: "Menu") {
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if let view = self.skView {
            if UserDefaults.standard.fullscreen != view.isInFullScreenMode {
                view.window?.toggleFullScreen(nil)
            }
        }

        self.controllerDidConnectObserver = NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { notification in
            let name = (notification.object as? GCController)?.vendorName ?? "Unknown Controller Vendor"
            Logger.input.info("Controller \(name, privacy: .public) did connect.")

            for controller in GCController.controllers() {
                controller.microGamepad?.valueChangedHandler = nil
                controller.extendedGamepad?.valueChangedHandler = { (gamepad: GCExtendedGamepad, element: GCControllerElement) in
                    InputMapper.shared.translate(gamepad: gamepad, element: element).forEach {
                        $0.postNotification()
                    }
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
