//
//  ViewController.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 02.01.24.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {
    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {

            if UserDefaults.standard.fullscreen {
               // view.enterFullScreenMode(NSScreen.main!)
            }

            if let scene = SKScene(fileNamed: "Menu") {
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
        }
    }
}
