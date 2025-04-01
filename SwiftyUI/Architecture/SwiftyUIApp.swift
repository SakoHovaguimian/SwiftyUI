//
//  SwiftyUIApp.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

@main
struct MyApp2: App {
 
    var body: some Scene {
        
        WindowGroup {
            
//            ScrollBannerViewPreview()
            
            SubscriptionView()
//            SomePreviewView()
//            SomePreviewView()
//            AccelerometerBallView()
            
//            ScrollView {
//                
//                AccelerometerBallView()
//                    .padding(.top, 48)
//                
//                PieChartView(logChartData: [
//                    .init(logType: "Info", totalCount: 100),
//                    .init(logType: "Error", totalCount: 150),
//                    .init(logType: "Success", totalCount: 200),
//                    .init(logType: "Debug", totalCount: 250),
//                    .init(logType: "Fault", totalCount: 300),
//                ])
//                
//                LineChartView(logChartData: [
//                    .init(logType: "Info", totalCount: 100),
//                    .init(logType: "Error", totalCount: 150),
//                    .init(logType: "Success", totalCount: 200),
//                    .init(logType: "Debug", totalCount: 250),
//                    .init(logType: "Fault", totalCount: 300),
//                    .init(logType: "Info", totalCount: 500)
//                ])
//                
//                BarChartView(logChartData: [
//                    .init(logType: "Info", totalCount: 100),
//                    .init(logType: "Error", totalCount: 150),
//                    .init(logType: "Success", totalCount: 200),
//                    .init(logType: "Debug", totalCount: 250),
//                    .init(logType: "Fault", totalCount: 300),
//                    .init(logType: "Info", totalCount: 500)
//                ])
//                
//            }
            
        }
        
    }
    
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
