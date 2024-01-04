//
//  Menu.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit

class Menu: SKScene {

    private var menuItems: [String] = []
    private var selection: Int = -1 {
        didSet {
            for (index, item) in menuItems.enumerated() {
                guard let bullet = self.childNode(withName: "menu" + item) as? SKLabelNode,
                      let label = self.childNode(withName: "label" + item) as? SKLabelNode
                else {
                    continue
                }

                if index == self.selection {
                    bullet.isHidden = false
                    bullet.fontColor = NSColor(named: "MenuHilite")
                    label.fontColor = NSColor(named: "MenuHilite")
                } else {
                    bullet.isHidden = true
                    bullet.fontColor = NSColor(named: "MenuDefault")
                    label.fontColor = NSColor(named: "MenuDefault")
                }
            }
        }
    }

    private func select (item: String) {
        switch item {
        case "Play":
            if let newScene = SKScene(fileNamed: "Game") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
        case "Settings":
            if let newScene = SKScene(fileNamed: "Settings") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
        case "Hiscores":
            if let newScene = SKScene(fileNamed: "Scores") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
        case "Quit":
            NSApplication.shared.terminate(nil)
        default:
            print("Unknown menu option \(item)")
        }
    }

    override func didMove(to view: SKView) {
        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0

        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0"
        let build = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "0"
        (self.childNode(withName: "labelVersion") as? SKLabelNode)?.text = "v\(version) (\(build))"
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case KeyBindings.up:
            AudioPlayer.playFxSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.selection

        case KeyBindings.down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : self.selection

        case KeyBindings.select:
            AudioPlayer.playFxPositive()
            self.select(item: self.menuItems[self.selection])

        case KeyBindings.enter:
            AudioPlayer.playFxPositive()
            self.select(item: self.menuItems[self.selection])

        case KeyBindings.fullscreen:
            if self.view?.isInFullScreenMode ?? false {
                self.view?.exitFullScreenMode()
            } else {
                self.view?.enterFullScreenMode(NSScreen.main!)
            }

        case KeyBindings.quit:
            NSApplication.shared.terminate(nil)

        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
}
