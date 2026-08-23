import CoreGraphics
import SwiftUI

struct KeyboardMapView: View {
    let pressedKeys: [KeyDescriptor]
    let language: AppLanguage

    private let keySpacing: CGFloat = 5
    private let rowSpacing: CGFloat = 5

    private var pressedKeyCodes: Set<CGKeyCode> {
        Set(pressedKeys.map(\.code))
    }

    private var unplacedPressedKeys: [KeyDescriptor] {
        pressedKeys.filter { !CompactANSIKeyboardLayout.placedKeyCodes.contains($0.code) }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                mapCanvas
                    .frame(height: unplacedPressedKeys.isEmpty ? 250 : 205)

                if !unplacedPressedKeys.isEmpty {
                    unplacedKeys
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
        }
    }

    private var mapCanvas: some View {
        GeometryReader { proxy in
            let availableWidth = min(max(proxy.size.width - 20, 0), 720)
            let unitWidth = max(
                24,
                (availableWidth - keySpacing * (CompactANSIKeyboardLayout.logicalWidth - 1))
                    / CompactANSIKeyboardLayout.logicalWidth
            )
            let contentWidth = unitWidth * CompactANSIKeyboardLayout.logicalWidth
                + keySpacing * (CompactANSIKeyboardLayout.logicalWidth - 1)
            let normalKeyHeight = min(38, max(28, unitWidth * 0.82))
            let heightLimitedKeyHeight = max(
                22,
                (proxy.size.height - 20 - rowSpacing * 5) / 5.72
            )
            let fittedKeyHeight = min(normalKeyHeight, heightLimitedKeyHeight)
            let functionKeyHeight = fittedKeyHeight * 0.72

            VStack(spacing: rowSpacing) {
                ForEach(Array(CompactANSIKeyboardLayout.rows.enumerated()), id: \.element.id) { index, row in
                    KeyboardMapRowView(
                        row: row,
                        pressedKeyCodes: pressedKeyCodes,
                        language: language,
                        unitWidth: unitWidth,
                        keyHeight: index == 0 ? functionKeyHeight : fittedKeyHeight,
                        keySpacing: keySpacing
                    )
                }
            }
            .frame(width: contentWidth)
            .padding(10)
            .background(Color.primary.opacity(0.025), in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var unplacedKeys: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text("keyboard.otherPressed"))
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)

            FlowLayout(spacing: 6) {
                ForEach(unplacedPressedKeys) { key in
                    Text(key.displayName(language: language))
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.red.opacity(0.16), in: RoundedRectangle(cornerRadius: 7))
                        .overlay {
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func text(_ key: String) -> String {
        L10n.text(key, language: language)
    }
}

private struct KeyboardMapRowView: View {
    let row: KeyboardMapRow
    let pressedKeyCodes: Set<CGKeyCode>
    let language: AppLanguage
    let unitWidth: CGFloat
    let keyHeight: CGFloat
    let keySpacing: CGFloat

    var body: some View {
        HStack(spacing: keySpacing) {
            ForEach(row.items) { item in
                switch item {
                case let .key(key):
                    KeyboardKeycapView(
                        key: key,
                        isPressed: pressedKeyCodes.contains(key.code),
                        language: language
                    )
                    .frame(width: itemWidth(item), height: keyHeight)

                case .spacer:
                    Color.clear
                        .frame(width: itemWidth(item), height: keyHeight)

                case .arrowCluster:
                    KeyboardArrowClusterView(
                        pressedKeyCodes: pressedKeyCodes,
                        language: language,
                        spacing: 2
                    )
                    .frame(width: itemWidth(item), height: keyHeight)
                }
            }
        }
    }

    private func itemWidth(_ item: KeyboardMapItem) -> CGFloat {
        unitWidth * item.width + keySpacing * (item.width - 1)
    }
}

private struct KeyboardArrowClusterView: View {
    let pressedKeyCodes: Set<CGKeyCode>
    let language: AppLanguage
    let spacing: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let keyWidth = (proxy.size.width - spacing * 2) / 3
            let keyHeight = (proxy.size.height - spacing) / 2
            let keys = CompactANSIKeyboardLayout.arrowKeys

            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    Color.clear.frame(width: keyWidth, height: keyHeight)
                    keycap(keys[1], width: keyWidth, height: keyHeight)
                    Color.clear.frame(width: keyWidth, height: keyHeight)
                }
                HStack(spacing: spacing) {
                    keycap(keys[0], width: keyWidth, height: keyHeight)
                    keycap(keys[2], width: keyWidth, height: keyHeight)
                    keycap(keys[3], width: keyWidth, height: keyHeight)
                }
            }
        }
    }

    private func keycap(_ key: KeyboardMapKey, width: CGFloat, height: CGFloat) -> some View {
        KeyboardKeycapView(
            key: key,
            isPressed: pressedKeyCodes.contains(key.code),
            language: language,
            usesCompactLabel: true
        )
        .frame(width: width, height: height)
    }
}

private struct KeyboardKeycapView: View {
    @Environment(\.colorScheme) private var colorScheme

    let key: KeyboardMapKey
    let isPressed: Bool
    let language: AppLanguage
    var usesCompactLabel = false

    var body: some View {
        Text(key.label)
            .font(
                .system(
                    size: labelSize,
                    weight: isPressed ? .bold : .medium,
                    design: key.label.count == 1 ? .rounded : .default
                )
            )
            .minimumScaleFactor(0.65)
            .lineLimit(1)
            .foregroundStyle(isPressed ? Color.red : Color.primary.opacity(0.82))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(keyBackground, in: RoundedRectangle(cornerRadius: usesCompactLabel ? 4 : 6))
            .overlay {
                RoundedRectangle(cornerRadius: usesCompactLabel ? 4 : 6)
                    .stroke(
                        isPressed ? Color.red.opacity(0.85) : Color.primary.opacity(0.16),
                        lineWidth: isPressed ? 1.5 : 0.8
                    )
            }
            .shadow(
                color: isPressed ? Color.red.opacity(0.2) : Color.black.opacity(colorScheme == .dark ? 0.18 : 0.1),
                radius: isPressed ? 1 : 1.5,
                y: isPressed ? 0 : 1
            )
            .scaleEffect(isPressed ? 0.96 : 1)
            .offset(y: isPressed ? 1 : 0)
            .help(keyName)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(keyName)
            .accessibilityValue(text(isPressed ? "keyboard.keyPressed" : "keyboard.keyReleased"))
    }

    private var keyBackground: Color {
        if isPressed {
            return Color.red.opacity(colorScheme == .dark ? 0.28 : 0.13)
        }
        return Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.055)
    }

    private var labelSize: CGFloat {
        if usesCompactLabel { return 8 }
        return key.label.count > 2 ? 9 : 12
    }

    private var keyName: String {
        KeyCatalog.descriptor(for: key.code)?.displayName(language: language) ?? key.label
    }

    private func text(_ key: String) -> String {
        L10n.text(key, language: language)
    }
}
