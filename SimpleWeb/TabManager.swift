import UIKit
import WebKit

class TabManager {
    static let shared = TabManager()

    private(set) var tabs: [Tab] = []
    private(set) var currentIndex: Int = 0

    var currentTab: Tab? {
        guard tabs.indices.contains(currentIndex) else { return nil }
        return tabs[currentIndex]
    }

    func addTab(configuration: WKWebViewConfiguration) -> Tab {
        let webView = WKWebView(frame: .zero, configuration: configuration)
        let tab = Tab(webView: webView)
        tabs.append(tab)
        currentIndex = tabs.count - 1
        return tab
    }

    func removeTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        tabs[index].webView.removeFromSuperview()
        tabs.remove(at: index)
        if tabs.isEmpty {
            let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
            let tab = Tab(webView: webView)
            tabs.append(tab)
        }
        if currentIndex >= tabs.count {
            currentIndex = tabs.count - 1
        }
    }

    func removeCurrentTab() {
        removeTab(at: currentIndex)
    }

    func switchToTab(at index: Int) {
        guard tabs.indices.contains(index) else { return }
        currentIndex = index
    }

    var count: Int {
        return tabs.count
    }
}
