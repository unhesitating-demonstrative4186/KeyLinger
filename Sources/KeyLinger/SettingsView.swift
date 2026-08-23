import SwiftUI

@MainActor
struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @StateObject private var updateChecker = UpdateChecker()

    private let projectURL = URL(string: "https://github.com/myweihp/KeyLinger")!
    private let pickerColumnWidth: CGFloat = 170

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            Divider()
            generalSection
            Divider()
            windowSection
            Divider()
            aboutSection
        }
        .padding(22)
        .frame(width: 460)
        .background(.ultraThinMaterial)
        .tint(settings.accentTheme.tintColor)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "keyboard.badge.ellipsis")
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 42, height: 42)
                .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(text("settings.title"))
                    .font(.title3.weight(.semibold))
                Text(text("settings.subtitle"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("settings.general", systemImage: "slider.horizontal.3")

            settingRow(label: text("settings.language")) {
                Picker("", selection: $settings.language) {
                    Text(text("language.system")).tag(AppLanguage.system)
                    Text("简体中文").tag(AppLanguage.simplifiedChinese)
                    Text("繁體中文").tag(AppLanguage.traditionalChinese)
                    Text("English").tag(AppLanguage.english)
                }
                .labelsHidden()
                .fixedSize()
                .frame(width: pickerColumnWidth, alignment: .trailing)
            }

            settingRow(label: text("settings.frequency")) {
                Picker("", selection: $settings.pollingFrequency) {
                    ForEach(PollingFrequency.allCases) { frequency in
                        Text(String(frequency.rawValue) + " Hz").tag(frequency)
                    }
                }
                .labelsHidden()
                .fixedSize()
                .frame(width: pickerColumnWidth, alignment: .trailing)
            }

            settingRow(label: text("settings.theme")) {
                Picker("", selection: $settings.accentTheme) {
                    ForEach(AccentTheme.allCases) { theme in
                        themeLabel(theme).tag(theme)
                    }
                }
                .labelsHidden()
                .fixedSize()
                .frame(width: pickerColumnWidth, alignment: .trailing)
            }

            Text(text("settings.frequencyHint"))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.leading, 24)
        }
    }

    private var windowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("settings.window", systemImage: "macwindow")

            Toggle(isOn: $settings.compactMode) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(text("settings.compactMode"))
                    Text(text("settings.compactHint"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .padding(.leading, 24)

            Toggle(isOn: $settings.showDockIcon) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(text("settings.showDockIcon"))
                    Text(text("settings.showDockHint"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .padding(.leading, 24)
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("settings.about", systemImage: "info.circle")

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text("app.name"))
                        .font(.body.weight(.semibold))
                    Text(text("settings.purpose"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(L10n.format("settings.version", language: settings.language, appVersion))
                    Text(L10n.format("settings.author", language: settings.language, "myweihp"))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.leading, 24)

            HStack(spacing: 10) {
                Link(destination: projectURL) {
                    Label {
                        Text(text("settings.project"))
                    } icon: {
                        githubMark
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13, height: 13)
                    }
                }
                .foregroundStyle(.tint)

                Spacer()

                updateStatus

                Button(text("settings.checkUpdates")) {
                    updateChecker.check(currentVersion: appVersion)
                }
                .controlSize(.small)
                .disabled(updateChecker.status == .checking)
            }
            .font(.caption)
            .padding(.leading, 24)

            Label {
                Text(text("settings.privacy"))
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "hand.raised.fill")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.leading, 24)
        }
    }

    @ViewBuilder
    private var updateStatus: some View {
        switch updateChecker.status {
        case .idle:
            EmptyView()
        case .checking:
            ProgressView()
                .controlSize(.small)
                .help(text("settings.checking"))
        case let .upToDate(version):
            Label(
                L10n.format("settings.upToDate", language: settings.language, version),
                systemImage: "checkmark.circle.fill"
            )
            .foregroundStyle(.green)
        case let .updateAvailable(version, url):
            Link(destination: url) {
                Label(
                    L10n.format("settings.updateAvailable", language: settings.language, version),
                    systemImage: "arrow.down.circle.fill"
                )
            }
        case .noReleases:
            Text(text("settings.noReleases"))
                .foregroundStyle(.secondary)
        case .failed:
            Text(text("settings.updateFailed"))
                .foregroundStyle(.red)
        }
    }

    private func sectionTitle(_ key: String, systemImage: String) -> some View {
        Label(text(key), systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
    }

    private func settingRow<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(label)
                .padding(.leading, 24)
            Spacer()
            content()
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.9.0"
    }

    private var githubMark: Image {
        let bundles = [Bundle.main, Bundle.module]
        for bundle in bundles {
            if let url = bundle.url(forResource: "GitHubMark", withExtension: "svg"),
               let image = NSImage(contentsOf: url) {
                image.isTemplate = true
                return Image(nsImage: image)
            }
        }
        return Image(systemName: "link")
    }

    @ViewBuilder
    private func themeLabel(_ theme: AccentTheme) -> some View {
        HStack(spacing: 7) {
            themeSwatch(theme)
            Text(text(theme.localizationKey))
        }
    }

    @ViewBuilder
    private func themeSwatch(_ theme: AccentTheme) -> some View {
        if let color = theme.tintColor {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        } else {
            Image(systemName: "circle.lefthalf.filled")
                .foregroundStyle(.secondary)
                .frame(width: 10, height: 10)
        }
    }

    private func text(_ key: String) -> String {
        L10n.text(key, language: settings.language)
    }
}
