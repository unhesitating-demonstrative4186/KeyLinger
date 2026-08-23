import AppKit
import CoreGraphics
import Foundation

protocol KeyStateReading {
    func isPressed(_ keyCode: CGKeyCode) -> Bool
}

struct CombinedSessionKeyStateReader: KeyStateReading {
    func isPressed(_ keyCode: CGKeyCode) -> Bool {
        CGEventSource.keyState(.combinedSessionState, key: keyCode)
    }
}

@MainActor
final class KeyboardMonitor: NSObject, ObservableObject {
    @Published private(set) var pressedKeys: [KeyDescriptor] = []

    private let reader: KeyStateReading
    private var timer: Timer?
    private var pollCount = 0
    private var frequencyHz = PollingFrequency.balanced.rawValue
    var permissionRefresh: (() -> Void)?

    init(reader: KeyStateReading = CombinedSessionKeyStateReader()) {
        self.reader = reader
        super.init()
    }

    func start(frequencyHz: Int = PollingFrequency.balanced.rawValue) {
        guard timer == nil else { return }
        self.frequencyHz = frequencyHz
        poll()
        scheduleTimer()
    }

    func updateFrequency(_ frequencyHz: Int) {
        guard frequencyHz > 0, frequencyHz != self.frequencyHz else { return }
        self.frequencyHz = frequencyHz
        pollCount = 0
        guard timer != nil else { return }
        timer?.invalidate()
        scheduleTimer()
    }

    private func scheduleTimer() {
        let interval = 1.0 / Double(frequencyHz)
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(poll),
            userInfo: nil,
            repeats: true
        )
        timer?.tolerance = interval * 0.15
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func poll() {
        let current = KeyCatalog.all.filter { reader.isPressed($0.code) }
        if current != pressedKeys {
            pressedKeys = current
        }

        pollCount += 1
        if pollCount >= frequencyHz {
            pollCount = 0
            permissionRefresh?()
        }
    }
}
