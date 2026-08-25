import SwiftUI
import WebKit

// 1. App'ning kirish nuqtasi
@main
struct YandexBrowserApp: App {
    var body: some Scene {
        WindowGroup {
            BrowserView()
        }
    }
}

// 2. WKWebView'ni SwiftUI'ga moslashtirish (Wrapper)
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Agar URL o'zgargan bo'lsa, yangi sahifani yuklaydi
        if uiView.url != url {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

// 3. Brauzer interfeysi va mantiq
struct BrowserView: View {
    @State private var webView = WKWebView()
    @State private var urlString: String = "https://yandex.com"
    @State private var currentURL: URL = URL(string: "https://yandex.com")!

    var body: some View {
        VStack(spacing: 0) {
            // URL / Qidiruv satri va Boshqaruv tugmalari
            HStack(spacing: 10) {
                // Orqaga tugmasi
                Button(action: {
                    if webView.canGoBack { webView.goBack() }
                }) {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }

                // Oldinga tugmasi
                Button(action: {
                    if webView.canGoForward { webView.goForward() }
                }) {
                    Image(systemName: "chevron.right")
                        .padding(8)
                }

                // Qidiruv / URL kiritish maydoni
                TextField("Qidiruv yoki URL...", text: $urlString, onCommit: searchOrLoad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                // Yangilash (Refresh) tugmasi
                Button(action: {
                    webView.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .padding(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6))

            // Veb-sahifa ko'rinadigan joy
            WebView(url: currentURL, webView: $webView)
        }
    }

    // Qidiruv mantiqiy funksiyasi
    private func searchOrLoad() {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
            // Agar to'liq URL kiritilgan bo'lsa
            if let url = URL(string: trimmed) {
                currentURL = url
            }
        } else if trimmed.contains(".") && !trimmed.contains(" ") {
            // Agar va domen formatida bo'lsa (masalan: google.com)
            if let url = URL(string: "https://" + trimmed) {
                currentURL = url
            }
        } else {
            // Aks holda matnni Yandex orqali qidiradi
            let searchQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let searchURL = URL(string: "https://yandex.com/search/?text=\(searchQuery)") {
                currentURL = searchURL
            }
        }
    }
}