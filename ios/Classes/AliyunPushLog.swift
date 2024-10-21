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

    static func d(_ format: String, _ args: CVarArg...) {
        if logEnabled {
            NSLog("[CloudPush Debug]: \(String(format: format, arguments: args))")
        }
    }

    static func e(_ format: String, _ args: CVarArg...) {
        if logEnabled {
            NSLog("[CloudPush Error]: \(String(format: format, arguments: args))")
        }
    }
}
