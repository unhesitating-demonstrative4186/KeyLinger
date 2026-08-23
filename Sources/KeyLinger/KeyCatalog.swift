import CoreGraphics
import Foundation

struct KeyDescriptor: Identifiable, Equatable, Sendable {
    let code: CGKeyCode
    let englishName: String
    let chineseName: String

    var id: CGKeyCode { code }

    func displayName(language: AppLanguage) -> String {
        language.resourceName == "zh-Hans" ? chineseName : englishName
    }
}

enum KeyCatalog {
    // The order follows a physical keyboard so simultaneous keys are easy to scan.
    static let all: [KeyDescriptor] = [
        key(53, "Esc"),
        key(122, "F1"), key(120, "F2"), key(99, "F3"), key(118, "F4"),
        key(96, "F5"), key(97, "F6"), key(98, "F7"), key(100, "F8"),
        key(101, "F9"), key(109, "F10"), key(103, "F11"), key(111, "F12"),
        key(105, "F13"), key(107, "F14"), key(113, "F15"), key(106, "F16"),
        key(64, "F17"), key(79, "F18"), key(80, "F19"), key(90, "F20"),

        key(50, "`"), key(18, "1"), key(19, "2"), key(20, "3"), key(21, "4"),
        key(23, "5"), key(22, "6"), key(26, "7"), key(28, "8"), key(25, "9"),
        key(29, "0"), key(27, "-"), key(24, "="), key(51, "Delete"),

        key(48, "Tab"), key(12, "Q"), key(13, "W"), key(14, "E"), key(15, "R"),
        key(17, "T"), key(16, "Y"), key(32, "U"), key(34, "I"), key(31, "O"),
        key(35, "P"), key(33, "["), key(30, "]"), key(42, "\\"),

        key(57, "Caps Lock"), key(0, "A"), key(1, "S"), key(2, "D"), key(3, "F"),
        key(5, "G"), key(4, "H"), key(38, "J"), key(40, "K"), key(37, "L"),
        key(41, ";"), key(39, "'"), key(36, "Return"),

        key(56, "⇧ Left", "⇧ 左"), key(6, "Z"), key(7, "X"), key(8, "C"), key(9, "V"),
        key(11, "B"), key(45, "N"), key(46, "M"), key(43, ","), key(47, "."),
        key(44, "/"), key(60, "⇧ Right", "⇧ 右"),

        key(63, "Fn"), key(59, "⌃ Left", "⌃ 左"), key(58, "⌥ Left", "⌥ 左"),
        key(55, "⌘ Left", "⌘ 左"), key(49, "Space", "空格"),
        key(54, "⌘ Right", "⌘ 右"), key(61, "⌥ Right", "⌥ 右"),
        key(62, "⌃ Right", "⌃ 右"),

        key(114, "Help"), key(115, "Home"), key(116, "Page Up"),
        key(117, "Forward Delete", "向前删除"), key(119, "End"), key(121, "Page Down"),
        key(123, "←"), key(126, "↑"), key(125, "↓"), key(124, "→"),

        key(72, "Volume +", "音量 +"), key(73, "Volume −", "音量 −"),
        key(74, "Mute", "静音"),

        key(71, "Numpad Clear", "小键盘 Clear"), key(81, "Numpad =", "小键盘 ="),
        key(75, "Numpad /", "小键盘 /"), key(67, "Numpad *", "小键盘 *"),
        key(78, "Numpad -", "小键盘 -"), key(69, "Numpad +", "小键盘 +"),
        key(82, "Numpad 0", "小键盘 0"), key(83, "Numpad 1", "小键盘 1"),
        key(84, "Numpad 2", "小键盘 2"), key(85, "Numpad 3", "小键盘 3"),
        key(86, "Numpad 4", "小键盘 4"), key(87, "Numpad 5", "小键盘 5"),
        key(88, "Numpad 6", "小键盘 6"), key(89, "Numpad 7", "小键盘 7"),
        key(91, "Numpad 8", "小键盘 8"), key(92, "Numpad 9", "小键盘 9"),
        key(65, "Numpad .", "小键盘 ."), key(76, "Numpad Enter", "小键盘 Enter"),

        key(10, "ISO §"), key(93, "JIS ¥"), key(94, "JIS _"),
        key(95, "JIS Numpad ,", "JIS 小键盘 ,"), key(102, "Eisu", "英数"),
        key(104, "Kana", "かな")
    ]

    private static func key(
        _ code: CGKeyCode,
        _ englishName: String,
        _ chineseName: String? = nil
    ) -> KeyDescriptor {
        KeyDescriptor(
            code: code,
            englishName: englishName,
            chineseName: chineseName ?? englishName
        )
    }
}
