//
//  SwiftyUIApp.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

@main
struct MyApp: App {
    
    @State var items: [VerticalTimelineView.Item] = [
        .init(title: "First Item", duration: 1),
        .init(title: "Second Item", duration: 1),
        .init(title: "Third Item", duration: 1),
        .init(title: "Fourth Item", duration: 1),
        .init(title: "Fifth Item", duration: 1),
    ]
    
    var body: some Scene {
        WindowGroup {
//            VerticalTimelineView(items: items, activeColor: .darkPurple)
//                .frame(width: 350, height: 500)
            iOSStrechyHeader()
        }
    }
    
//        var body: some Scene {
//            WindowGroup {
//                ItemListView()
//            }
//        }
    
}

//@main
struct SwiftyUIApp: App {
    
    private let appAssembler: AppAssembler = AppAssembler()
    
    private let demoViewModel: DemoViewModel
    
    init() {
        
        self.demoViewModel = self.appAssembler
            .resolver
            .resolve(DemoViewModel.self)!
            .setup()
        
    }
    
    var body: some Scene {
        
        WindowGroup {
            DemoView(viewModel: demoViewModel)
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
