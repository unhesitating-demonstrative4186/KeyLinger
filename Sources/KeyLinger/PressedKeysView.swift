import SwiftUI

struct PressedKeysView: View {
    @ObservedObject var monitor: KeyboardMonitor
    @ObservedObject var settings: AppSettings
    @ObservedObject var inputAccess: InputMonitoringAccess
    let openSettings: () -> Void

    var body: some View {
        Group {
            if settings.compactMode {
                compactView
            } else {
                fullView
            }
        }
        .background(.ultraThinMaterial)
        .tint(settings.accentTheme.tintColor)
    }

    private var fullView: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if !inputAccess.isGranted {
                permissionBanner
            }

            fullContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            footer
        }
        .padding(18)
        .frame(
            minWidth: settings.standardViewMode == .keyboard ? 640 : 390,
            idealWidth: settings.standardViewMode == .keyboard ? 760 : 430,
            minHeight: settings.standardViewMode == .keyboard ? 350 : 230,
            idealHeight: settings.standardViewMode == .keyboard ? 390 : 280
        )
    }

    @ViewBuilder
    private var fullContent: some View {
        if settings.standardViewMode == .keyboard {
            KeyboardMapView(
                pressedKeys: monitor.pressedKeys,
                language: settings.language
            )
        } else if monitor.pressedKeys.isEmpty {
            emptyState
        } else {
            pressedKeyGrid
        }
    }

    private var compactView: some View {
        HStack(spacing: 10) {
            statusDot

            VStack(alignment: .leading, spacing: 2) {
                Text(compactTitle)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                if !inputAccess.isGranted {
                    Text(text("permission.compact"))
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Spacer(minLength: 4)

            if !inputAccess.isGranted {
                Button(action: inputAccess.requestFromUser) {
                    Image(systemName: "exclamationmark.shield")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.orange)
                .help(text("permission.enable"))
            }

            Button(action: openSettings) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .help(text("settings.open"))

            Button {
                settings.compactMode = false
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .help(text("window.expand"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(minWidth: 280, idealWidth: 330, maxWidth: .infinity, minHeight: 58)
    }

    private var header: some View {
        HStack(spacing: 10) {
            statusDot

            VStack(alignment: .leading, spacing: 2) {
                Text(text(monitor.pressedKeys.isEmpty ? "status.normalTitle" : "status.pressedTitle"))
                    .font(.headline)
                Text(
                    monitor.pressedKeys.isEmpty
                        ? text("status.noUnreleased")
                        : L10n.format("status.reportedCount", language: settings.language, monitor.pressedKeys.count)
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("", selection: $settings.standardViewMode) {
                Image(systemName: "list.bullet")
                    .tag(StandardViewMode.list)
                    .help(text("view.list"))
                Image(systemName: "keyboard")
                    .tag(StandardViewMode.keyboard)
                    .help(text("view.keyboard"))
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 76)
            .accessibilityLabel(text("view.mode"))

            Button(action: openSettings) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .help(text("settings.open"))

            Button {
                settings.compactMode = true
            } label: {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .help(text("window.compact"))
        }
    }

    private var statusDot: some View {
        Circle()
            .fill(monitor.pressedKeys.isEmpty ? Color.green : Color.red)
            .frame(width: 10, height: 10)
            .shadow(
                color: monitor.pressedKeys.isEmpty ? .green.opacity(0.5) : .red.opacity(0.55),
                radius: 5
            )
    }

    private var permissionBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.shield.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(text("permission.title"))
                    .font(.caption.weight(.semibold))
                Text(text("permission.message"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            Button(text("permission.enable"), action: inputAccess.requestFromUser)
                .controlSize(.small)
        }
        .padding(10)
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 9))
        .overlay {
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.orange.opacity(0.28), lineWidth: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.green)
            Text(text("empty.none"))
                .font(.system(.body, design: .rounded, weight: .medium))
            Text(text("empty.hint"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var pressedKeyGrid: some View {
        ScrollView {
            FlowLayout(spacing: 8) {
                ForEach(monitor.pressedKeys) { key in
                    Text(key.displayName(language: settings.language))
                        .font(.system(.body, design: .rounded, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.14), in: RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red.opacity(0.45), lineWidth: 1)
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .foregroundStyle(.tint)
            Text(
                L10n.format(
                    "footer.reading",
                    language: settings.language,
                    settings.pollingFrequency.rawValue
                )
            )
            Spacer()
            Text("⌨ " + String(monitor.pressedKeys.count))
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var compactTitle: String {
        guard !monitor.pressedKeys.isEmpty else { return text("compact.normal") }
        return monitor.pressedKeys
            .map { $0.displayName(language: settings.language) }
            .joined(separator: " + ")
    }

    private func text(_ key: String) -> String {
        L10n.text(key, language: settings.language)
    }
}
