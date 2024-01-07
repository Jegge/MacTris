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

        NotificationCenter.default.addObserver(forName: Notification.Name.GCControllerDidConnect, object: nil, queue: .main) { [weak self] notification in
            let name = (notification.object as? GCController)?.vendorName ?? "Unknown Controller Vendor"
            Logger.input.info("Controller \(name) did connect.")

            for controller in GCController.controllers() {
                controller.microGamepad?.valueChangedHandler = nil
                controller.extendedGamepad?.valueChangedHandler = {  [weak self] (gamepad: GCExtendedGamepad, element: GCControllerElement) in
                    if let responder = self?.skView.scene as? InputEventResponder {
                        InputMapper.shared.translate(gamepad: gamepad, element: element).forEach {
                            responder.input(event: $0)
                        }
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.GCControllerDidDisconnect, object: nil, queue: .main) { notification in
            let name = (notification.object as? GCController)?.vendorName ?? "Unknown Controller Vendor"
            Logger.input.info("Controller \(name) did disconnect.")
        }

        NotificationCenter.default.addObserver(forName: NSWindow.didEnterFullScreenNotification, object: nil, queue: .main) { _ in
            NSCursor.hide()
        }

        NotificationCenter.default.addObserver(forName: NSWindow.didExitFullScreenNotification, object: nil, queue: .main) { _ in
            NSCursor.unhide()
        }
    }
}
