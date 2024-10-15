import Foundation

class AliyunPushLog {
    static var logEnabled = false

    static func enableLog() {
        logEnabled = true
    }

    static func isLogEnabled() -> Bool {
        return logEnabled
    }

    static func disableLog() {
        logEnabled = false
    }
}
