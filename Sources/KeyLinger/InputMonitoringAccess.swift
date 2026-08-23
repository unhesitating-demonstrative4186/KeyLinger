import AppKit
import CoreGraphics
import Foundation

@MainActor
final class InputMonitoringAccess: ObservableObject {
    @Published private(set) var isGranted = CGPreflightListenEventAccess()

    func refresh() {
        isGranted = CGPreflightListenEventAccess()
    }

    func requestFromUser() {
        isGranted = CGRequestListenEventAccess()
        if !isGranted {
            openSystemSettings()
        }
    }

    func requestOnceAfterFirstLaunch() {
        guard !isGranted else { return }

        let key = "didRequestInputMonitoring"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        isGranted = CGRequestListenEventAccess()
    }

    private func openSystemSettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
        ) else { return }
        NSWorkspace.shared.open(url)
    }
}
