//
//  Menu.swift
//  MacTris
//
//  Created by Sebastian Boettcher on 03.01.24.
//

import SpriteKit
import OSLog

class Menu: SceneBase {

    private struct Item {
        static let play = "Play"
        static let settings = "Settings"
        static let hiscores = "Hiscores"
        static let update = "Update"
        static let quit = "Quit"
    }

    private var menuItems: [String] = []

    private var selection: Int = -1 {
        didSet {
            self.update()
        }
    }

    @MainActor private var updateUrl: URL? {
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

            if item == Item.update && self.updateUrl == nil {
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
                label.text = String(format: NSLocalizedString("MenuPlayLevelNr", comment: "Has a numeric argument for the level nr."), UserDefaults.standard.startLevel)
            }
        }
    }

    private func select(item: String) {
        switch item {
        case Item.play:
            self.audioFxPlayer.play(.positive)
            self.transitionToGame()

        case Item.settings:
            self.audioFxPlayer.play(.positive)
            self.transitionToSettings()

        case Item.hiscores:
            self.audioFxPlayer.play(.positive)
            self.transitionToScores()

        case Item.update:
            if let url = self.updateUrl {
                self.audioFxPlayer.play(.positive)
                NSWorkspace.shared.open(url)
            } else {
                self.audioFxPlayer.play(.negative)
            }

        case Item.quit:
            NSApplication.shared.terminate(nil)

        default:
            self.audioFxPlayer.play(.negative)
        }
    }

    private func adjust(item: String, direction: AdjustDirection) {
        switch item {
        case Item.play:
            if direction == .increase && UserDefaults.standard.startLevel < Tetris.maxLevel {
                UserDefaults.standard.startLevel += 1
                self.update()
                self.audioFxPlayer.play(.positive)
            } else if direction == .decrease && UserDefaults.standard.startLevel > 0 {
                UserDefaults.standard.startLevel -= 1
                self.update()
                self.audioFxPlayer.play(.positive)
            } else {
                self.audioFxPlayer.play(.negative)
            }

        default:
            self.audioFxPlayer.play(.negative)
        }
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.menuItems = self.children.map { $0.name ?? "" }.filter { $0.hasPrefix("menu") }.map { String($0.dropFirst(4)) }
        self.selection = 0

        (self.childNode(withName: "labelVersion") as? SKLabelNode)?.text = "\(Bundle.main.version) (\(Bundle.main.build))"
        (self.childNode(withName: "labelCopyright") as? SKLabelNode)?.text = Bundle.main.copyright

        Task { [weak self] in
            self?.updateUrl = await self?.checkForUpdate()
        }
    }

    override func inputDown(event: InputEvent) {
        switch event.id {
        case .up:
            self.audioFxPlayer.play(.select)
            self.selection = self.selection > 0 ? self.selection - 1 : self.menuItems.count - 1

        case .down:
            self.audioFxPlayer.play(.select)
            self.selection = self.selection < menuItems.count - 1 ? self.selection + 1 : 0

        case .select:
            self.select(item: self.menuItems[self.selection])

        case .left:
            self.adjust(item: self.menuItems[self.selection], direction: .decrease)

        case .right:
            self.adjust(item: self.menuItems[self.selection], direction: .increase)

        default:
            break
        }
    }

    private func checkForUpdate() async -> URL? {
        do {
            let reader = GitHubApiReleaseReader(baseUrl: UserDefaults.standard.updateCheckBaseUrl)
            if let release = try await reader.readLatestRelease(), release.version > Bundle.main.version {
                Logger.update.info("Update \(release.version, privacy: .public) available at \(release.downloadUrl.absoluteString, privacy: .public)")
                return release.downloadUrl
            } else {
                Logger.update.info("Current version \(Bundle.main.version, privacy: .public) is up to date.")
            }
        } catch {
            Logger.update.warning("Update check failed: \(error, privacy: .public).")
        }
        return nil
    }
}
