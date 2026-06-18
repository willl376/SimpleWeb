import UIKit
import WebKit

class BrowserViewController: UIViewController {

    private var webViewContainer = UIView()
    private let topToolbar = UIToolbar()
    private let bottomToolbar = UIToolbar()
    private let urlTextField = UITextField()
    private let tabManager = TabManager.shared

    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    private var tabCountLabel: UIBarButtonItem!
    private var currentWebView: WKWebView? {
        return tabManager.currentTab?.webView
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTopToolbar()
        setupBottomToolbar()
        setupWebViewContainer()
        addInitialTab()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: - Setup

    private func setupTopToolbar() {
        topToolbar.translatesAutoresizingMaskIntoConstraints = false
        topToolbar.isTranslucent = false
        topToolbar.barTintColor = UIColor(white: 0.97, alpha: 1.0)
        view.addSubview(topToolbar)

        NSLayoutConstraint.activate([
            topToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topToolbar.heightAnchor.constraint(equalToConstant: 44)
        ])

        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlTextField.borderStyle = .roundedRect
        urlTextField.placeholder = "Enter URL or search..."
        urlTextField.autocapitalizationType = .none
        urlTextField.autocorrectionType = .no
        urlTextField.keyboardType = .webSearch
        urlTextField.returnKeyType = .go
        urlTextField.clearButtonMode = .whileEditing
        urlTextField.font = UIFont.systemFont(ofSize: 15)
        urlTextField.delegate = self
        urlTextField.backgroundColor = UIColor(white: 0.92, alpha: 1.0)

        let urlItem = UIBarButtonItem(customView: urlTextField)
        topToolbar.items = [urlItem]
    }

    private func setupBottomToolbar() {
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.isTranslucent = false
        bottomToolbar.barTintColor = UIColor(white: 0.97, alpha: 1.0)
        view.addSubview(bottomToolbar)

        NSLayoutConstraint.activate([
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 44)
        ])

        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                     style: .plain, target: self,
                                     action: #selector(goBack))
        backButton.isEnabled = false

        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                        style: .plain, target: self,
                                        action: #selector(goForward))
        forwardButton.isEnabled = false

        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(refreshPage))
        let flex = UIBarButtonItem(flexibleSpace: true, target: nil, action: nil)
        let bookmarksButton = UIBarButtonItem(barButtonSystemItem: .bookmarks,
                                              target: self,
                                              action: #selector(showBookmarks))
        let newTabButton = UIBarButtonItem(barButtonSystemItem: .add,
                                           target: self,
                                           action: #selector(addNewTab))
        tabCountLabel = UIBarButtonItem(title: "1", style: .plain,
                                        target: self, action: #selector(showTabSwitcher))

        let shareButton = UIBarButtonItem(barButtonSystemItem: .action,
                                          target: self,
                                          action: #selector(sharePage))

        bottomToolbar.items = [
            backButton, forwardButton, refreshButton, flex,
            bookmarksButton, newTabButton, tabCountLabel, flex,
            shareButton
        ]
    }

    private func setupWebViewContainer() {
        webViewContainer.translatesAutoresizingMaskIntoConstraints = false
        webViewContainer.backgroundColor = .white
        view.addSubview(webViewContainer)

        NSLayoutConstraint.activate([
            webViewContainer.topAnchor.constraint(equalTo: topToolbar.bottomAnchor),
            webViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor)
        ])
    }

    private func addInitialTab() {
        let config = WKWebViewConfiguration()
        _ = tabManager.addTab(configuration: config)
        attachCurrentWebView()
    }

    // MARK: - WebView Management

    private func attachCurrentWebView() {
        webViewContainer.subviews.forEach { $0.removeFromSuperview() }
        guard let wv = currentWebView else { return }
        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        wv.uiDelegate = self
        webViewContainer.addSubview(wv)

        NSLayoutConstraint.activate([
            wv.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            wv.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            wv.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            wv.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        ])

        updateUI()
    }

    private func updateUI() {
        guard let tab = tabManager.currentTab else { return }
        urlTextField.text = tab.url?.absoluteString ?? ""
        backButton.isEnabled = tab.webView.canGoBack
        forwardButton.isEnabled = tab.webView.canGoForward
        tabCountLabel.title = "\(tabManager.count)"
    }

    // MARK: - Actions

    @objc private func goBack() {
        currentWebView?.goBack()
    }

    @objc private func goForward() {
        currentWebView?.goForward()
    }

    @objc private func refreshPage() {
        currentWebView?.reload()
    }

    @objc private func addNewTab() {
        let config = WKWebViewConfiguration()
        _ = tabManager.addTab(configuration: config)
        attachCurrentWebView()
    }

    @objc private func showBookmarks() {
        let vc = BookmarksViewController()
        vc.didSelectBookmark = { [weak self] bookmark in
            self?.dismiss(animated: true) {
                guard let url = URL(string: bookmark.url) else { return }
                self?.loadURL(url)
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func showTabSwitcher() {
        let vc = TabSwitcherViewController()
        vc.didSelectTab = { [weak self] index in
            self?.dismiss(animated: true) {
                self?.tabManager.switchToTab(at: index)
                self?.attachCurrentWebView()
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }

    @objc private func sharePage() {
        guard let tab = tabManager.currentTab, let url = tab.url else { return }
        let vc = UIActivityViewController(activityItems: [url, tab.title], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = bottomToolbar.items?.last
        present(vc, animated: true)
    }

    private func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        currentWebView?.load(request)
        urlTextField.text = url.absoluteString
        urlTextField.resignFirstResponder()
    }

    private func navigateToURL(_ text: String) {
        var urlString = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if urlString.isEmpty { return }

        if !urlString.contains(".") || urlString.contains(" ") {
            urlString = "https://www.google.com/search?q=" + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        } else if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }

        guard let url = URL(string: urlString) else { return }
        loadURL(url)
    }
}

// MARK: - UITextFieldDelegate

extension BrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            navigateToURL(text)
        }
        return true
    }
}

// MARK: - WKNavigationDelegate

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateUI()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView === currentWebView {
            tabManager.currentTab?.title = webView.title ?? ""
            tabManager.currentTab?.url = webView.url
            urlTextField.text = webView.url?.absoluteString ?? ""
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code != NSURLErrorCancelled {
            let alert = UIAlertController(title: "Error",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Load Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let config = WKWebViewConfiguration()
            _ = tabManager.addTab(configuration: config)
            attachCurrentWebView()
            if let url = navigationAction.request.url {
                loadURL(url)
            }
        }
        return nil
    }
}
