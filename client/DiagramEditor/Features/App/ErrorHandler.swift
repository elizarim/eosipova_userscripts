import Cocoa

protocol AppErrorHandling {
    func showError(_ error: Error, message: String)
}

final class AppErrorHandler: AppErrorHandling {
    func showError(_ error: Error, message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
