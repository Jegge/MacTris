//
//  Settings.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit

class Settings: SKScene {

    private var menuItems: [String] = []
    private var selection: Int = 0

    private func update () {
        for (index, item) in menuItems.enumerated() {
            guard let bullet = self.childNode(withName: "menu" + item) as? SKLabelNode,
                  let label = self.childNode(withName: "label" + item) as? SKLabelNode,
                  let value = self.childNode(withName: "value" + item) as? SKLabelNode
            else {
                continue
            }

            if index == self.selection {
                bullet.isHidden = false
                bullet.fontColor = NSColor(named: "MenuHilite")
                label.fontColor = NSColor(named: "MenuHilite")
                value.fontColor = NSColor(named: "MenuHilite")
            } else {
                bullet.isHidden = true
                bullet.fontColor = NSColor(named: "MenuDefault")
                label.fontColor = NSColor(named: "MenuDefault")
                value.fontColor = NSColor(named: "MenuDefault")
            }

            if let text = self.value(for: item) {
                value.text = text
            }
        }
    }

    private func value (for item: String) -> String? {
        switch item {
        case "DisplayMode":
            return (self.view?.isInFullScreenMode ?? false) ? "fullscreen" : "windowed"
        default:
            return nil
        }
    }

    private func select (item: String) {
        switch item {
        case "DisplayMode":
            if self.view?.isInFullScreenMode ?? false {
                self.view?.exitFullScreenMode()
                UserDefaults.standard.isFullscreen = false
            } else {
                self.view?.enterFullScreenMode(NSScreen.main!)
                UserDefaults.standard.isFullscreen = true
            }
            self.update()

//            if let newScene = SKScene(fileNamed: "Game") {
//                newScene.scaleMode = .aspectFit
//                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
//            }
//        case "Settings":
//            break
//        case "Hiscores":
//            if let newScene = SKScene(fileNamed: "Scores") {
//                newScene.scaleMode = .aspectFit
//                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
//            }
//        case "Quit":
//            NSApplication.shared.terminate(nil)
        default:
            print("Unknown menu option \(item)")
        }
    }

    override func didMove(to view: SKView) {
        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.update()
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case KeyBindings.up:
            self.selection = self.selection > 0 ? self.selection - 1 : self.selection
            self.update()
        case KeyBindings.down:
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : self.selection
            self.update()
        case KeyBindings.select:
            self.select(item: self.menuItems[self.selection])
        case KeyBindings.enter:
            self.select(item: self.menuItems[self.selection])
        case KeyBindings.quit:
            if let newScene = SKScene(fileNamed: "Menu") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
}
