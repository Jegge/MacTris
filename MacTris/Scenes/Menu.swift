//
//  Menu.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import Foundation
import SpriteKit
import GameplayKit
import GameController

class Menu: SceneBase {

    private struct Item {
        public static let play = "Play"
        public static let settings = "Settings"
        public static let hiscores = "Hiscores"
        public static let update = "Update"
        public static let quit = "Quit"
    }

    private var level: Int = 0 {
        didSet {
            self.update()
        }
    }
    private var menuItems: [String] = []

    private var selection: Int = -1 {
        didSet {
            self.update()
        }
    }

    private var updateURL: URL? {
        didSet {
            self.update()
        }
    }

    private func update() {
        for (index, item) in menuItems.enumerated() {
            guard let bullet = self.childNode(withName: "menu" + item) as? SKLabelNode,
                  let label = self.childNode(withName: "label" + item) as? SKLabelNode
            else {
                continue
            }

            if item == Item.update && self.updateURL == nil {
                bullet.isHidden = index != self.selection
                bullet.fontColor = NSColor(named: "MenuDisabled")
                label.fontColor = NSColor(named: "MenuDisabled")
            } else if index == self.selection {
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

    private func select(item: String) {
        switch item {
        case Item.play:
            AudioPlayer.playFxPositive()
            self.transitionToGame(level: self.level)

        case Item.settings:
            AudioPlayer.playFxPositive()
            self.transitionToSettings()

        case Item.hiscores:
            AudioPlayer.playFxPositive()
            self.transitionToScores()

        case Item.update:
            if let url = self.updateURL {
                AudioPlayer.playFxPositive()
                NSWorkspace.shared.open(url)
            } else {
                AudioPlayer.playFxNegative()
            }

        case Item.quit:
            NSApplication.shared.terminate(nil)

        default:
            AudioPlayer.playFxNegative()
            print("Unknown menu option \(item)")
        }
    }

    private func increase(item: String) {
        switch item {
        case Item.play:
            if self.level < 19 {
                self.level += 1
                UserDefaults.standard.startLevel = self.level
                AudioPlayer.playFxPositive()
            } else {
                AudioPlayer.playFxNegative()
            }

        default:
            AudioPlayer.playFxNegative()
        }
    }

    private func decrease(item: String) {
        switch item {
        case Item.play:
            if self.level > 0 {
                self.level -= 1
                UserDefaults.standard.startLevel = self.level
                AudioPlayer.playFxPositive()
            } else {
                AudioPlayer.playFxNegative()
            }

        default:
            AudioPlayer.playFxNegative()
        }
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0

        (self.childNode(withName: "labelVersion") as? SKLabelNode)?.text = "\(UpdateCheck.version) (\(UpdateCheck.build))"

        let copyright = (Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String) ?? "© 2024-now Sebastian Boettcher"
        (self.childNode(withName: "labelCopyright") as? SKLabelNode)?.text = copyright

        self.level = UserDefaults.standard.startLevel

        Task { [weak self] in
            self?.updateURL = try? await UpdateCheck.getUpdateUrl()
        }
    }

    override func keyDown(with event: NSEvent) {
        InputMapper.shared.translate(event: event).forEach {
            self.inputDown(event: $0)
        }
    }

    override func inputDown(event: InputEvent) {
        switch event.id {
        case .up:
            AudioPlayer.playFxSelect()
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1

        case .down:
            AudioPlayer.playFxSelect()
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0

        case .select:
            self.select(item: self.menuItems[self.selection])

        case .left:
            self.decrease(item: self.menuItems[self.selection])
            self.update()

        case .right:
            self.increase(item: self.menuItems[self.selection])
            self.update()

        default:
            break
        }
    }
}
