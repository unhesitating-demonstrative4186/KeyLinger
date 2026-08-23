import AppKit

@MainActor
private func runApplication() {
    let application = NSApplication.shared
    let delegate = AppDelegate()

    let activationPolicy: NSApplication.ActivationPolicy = AppSettings.shouldShowDockIcon()
        ? .regular
        : .accessory
    application.setActivationPolicy(activationPolicy)
    application.delegate = delegate
    application.run()

    withExtendedLifetime(delegate) {}
}

if CommandLine.arguments.contains("--validate-keyboard-layout") {
    let errors = CompactANSIKeyboardLayout.validationErrors()
    precondition(errors.isEmpty, errors.joined(separator: "\n"))
    print("Keyboard layout validation passed")
} else {
    runApplication()
}
