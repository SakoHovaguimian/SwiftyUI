//
//  AlwaysOnTop.swift
//  Rune
//
//  Created by Sako Hovaguimian on 11/29/25.
//

import SwiftUI
import UIKit

@MainActor
public enum OverlayChannel: Hashable {
    
    case toast
    case alert
    case custom(String)
    
    var windowLevel: UIWindow.Level {
        switch self {
        case .toast:
            
            // Below alerts, above normal app content
            return .alert + 1
            
        case .alert:
            
            // On top of everything
            return .alert + 2
            
        case .custom:
            
            // Reasonable default for extra overlays
            return .statusBar + 1
        }
        
    }
    
}

@MainActor
final public class AlwaysOnTopWindowManager {
    
    public static let shared = AlwaysOnTopWindowManager()
    
    private var windows: [OverlayChannel: PassThroughWindow] = [:]
    private var pending: [OverlayChannel: () -> AnyView] = [:]
    
    private init() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public API
    
    public func show<Content: View>(
        _ channel: OverlayChannel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        
        let anyContent: () -> AnyView = {
            AnyView(content())
        }
        
        guard let scene = self.bestWindowScene() else {
            
            /// Scene not ready yet (common at root)
            self.pending[channel] = anyContent
            
            return
        }
        
        self.pending[channel] = nil
        
        self.show(
            channel,
            in: scene,
            content: anyContent
        )
        
    }
    
    public func hide(_ channel: OverlayChannel) {
        
        guard let window = self.windows[channel] else { return }
        
        window.isHidden = true
        window.rootViewController = nil
        
        self.windows[channel] = nil
        self.pending[channel] = nil
        
    }
    
    public func hideAll() {
        
        self.windows.values.forEach {
            
            $0.isHidden = true
            $0.rootViewController = nil
            
        }
        
        self.windows.removeAll()
        self.pending.removeAll()
        
    }
    
    // MARK: - Private
    
    @objc
    private func handleDidBecomeActive() {
        
        guard !self.pending.isEmpty else { return }
        guard let scene = self.bestWindowScene() else { return }
        
        let queued = self.pending
        self.pending.removeAll()
        
        for (channel, content) in queued {
            
            self.show(
                channel,
                in: scene,
                content: content
            )
            
        }
        
    }
    
    private func show(
        _ channel: OverlayChannel,
        in scene: UIWindowScene,
        content: @escaping () -> AnyView
    ) {
        
        /// Reuse window if possible
        if let window = self.windows[channel],
           let hosting = window.rootViewController as? UIHostingController<AnyView> {
            
            hosting.rootView = content()
            
            window.windowLevel = channel.windowLevel
            window.isHidden = false
            
            self.syncFrame(of: window, to: scene)
            
            return
        }
        
        let window = PassThroughWindow(windowScene: scene)
        let hosting = UIHostingController(rootView: content())
        
        hosting.view.backgroundColor = .clear
        
        window.rootViewController = hosting
        window.backgroundColor = .clear
        window.windowLevel = channel.windowLevel
        window.isHidden = false
        
        self.syncFrame(of: window, to: scene)
        
        self.windows[channel] = window
        
    }
    
    private func syncFrame(of window: UIWindow, to scene: UIWindowScene) {
        
        if let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) {
            
            window.frame = keyWindow.bounds
            
        } else {
            
            window.frame = scene.screen.bounds
            
        }
        
    }
    
    private func bestWindowScene() -> UIWindowScene? {
        
        let scenes = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
        
        /// Prefer foregroundActive, but fall back to foregroundInactive (launch / transitions)
        if let active = scenes.first(where: { $0.activationState == .foregroundActive }) {
            return active
        }
        
        if let inactive = scenes.first(where: { $0.activationState == .foregroundInactive }) {
            return inactive
        }
        
        return scenes.first
        
    }
    
}

import UIKit

public class PassThroughWindow: UIWindow {
    
    public override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        
        guard let hitView = super.hitTest(point, with: event),
              let rootView = rootViewController?.view else {
            
            return nil
            
        }
        
        if #available(iOS 26, *) {
            
            if rootView.layer.hitTest(point)?.name == nil {
                return rootView
            }
            
            return nil
            
        } else {
            
            if #unavailable(iOS 18) {
                
                /// Less than iOS 18
                return hitView == rootView ? nil : hitView
                
            } else {
                
                /// iOS 18 to less than iOS 26
                for subview in rootView.subviews.reversed() {
                    
                    /// Finding if any of rootview's subview is receving hit test
                    let pointInSubView = subview.convert(point, from: rootView)
                    if subview.hitTest(pointInSubView, with: event) != nil {
                        return hitView
                    }
                    
                }
                
                return nil
                
            }
            
        }
        
    }
    
}

@main
struct SwiftyUIApp: App {
    
//    private let appAssembler: AppAssembler = AppAssembler()
    
//    private let demoViewModel: DemoViewModel
    
    init() {
//
//        self.demoViewModel = self.appAssembler
//            .resolver
//            .resolve(DemoViewModel.self)!
//            .setup()
        
    }
    
    var body: some Scene {
        
        WindowGroup {
//            let url: URL  = .init(string: "https://fastly.picsum.photos/id/237/1080/1920.jpg?hmac=M8JWQ-aKjdPJk7LsPrXgN_XlxgxXsm1Pr-_WEr6obYU")!
//            let url = Bundle.main.url(forResource: "Sample", withExtension: "pdf")!
//
//            return PDFPencilKitEditorView(
//                initialPDFURL: url,
//                outputFileName: "MyEdited.pdf",
//                showsBuiltInControls: true
//            )
//            .ignoresSafeArea()
//            CleanPDFContainer()
//            ImageDrawingView(imageURL: url)
//            GlowProDashboardView()
//            DemoWheelSpin()
//                .preferredColorScheme(.light)
//                .colorScheme(.light)
//                .toolbarColorScheme(.light, for: .automatic)
            
//            DynamicIslandAlwaysOnTop()
            
            ComponentsPreview()
        }
        
    }
    
}

struct DemoView: View {
    
    @StateObject var viewModel: DemoViewModel
    
    @State private var textfieldTitle: String = ""
    
    var body: some View {
        
        title
        
    }
    
    private var title: some View {
        
        Text(self.viewModel.title)
            .contentTransition(.numericText(countsDown: true))
            .padding(.xLarge)
            .frame(
                width: 100,
                height: 100
            )
            .background(self.viewModel.bakgroundColor)
            .clipShape(.rect(cornerRadius: .appMedium))
            .appOnTapGesture {
                self.viewModel.set(environment: AppEnvironment.allCases.randomElement()!)
            }
            .animation(.spring, value: self.viewModel.title)
        
    }
    
}
