//
//  KeyCodes.swift
//  Mactris
//
//  Created by Sebastian Boettcher on 04.01.24.
//

// swiftlint:disable identifier_name
public enum KeyCode: UInt16 {
    case a                   = 0x00
    case s                   = 0x01
    case d                   = 0x02
    case f                   = 0x03
    case h                   = 0x04
    case g                   = 0x05
    case z                   = 0x06
    case x                   = 0x07
    case c                   = 0x08
    case v                   = 0x09
    case b                   = 0x0B
    case q                   = 0x0C
    case w                   = 0x0D
    case e                   = 0x0E
    case r                   = 0x0F
    case y                   = 0x10
    case t                   = 0x11
    case number1             = 0x12
    case number2             = 0x13
    case number3             = 0x14
    case number4             = 0x15
    case number6             = 0x16
    case number5             = 0x17
    case equal               = 0x18
    case number9             = 0x19
    case number7             = 0x1A
    case minus               = 0x1B
    case number8             = 0x1C
    case number0             = 0x1D
    case rightBracket        = 0x1E
    case o                   = 0x1F
    case u                   = 0x20
    case leftBracket         = 0x21
    case i                   = 0x22
    case p                   = 0x23
    case l                   = 0x25
    case j                   = 0x26
    case quote               = 0x27
    case k                   = 0x28
    case semicolon           = 0x29
    case backslash           = 0x2A
    case comma               = 0x2B
    case slash               = 0x2C
    case n                   = 0x2D
    case m                   = 0x2E
    case period              = 0x2F
    case grave               = 0x32
    case keypadDecimal       = 0x41
    case keypadMultiply      = 0x43
    case keypadPlus          = 0x45
    case keypadClear         = 0x47
    case keypadDivide        = 0x4B
    case keypadEnter         = 0x4C
    case keypadMinus         = 0x4E
    case keypadEquals        = 0x51
    case keypad0             = 0x52
    case keypad1             = 0x53
    case keypad2             = 0x54
    case keypad3             = 0x55
    case keypad4             = 0x56
    case keypad5             = 0x57
    case keypad6             = 0x58
    case keypad7             = 0x59
    case keypad8             = 0x5B
    case keypad9             = 0x5C
    case `return`            = 0x24
    case tab                 = 0x30
    case space               = 0x31
    case delete              = 0x33
    case escape              = 0x35
    case command             = 0x37
    case shift               = 0x38
    case capslock            = 0x39
    case option              = 0x3A
    case control             = 0x3B
    case rightshift          = 0x3C
    case rightoption         = 0x3D
    case rightcontrol        = 0x3E
    case function            = 0x3F
    case f17                 = 0x40
    case volumeup            = 0x48
    case volumedown          = 0x49
    case mute                = 0x4A
    case f18                 = 0x4F
    case f19                 = 0x50
    case f20                 = 0x5A
    case f5                  = 0x60
    case f6                  = 0x61
    case f7                  = 0x62
    case f3                  = 0x63
    case f8                  = 0x64
    case f9                  = 0x65
    case f11                 = 0x67
    case f13                 = 0x69
    case f16                 = 0x6A
    case f14                 = 0x6B
    case f10                 = 0x6D
    case f12                 = 0x6F
    case f15                 = 0x71
    case help                = 0x72
    case home                = 0x73
    case pageup              = 0x74
    case forwarddelete       = 0x75
    case f4                  = 0x76
    case end                 = 0x77
    case f2                  = 0x78
    case pagedown            = 0x79
    case f1                  = 0x7A
    case arrowLeft           = 0x7B
    case arrowRight          = 0x7C
    case arrowDown           = 0x7D
    case arrowUp             = 0x7E
}
// swiftlint:enable identifier_name

extension KeyCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .a: return "A"
        case .s: return "S"
        case .d: return "D"
        case .f: return "F"
        case .h: return "H"
        case .g: return "G"
        case .z: return "Z"
        case .x: return "X"
        case .c: return "C"
        case .v: return "V"
        case .b: return "B"
        case .q: return "Q"
        case .w: return "W"
        case .e: return "E"
        case .r: return "R"
        case .y: return "Y"
        case .t: return "T"
        case .number1: return "1"
        case .number2: return "2"
        case .number3: return "3"
        case .number4: return "4"
        case .number6: return "6"
        case .number5: return "5"
        case .equal: return "="
        case .number9: return "9"
        case .number7: return "7"
        case .minus: return "-"
        case .number8: return "8"
        case .number0: return "0"
        case .rightBracket: return "]"
        case .o: return "O"
        case .u: return "U"
        case .leftBracket: return "["
        case .i: return "I"
        case .p: return "P"
        case .l: return "L"
        case .j: return "J"
        case .quote: return "\""
        case .k: return "K"
        case .semicolon: return ";"
        case .backslash: return "\\"
        case .comma: return ","
        case .slash: return "/"
        case .n: return "N"
        case .m: return "M"
        case .period: return "."
        case .grave: return "`"
        case .keypadDecimal: return "."
        case .keypadMultiply: return "*"
        case .keypadPlus: return "+"
        case .keypadClear: return "⌧"
        case .keypadDivide: return "/"
        case .keypadEnter: return "⌅"
        case .keypadMinus: return "-"
        case .keypadEquals: return "="
        case .keypad0: return "Keypad 0"
        case .keypad1: return "Keypad 1"
        case .keypad2: return "Keypad 2"
        case .keypad3: return "Keypad 3"
        case .keypad4: return "Keypad 4"
        case .keypad5: return "Keypad 5"
        case .keypad6: return "Keypad 6"
        case .keypad7: return "Keypad 7"
        case .keypad8: return "Keypad 8"
        case .keypad9: return "Keypad 9"
        case .return: return "⏎"
        case .tab: return "⇥"
        case .space: return "␣"
        case .delete: return "⌦"
        case .escape: return "⎋"
        case .command: return "Left ⌘"
        case .shift: return "Left ⇪"
        case .capslock: return "⇪"
        case .option: return "Left ⌥"
        case .control: return "Left ⌃"
        case .rightshift: return "Right ⇪"
        case .rightoption: return "Right ⌥"
        case .rightcontrol: return "Right ⌃"
        case .function: return "fn"
        case .f17: return "F17"
        case .volumeup: return "Volume up"
        case .volumedown: return "Volume down"
        case .mute: return "Mute"
        case .f18: return "F18"
        case .f19: return "F19"
        case .f20: return "F20"
        case .f5: return "F5"
        case .f6: return "F6"
        case .f7: return "F7"
        case .f3: return "F3"
        case .f8: return "F8"
        case .f9: return "F9"
        case .f11: return "F11"
        case .f13: return "F13"
        case .f16: return "F16"
        case .f14: return "F14"
        case .f10: return "F10"
        case .f12: return "F12"
        case .f15: return "F15"
        case .help: return "Help"
        case .home: return "⤒"
        case .pageup: return "⇞"
        case .forwarddelete: return "⌦"
        case .f4: return "F4"
        case .end: return "⤓"
        case .f2: return "F2"
        case .pagedown: return "⇟"
        case .f1: return "F1"
        case .arrowLeft: return "←"
        case .arrowRight: return "→"
        case .arrowDown: return "↓"
        case .arrowUp: return "↑"
        }
    }
}
