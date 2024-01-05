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

    private struct Item {
        public static let play = "Play"
        public static let settings = "Settings"
        public static let hiscores = "Hiscores"
        public static let quit = "Quit"
    }

    private var level = 0
    private var menuItems: [String] = []
    private var selection: Int = -1 {
        didSet {
            self.update()
        }
    }

    private func update () {
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

            if item == Item.play {
                label.text = "Play level \(self.level)"
            }
        }
    }

    private func select (item: String) {
        switch item {
        case Item.play:
            AudioPlayer.playFxPositive()
            if let newScene = SKScene(fileNamed: "Game") as? Game {
                newScene.scaleMode = .aspectFit
                newScene.level = self.level
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }

        case Item.settings:
            AudioPlayer.playFxPositive()
            if let newScene = SKScene(fileNamed: "Settings") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }

        case Item.hiscores:
            AudioPlayer.playFxPositive()
            if let newScene = SKScene(fileNamed: "Scores") {
                newScene.scaleMode = .aspectFit
                self.scene?.view?.presentScene(newScene, transition: SKTransition.flipVertical(withDuration: 0.1))
            }

        case Item.quit:
            NSApplication.shared.terminate(nil)

        default:
            AudioPlayer.playFxNegative()
            print("Unknown menu option \(item)")
        }
    }

    private func increase (item: String) {
        switch item {
        case Item.play:
            if self.level < 19 {
                self.level += 1
                AudioPlayer.playFxPositive()
            } else {
                AudioPlayer.playFxNegative()
            }

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func decrease (item: String) {
        switch item {
        case Item.play:
            if self.level > 0 {
                self.level -= 1
                AudioPlayer.playFxPositive()
            } else {
                AudioPlayer.playFxNegative()
            }

        default:
            AudioPlayer.playFxNegative()
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
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1

        case KeyBindings.down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0

        case KeyBindings.select:
            self.select(item: self.menuItems[self.selection])

        case KeyBindings.enter:
            self.select(item: self.menuItems[self.selection])

        case KeyBindings.left:
            self.decrease(item: self.menuItems[self.selection])
            self.update()

        case KeyBindings.right:
            self.increase(item: self.menuItems[self.selection])
            self.update()

        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
}
