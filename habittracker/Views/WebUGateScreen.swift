import SwiftUI
import UIKit
import WebKit

struct WebUGateScreen: View {
    let urlString: String

    @State private var isPageLoading = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            FullScreenWebViewRepresentable(
                urlString: urlString,
                isLoading: $isPageLoading
            )
            .ignoresSafeArea()

            if isPageLoading {
                SwiftUI.ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.2)
            }
        }
    }
}

struct FullScreenWebViewRepresentable: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all

        let userContentController = WKUserContentController()

        let noZoomScript = WKUserScript(
            source: """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no';
            document.head.appendChild(meta);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(noZoomScript)
        userContentController.add(LeakAvoider(delegate: context.coordinator), name: "godot")

        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = true
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.bounces = true

        context.coordinator.webView = webView

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        } else {
            DispatchQueue.main.async {
                isLoading = false
            }
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }
}

extension FullScreenWebViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: FullScreenWebViewRepresentable
        weak var webView: WKWebView?

        init(parent: FullScreenWebViewRepresentable) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            _ = message.body
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in
                parent.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handleLoadError(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handleLoadError(error)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = url.scheme?.lowercased() ?? ""

            if scheme == "http" || scheme == "https" || scheme == "about" || scheme == "blob" {
                decisionHandler(.allow)
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            }
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? false) {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            presentAlert(title: nil, message: message) {
                completionHandler()
            }
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            guard let presenter = topViewController(from: webView) else {
                completionHandler(false)
                return
            }

            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            presenter.present(alert, animated: true)
        }

        private func handleLoadError(_ error: Error) {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                return
            }

            Task { @MainActor in
                parent.isLoading = false
            }
        }

        private func presentAlert(title: String?, message: String, onConfirm: @escaping () -> Void) {
            guard let presenter = topViewController(from: webView) else {
                onConfirm()
                return
            }

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                onConfirm()
            })
            presenter.present(alert, animated: true)
        }

        private func topViewController(from webView: WKWebView?) -> UIViewController? {
            if let window = webView?.window, let root = window.rootViewController {
                return root.topMost
            }

            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
                if let root = keyWindow?.rootViewController {
                    return root.topMost
                }
            }

            return nil
        }
    }
}

private final class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?

    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

private extension UIViewController {
    var topMost: UIViewController {
        if let presented = presentedViewController {
            return presented.topMost
        }
        if let nav = self as? UINavigationController, let visible = nav.visibleViewController {
            return visible.topMost
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMost
        }
        return self
    }
}

#if DEBUG
#Preview {
    WebUGateScreen(urlString: "https://www.apple.com")
}
#endif
