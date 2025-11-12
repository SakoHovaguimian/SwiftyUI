//
//  SwiftyUIApp.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

final class AlwaysOnTopWindowManager {
    
    static let shared = AlwaysOnTopWindowManager()
    
    private var window: PassthroughWindow?
    
    func show<Content: View>(_ view: Content) {
        
        // If we already have a window, just update its content.
        if let window {
            
            if let hosting = window.rootViewController as? UIHostingController<AnyView> {
                hosting.rootView = AnyView(view)
            } else {
                window.rootViewController = UIHostingController(rootView: AnyView(view))
            }
            
            window.isHidden = false
            window.windowLevel = .alert + 1
            return
            
        }
        
        // Grab *any* UIWindowScene instead of requiring .foregroundActive
        guard let scene = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first
        else {
            return
        }
        
        let window = PassthroughWindow(windowScene: scene)
        let hosting = UIHostingController(rootView: AnyView(view))
        
        hosting.view.backgroundColor = .clear
        
        window.rootViewController = hosting
        window.windowLevel = .alert + 1     // stays above fullScreenCover
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = true
        
        window.makeKeyAndVisible()          // <- important
        
        self.window = window
    }
    
    func hide() {
        
        self.window?.isHidden = true
        self.window = nil
        
    }
}

fileprivate class PassthroughWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
        
    }
    
}

@main
struct MyApp2: App {
    
    @State private var shouldShow: Bool = true
    
    var body: some Scene {
        
        WindowGroup {
            
            DrawingView()
            
        }
        
    }
    
    private var overlayView: some View {
        
        Text("🚀 OVER EVERYTHING")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .padding()
            .background(
                Color.black.opacity(0.7)
            )
            .cornerRadius(12)
            .padding(.top, 60)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .allowsHitTesting(false)   // so it doesn’t block taps below, if you want
        
    }
}

//@main
//struct MyApp2: App {
//    
//    @State var shouldShow: Bool = true
// 
//    var body: some Scene {
//        
//        WindowGroup {
//            
//            ZStack {
//                
//                Color.green.ignoresSafeArea()
//                
//                Color.red.ignoresSafeArea()
//                    .fullScreenCover(isPresented: $shouldShow) {
//                        
//                        Color.blue.ignoresSafeArea()
//                            .onTapGesture {
//                                shouldShow = false
//                            }
//                        
//                    }
//                
//                Color.yellow.ignoresSafeArea()
//                
//            }
//            .overlay {
//                
//                Text("SOME TEST")
//                    .foregroundStyle(.white)
//                    .font(.largeTitle)
//                
//            }
//            
////            ScrollBannerViewPreview()
//            
////            StaggeredTestView()
////            SubscriptionView()
////            SomePreviewView()
////            SomePreviewView()
////            AccelerometerBallView()
//            
////            ScrollView {
////                
////                AccelerometerBallView()
////                    .padding(.top, 48)
////                
////                PieChartView(logChartData: [
////                    .init(logType: "Info", totalCount: 100),
////                    .init(logType: "Error", totalCount: 150),
////                    .init(logType: "Success", totalCount: 200),
////                    .init(logType: "Debug", totalCount: 250),
////                    .init(logType: "Fault", totalCount: 300),
////                ])
////                
////                LineChartView(logChartData: [
////                    .init(logType: "Info", totalCount: 100),
////                    .init(logType: "Error", totalCount: 150),
////                    .init(logType: "Success", totalCount: 200),
////                    .init(logType: "Debug", totalCount: 250),
////                    .init(logType: "Fault", totalCount: 300),
////                    .init(logType: "Info", totalCount: 500)
////                ])
////                
////                BarChartView(logChartData: [
////                    .init(logType: "Info", totalCount: 100),
////                    .init(logType: "Error", totalCount: 150),
////                    .init(logType: "Success", totalCount: 200),
////                    .init(logType: "Debug", totalCount: 250),
////                    .init(logType: "Fault", totalCount: 300),
////                    .init(logType: "Info", totalCount: 500)
////                ])
////                
////            }
//            
//        }
//        
//    }
//    
//}

//@main
//struct SwiftyUIApp: App {
//    
//    private let appAssembler: AppAssembler = AppAssembler()
//    
//    private let demoViewModel: DemoViewModel
//    
//    init() {
//        
//        self.demoViewModel = self.appAssembler
//            .resolver
//            .resolve(DemoViewModel.self)!
//            .setup()
//        
//    }
//    
//    var body: some Scene {
//        
//        WindowGroup {
//            DemoView(viewModel: demoViewModel)
//        }
//        
//    }
//    
//}

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
