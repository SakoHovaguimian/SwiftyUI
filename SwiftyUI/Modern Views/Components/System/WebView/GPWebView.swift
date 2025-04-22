//
//  GPWebView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/27/24.
//

import SwiftUI
import WebKit

// TODO: - Style WebView. Tint Colors, Nav Colors

public struct GPWebView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var webView = WKWebView()
    @State private var isLoading: Bool = false
    @State private var progress: Double = 0.0
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    
    @State private var navBarFrame: CGRect = .zero
    
    public init(title: String, url: String) {
        
        self.title = title
        self.url = url
        
    }
    
    let title: String
    let url: String
    
    public var body: some View {
        
        ZStack(alignment: .top) {
            
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                NavBarView(
                    title: self.title,
                    leftButtonView: (self.navigationControlsView.asAnyView()),
                    navBackgroundStyle: .color(Color(uiColor: .systemBackground))
                )
                .overlay(alignment: .bottom) {
                    Divider()
                }
                
                WebView(
                    url: self.url,
                    webView: self.webView,
                    isLoading: self.$isLoading,
                    progress: self.$progress,
                    canGoBack: self.$canGoBack,
                    canGoForward: self.$canGoForward
                )
                .ignoresSafeArea()
                
            }
            
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .frame(maxHeight: .infinity)
        
    }
    
    private var navigationControlsView: some View {
        
        HStack {
            
            Button(action: {
                self.webView.goBack()
            }, label: {
                
                let image = self.canGoBack ? "arrowshape.turn.up.backward.fill" : "arrowshape.turn.up.backward"
                Image(systemName: image)
            })
            .disabled(!self.canGoBack)
            
            Button(action: {
                self.webView.goForward()
            }, label: {
                
                let image = self.canGoForward ? "arrowshape.turn.up.right.fill" : "arrowshape.turn.up.right"
                Image(systemName: image)
                
            })
            .disabled(!self.canGoForward)
            
        }
        
    }
    
}

#Preview {
    
    GPWebView(
        title: "Google",
        url: "https://google.com"
    )
    
}

internal struct WebView: UIViewRepresentable {
    
    public typealias UIViewType = WKWebView
    
    private var url: URL?
    private var webView: WKWebView?
    
    @Binding private var isLoading: Bool
    @Binding private var progress: Double
    @Binding private var canGoBack: Bool
    @Binding private var canGoForward: Bool
        
    public init(url: String,
                webView: WKWebView,
                isLoading: Binding<Bool>,
                progress: Binding<Double>,
                canGoBack: Binding<Bool>,
                canGoForward: Binding<Bool>) {
        
        self.url = URL(string: url)
        self.webView = webView
        
        self._isLoading = isLoading
        self._progress = progress
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        
        self.webView?.navigationDelegate = context.coordinator
        self.webView?.allowsBackForwardNavigationGestures = true
        self.webView?.configuration.allowsInlineMediaPlayback = true
        
        if let url  {
            
            let request = URLRequest(url: url)
            self.webView?.load(request)
            
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        return self.webView!
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self, isLoading: self.$isLoading)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        
        var parent: WebView
        @Binding var isLoading: Bool
        
        public init(_ parent: WebView,
                    isLoading: Binding<Bool>) {
            
            self._isLoading = isLoading
            self.parent = parent
            
        }
        
        public func webView(_ webView: WKWebView,
                            didStartProvisionalNavigation navigation: WKNavigation!) {
            
            self.isLoading = true
            
        }
        
        public func webView(_ webView: WKWebView,
                            didFinish navigation: WKNavigation!) {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
            }
            
            self.parent.canGoBack = webView.canGoBack
            self.parent.canGoForward = webView.canGoForward
            
            self.parent.progress = 1.0
            
        }
        
        public func webView(_ webView: WKWebView,
                            didCommit navigation: WKNavigation!) {
            
            self.parent.progress = Double(webView.estimatedProgress)
            
        }
        
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {}
    
}
