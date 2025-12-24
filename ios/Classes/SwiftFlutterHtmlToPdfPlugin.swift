import Flutter
import UIKit
import WebKit

public class SwiftFlutterHtmlToPdfPlugin: NSObject, FlutterPlugin, WKNavigationDelegate {
    var wkWebView: WKWebView?
    var pendingResult: FlutterResult?
    var pdfWidth: Double = 0
    var pdfHeight: Double = 0
    var linksClickable: Bool = false
    var htmlContent: String = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_html_to_pdf", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterHtmlToPdfPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convertHtmlToPdf":
            guard let args = call.arguments as? [String: Any],
                  let htmlFilePath = args["htmlFilePath"] as? String,
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int,
                  let linksClickable = args["linksClickable"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }

            // Reset and Store parameters
            self.pendingResult = result
            self.pdfWidth = Double(width)
            self.pdfHeight = Double(height)
            self.linksClickable = linksClickable
            
            // Get HTML content
            let content = FileHelper.getContent(from: htmlFilePath)
            if content.isEmpty {
                result(FlutterError(code: "EMPTY_FILE", message: "HTML content is empty", details: nil))
                return
            }
            self.htmlContent = content

            // Initialize WebView on Main Thread
            setupWebView()
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setupWebView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let viewController = UIApplication.shared.delegate?.window?!.rootViewController
            
            // Create Configuration
            let config = WKWebViewConfiguration()
            
            // Initialize WebView
            self.wkWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.pdfWidth, height: self.pdfHeight), configuration: config)
            self.wkWebView?.navigationDelegate = self
            self.wkWebView?.isHidden = true
            
            // Important: Add to view hierarchy so it renders properly
            viewController?.view.addSubview(self.wkWebView!)
            
            // Load Content
            self.wkWebView?.loadHTMLString(self.htmlContent, baseURL: Bundle.main.bundleURL)
            
            // Setup a Safety Timeout (30 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                if self.pendingResult != nil {
                    self.cleanup()
                    self.pendingResult?(FlutterError(code: "TIMEOUT", message: "PDF generation timed out", details: nil))
                    self.pendingResult = nil
                }
            }
        }
    }

    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Wait slightly for assets (images/fonts) to finish internal rendering
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, self.pendingResult != nil else { return }
            self.generatePDF()
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.cleanup()
        self.pendingResult?(FlutterError(code: "LOAD_ERROR", message: error.localizedDescription, details: nil))
        self.pendingResult = nil
    }
    private func containsLinks(_ html: String) -> Bool {
            return html.lowercased().contains("<a ") || html.lowercased().contains("</a>")
        }
    private func generatePDF() {
        // 1. Prepare Formatter on MAIN THREAD
        let fmt: UIPrintFormatter
        if self.linksClickable &&  self.containsLinks(self.htmlContent) {
            // UIMarkupTextPrintFormatter can be slow; we initialize it here
            fmt = UIMarkupTextPrintFormatter(markupText: self.htmlContent)
        } else if let webView = self.wkWebView {
            fmt = webView.viewPrintFormatter()
        } else {
            return
        }

        // 2. Perform PDF Creation
        // We stay on Main Thread for the creation because PDFCreator likely
        // uses UIPrintPageRenderer which is a UIKit component.
        let convertedFileURL = PDFCreator.create(
            printFormatter: fmt,
            width: self.pdfWidth,
            height: self.pdfHeight
        )
        
        let convertedFilePath = convertedFileURL.absoluteString.replacingOccurrences(of: "file://", with: "")

        // 3. Cleanup and Return
        self.cleanup()
        self.pendingResult?(convertedFilePath)
        self.pendingResult = nil
    }

    private func cleanup() {
        DispatchQueue.main.async { [weak self] in
            self?.wkWebView?.stopLoading()
            self?.wkWebView?.removeFromSuperview()
            self?.wkWebView = nil
        }
    }
}
