import UIKit
import WebKit

class Tab {
    let id: UUID
    var title: String
    var url: URL?
    var webView: WKWebView

    init(webView: WKWebView) {
        self.id = UUID()
        self.title = "New Tab"
        self.url = nil
        self.webView = webView
    }
}
