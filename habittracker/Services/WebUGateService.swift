import Combine
import Foundation

@MainActor
final class WebUGateService: ObservableObject {
    private static let productionAPIURL = URL(string: "https://tiny-endpoint.vercel.app/api/webview-target")!
    private static let requestTimeout: TimeInterval = 10

    @Published private(set) var shouldShowWebView = false
    @Published private(set) var targetURL = ""
    @Published private(set) var isLoading = false

    private static func resolvedAPIURL() -> URL {
        #if DEBUG
        if let raw = ProcessInfo.processInfo.environment["WEBVIEW_GATE_API"],
           let url = URL(string: raw),
           !raw.isEmpty {
            return url
        }
        return URL(string: "http://127.0.0.1:8000/api/webview-target")!
        #else
        return productionAPIURL
        #endif
    }

    func checkRemote() async {
        isLoading = true
        defer { isLoading = false }

        var request = URLRequest(url: Self.resolvedAPIURL())
        request.timeoutInterval = Self.requestTimeout
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                applyDisabledState()
                return
            }

            let config = try JSONDecoder().decode(RemoteWebViewConfig.self, from: data)
            let enabled = config.enabled ?? false
            let urlString = config.targetURL?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            guard enabled, !urlString.isEmpty, URL(string: urlString) != nil else {
                applyDisabledState()
                return
            }

            shouldShowWebView = true
            targetURL = urlString
        } catch {
            applyDisabledState()
        }
    }

    private func applyDisabledState() {
        shouldShowWebView = false
        targetURL = ""
    }
}

private struct RemoteWebViewConfig: Decodable {
    let enabled: Bool?
    let targetURL: String?

    enum CodingKeys: String, CodingKey {
        case enabled
        case targetURL = "target_url"
    }
}
