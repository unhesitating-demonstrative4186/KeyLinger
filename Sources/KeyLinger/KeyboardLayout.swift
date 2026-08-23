import CoreGraphics
import Foundation

struct KeyboardMapKey: Identifiable, Sendable {
    let code: CGKeyCode
    let label: String
    let width: CGFloat

    var id: String { "key-\(code)" }
}

enum KeyboardMapItem: Identifiable, Sendable {
    case key(KeyboardMapKey)
    case spacer(id: String, width: CGFloat)
    case arrowCluster

    var id: String {
        switch self {
        case let .key(key):
            return key.id
        case let .spacer(id, _):
            return "spacer-\(id)"
        case .arrowCluster:
            return "arrow-cluster"
        }
    }

    var width: CGFloat {
        switch self {
        case let .key(key):
            return key.width
        case let .spacer(_, width):
            return width
        case .arrowCluster:
            return 2.25
        }
    }
}

struct KeyboardMapRow: Identifiable, Sendable {
    let id: String
    let items: [KeyboardMapItem]
}

enum CompactANSIKeyboardLayout {
    static let logicalWidth: CGFloat = 15

    static let rows: [KeyboardMapRow] = [
        KeyboardMapRow(id: "function", items: [
            key(53, "esc", 1.25), spacer("function-left", 0.75),
            key(122, "F1"), key(120, "F2"), key(99, "F3"), key(118, "F4"),
            spacer("function-middle-left", 0.5),
            key(96, "F5"), key(97, "F6"), key(98, "F7"), key(100, "F8"),
            spacer("function-middle-right", 0.5),
            key(101, "F9"), key(109, "F10"), key(103, "F11"), key(111, "F12")
        ]),
        KeyboardMapRow(id: "number", items: [
            key(50, "`"), key(18, "1"), key(19, "2"), key(20, "3"),
            key(21, "4"), key(23, "5"), key(22, "6"), key(26, "7"),
            key(28, "8"), key(25, "9"), key(29, "0"), key(27, "−"),
            key(24, "="), key(51, "⌫", 2)
        ]),
        KeyboardMapRow(id: "qwerty", items: [
            key(48, "⇥", 1.5), key(12, "Q"), key(13, "W"), key(14, "E"),
            key(15, "R"), key(17, "T"), key(16, "Y"), key(32, "U"),
            key(34, "I"), key(31, "O"), key(35, "P"), key(33, "["),
            key(30, "]"), key(42, "\\", 1.5)
        ]),
        KeyboardMapRow(id: "home", items: [
            key(57, "⇪", 1.75), key(0, "A"), key(1, "S"), key(2, "D"),
            key(3, "F"), key(5, "G"), key(4, "H"), key(38, "J"),
            key(40, "K"), key(37, "L"), key(41, ";"), key(39, "'"),
            key(36, "↩", 2.25)
        ]),
        KeyboardMapRow(id: "shift", items: [
            key(56, "⇧", 2.25), key(6, "Z"), key(7, "X"), key(8, "C"),
            key(9, "V"), key(11, "B"), key(45, "N"), key(46, "M"),
            key(43, ","), key(47, "."), key(44, "/"), key(60, "⇧", 2.75)
        ]),
        KeyboardMapRow(id: "modifiers", items: [
            key(63, "fn"), key(59, "⌃", 1.25), key(58, "⌥", 1.25),
            key(55, "⌘", 1.5), key(49, "", 5), key(54, "⌘", 1.5),
            key(61, "⌥", 1.25), .arrowCluster
        ])
    ]

    static let arrowKeys: [KeyboardMapKey] = [
        keyDefinition(123, "←"),
        keyDefinition(126, "↑"),
        keyDefinition(125, "↓"),
        keyDefinition(124, "→")
    ]

    static let placedKeyCodes: Set<CGKeyCode> = {
        let rowCodes = rows.flatMap(\.items).compactMap { item -> CGKeyCode? in
            guard case let .key(key) = item else { return nil }
            return key.code
        }
        return Set(rowCodes + arrowKeys.map(\.code))
    }()

    static func validationErrors() -> [String] {
        var errors: [String] = []

        for row in rows {
            let width = row.items.reduce(CGFloat.zero) { $0 + $1.width }
            if abs(width - logicalWidth) > 0.001 {
                errors.append("Row \(row.id) has logical width \(width), expected \(logicalWidth)")
            }
        }

        let rowCodes = rows.flatMap(\.items).compactMap { item -> CGKeyCode? in
            guard case let .key(key) = item else { return nil }
            return key.code
        }
        let codes = rowCodes + arrowKeys.map(\.code)
        if Set(codes).count != codes.count {
            errors.append("Keyboard Map contains duplicate key codes")
        }

        let unknownCodes = codes.filter { KeyCatalog.descriptor(for: $0) == nil }
        if !unknownCodes.isEmpty {
            errors.append("Keyboard Map contains unknown key codes: \(unknownCodes)")
        }

        return errors
    }

    private static func key(
        _ code: CGKeyCode,
        _ label: String,
        _ width: CGFloat = 1
    ) -> KeyboardMapItem {
        .key(keyDefinition(code, label, width))
    }

    private static func keyDefinition(
        _ code: CGKeyCode,
        _ label: String,
        _ width: CGFloat = 1
    ) -> KeyboardMapKey {
        KeyboardMapKey(code: code, label: label, width: width)
    }

    private static func spacer(_ id: String, _ width: CGFloat) -> KeyboardMapItem {
        .spacer(id: id, width: width)
    }
}
