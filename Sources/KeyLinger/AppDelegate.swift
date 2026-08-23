import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private let monitor = KeyboardMonitor()
    private let settings = AppSettings()
    private let inputAccess = InputMonitoringAccess()

    private var panel: NSPanel!
    private var settingsWindow: NSPanel?
    private var statusItem: NSStatusItem!
    private var showMenuItem: NSMenuItem!
    private var compactMenuItem: NSMenuItem!
    private var settingsMenuItem: NSMenuItem!
    private var permissionMenuItem: NSMenuItem!
    private var quitMenuItem: NSMenuItem!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        makePanel()
        makeStatusItem()

        monitor.permissionRefresh = { [weak self] in
            self?.inputAccess.refresh()
        }
        monitor.start(frequencyHz: settings.pollingFrequency.rawValue)

        observeState()
        updateLocalizedUI()
        updatePanelMode(animated: false)

        // Polling before the first frame makes a key stuck before launch visible immediately.
        panel.orderFrontRegardless()

        if CommandLine.arguments.contains("--settings") {
            DispatchQueue.main.async { [weak self] in
                self?.showSettings()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.inputAccess.requestOnceAfterFirstLaunch()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor.stop()
    }

    private func makePanel() {
        let view = PressedKeysView(
            monitor: monitor,
            settings: settings,
            inputAccess: inputAccess,
            openSettings: { [weak self] in self?.showSettings() }
        )
        let hostingView = NSHostingView(rootView: view)

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 430, height: 280),
            styleMask: [.titled, .closable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hostingView
        panel.level = .floating
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.setFrameAutosaveName("KeyLingerPanel")
        panel.center()
        panel.delegate = self
    }

    private func makeStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.autosaveName = "io.github.myweihp.KeyLinger.status-item"
        statusItem.button?.image = statusBarImage(
            systemName: "keyboard",
            accessibilityDescription: "KeyLinger"
        )
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.imageScaling = .scaleProportionallyDown
        statusItem.button?.setAccessibilityLabel("KeyLinger")
        statusItem.button?.setAccessibilityIdentifier("io.github.myweihp.KeyLinger.status-item")

        let menu = NSMenu()
        showMenuItem = menu.addItem(withTitle: "", action: #selector(showPanel), keyEquivalent: "s")
        showMenuItem.target = self

        compactMenuItem = menu.addItem(withTitle: "", action: #selector(toggleCompactMode), keyEquivalent: "m")
        compactMenuItem.target = self

        settingsMenuItem = menu.addItem(withTitle: "", action: #selector(showSettings), keyEquivalent: ",")
        settingsMenuItem.target = self

        permissionMenuItem = menu.addItem(withTitle: "", action: #selector(requestInputMonitoring), keyEquivalent: "")
        permissionMenuItem.target = self

        menu.addItem(.separator())
        quitMenuItem = menu.addItem(withTitle: "", action: #selector(quit), keyEquivalent: "q")
        quitMenuItem.target = self
        statusItem.menu = menu
    }

    private func observeState() {
        monitor.$pressedKeys
            .sink { [weak self] pressedKeys in
                self?.updateStatusItem(pressedKeyCount: pressedKeys.count)
            }
            .store(in: &cancellables)

        settings.$language
            .sink { [weak self] language in
                self?.updateLocalizedUI(language: language)
            }
            .store(in: &cancellables)

        settings.$compactMode
            .dropFirst()
            .sink { [weak self] _ in self?.updatePanelMode(animated: true) }
            .store(in: &cancellables)

        settings.$standardViewMode
            .dropFirst()
            .sink { [weak self] _ in self?.updatePanelMode(animated: true) }
            .store(in: &cancellables)

        settings.$pollingFrequency
            .dropFirst()
            .sink { [weak self] frequency in
                self?.monitor.updateFrequency(frequency.rawValue)
            }
            .store(in: &cancellables)

        inputAccess.$isGranted
            .sink { [weak self] _ in self?.updatePermissionMenuItem() }
            .store(in: &cancellables)
    }

    private func updateLocalizedUI(language: AppLanguage? = nil) {
        let language = language ?? settings.language
        panel?.title = text("app.name", language: language)
        showMenuItem?.title = text("menu.showPanel", language: language)
        compactMenuItem?.title = text("menu.compactMode", language: language)
        settingsMenuItem?.title = text("menu.settings", language: language)
        quitMenuItem?.title = text("menu.quit", language: language)
        settingsWindow?.title = text("settings.title", language: language)

        updatePermissionMenuItem(language: language)
        updateStatusItem(language: language)
    }

    private func updateStatusItem(
        language: AppLanguage? = nil,
        pressedKeyCount: Int? = nil
    ) {
        guard statusItem != nil else { return }
        let language = language ?? settings.language
        let count = pressedKeyCount ?? monitor.pressedKeys.count
        let statusImage = statusBarImage(
            systemName: count == 0 ? "keyboard" : "keyboard.fill",
            accessibilityDescription: text("app.name", language: language)
        )

        if let statusImage {
            statusItem.length = count == 0
                ? NSStatusItem.squareLength
                : NSStatusItem.variableLength
            statusItem.button?.title = count == 0 ? "" : " " + String(count)
            statusItem.button?.image = statusImage
            statusItem.button?.imagePosition = count == 0 ? .imageOnly : .imageLeading
        } else {
            statusItem.length = NSStatusItem.variableLength
            statusItem.button?.image = nil
            statusItem.button?.title = count == 0 ? "⌨" : "⌨ " + String(count)
        }

        statusItem.button?.contentTintColor = nil
        statusItem.button?.toolTip = count == 0
            ? text("status.tooltip.normal", language: language)
            : L10n.format("status.tooltip.pressed", language: language, count)
    }

    private func statusBarImage(
        systemName: String,
        accessibilityDescription: String
    ) -> NSImage? {
        guard let image = NSImage(
            systemSymbolName: systemName,
            accessibilityDescription: accessibilityDescription
        ) else { return nil }

        let configuration = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let configuredImage = image.withSymbolConfiguration(configuration) ?? image
        configuredImage.isTemplate = true
        configuredImage.size = NSSize(width: 18, height: 18)
        return configuredImage
    }

    private func updatePermissionMenuItem(language: AppLanguage? = nil) {
        guard permissionMenuItem != nil else { return }
        let language = language ?? settings.language
        permissionMenuItem.title = inputAccess.isGranted
            ? text("permission.granted", language: language)
            : text("permission.enableMenu", language: language)
        permissionMenuItem.state = inputAccess.isGranted ? .on : .off
        permissionMenuItem.isEnabled = !inputAccess.isGranted
        permissionMenuItem.isHidden = inputAccess.isGranted
    }

    private func updatePanelMode(animated: Bool) {
        guard panel != nil else { return }

        let topLeft = NSPoint(x: panel.frame.minX, y: panel.frame.maxY)
        let targetSize: NSSize
        let minimumSize: NSSize
        if settings.compactMode {
            targetSize = NSSize(width: 330, height: 58)
            minimumSize = NSSize(width: 280, height: 58)
        } else if settings.standardViewMode == .keyboard {
            targetSize = NSSize(width: 760, height: inputAccess.isGranted ? 390 : 455)
            minimumSize = NSSize(width: 640, height: inputAccess.isGranted ? 350 : 415)
        } else {
            targetSize = NSSize(width: 430, height: inputAccess.isGranted ? 250 : 300)
            minimumSize = NSSize(width: 390, height: 230)
        }

        panel.contentMinSize = minimumSize
        panel.contentMaxSize = settings.compactMode
            ? NSSize(width: 620, height: 58)
            : NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        compactMenuItem?.state = settings.compactMode ? .on : .off

        let changes = {
            self.panel.setContentSize(targetSize)
            self.panel.setFrameTopLeftPoint(topLeft)
            if let screen = self.panel.screen {
                let constrainedFrame = self.panel.constrainFrameRect(self.panel.frame, to: screen)
                self.panel.setFrame(constrainedFrame, display: true)
            }
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.18
                context.allowsImplicitAnimation = true
                changes()
            }
        } else {
            changes()
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    @objc private func showPanel() {
        panel.orderFrontRegardless()
    }

    @objc private func toggleCompactMode() {
        settings.compactMode.toggle()
        panel.orderFrontRegardless()
    }

    @objc private func requestInputMonitoring() {
        inputAccess.requestFromUser()
    }

    @objc private func showSettings() {
        if settingsWindow == nil {
            let view = SettingsView(settings: settings)
            let window = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 460, height: 600),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = text("settings.title")
            window.contentView = NSHostingView(rootView: view)
            window.isReleasedWhenClosed = false
            window.hidesOnDeactivate = false
            window.level = .floating
            window.center()
            settingsWindow = window
        }

        NSApplication.shared.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    private func text(_ key: String, language: AppLanguage? = nil) -> String {
        L10n.text(key, language: language ?? settings.language)
    }
}
