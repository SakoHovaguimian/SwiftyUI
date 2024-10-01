//
//  Test.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/9/24.
//

import SwiftUI

enum Route {
    
    case one
    case two
    case three
    
}

class TestViewModel2: ObservableObject {
    
    var title: String
    
    init(title: String) {
        self.title = title
        print("CREATED: \(title)")
    }
    
    func myPrint() {
        print("PRINTING FOR FUNSIES")
    }
    
    func set(title: String) {
        
        Task {
            
            self.title = title
            print("UPDATING VIEW MODEL TITLE IN TASK BLOCK")
            
        }
        
    }
    
}

struct TestView: View {
    
    @State private var path: [Route] = []
    
    var body: some View {
        
        NavigationStack(path: self.$path) {
            
            Color.green.ignoresSafeArea()
            
                .overlay(content: {
                    
                    VStack {
                        
                        Button {
                            self.path.append(.one)
                        } label: {
                            Text("ONE")
                        }
                        
                        Button {
                            self.path.append(.two)
                        } label: {
                            Text("TWO")
                        }
                        
                        Button {
                            self.path.append(.three)
                        } label: {
                            Text("THREE")
                        }

                        
                    }
                    
                })
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .one: ViewModelView(viewModel: .init(title: "One"))
                    case .two: ViewModelView(viewModel: .init(title: "Two"))
                    case .three: ViewModelView(viewModel: .init(title: "Three"))
                    }
                }
            
        }
        
    }
    
}

struct ViewModelView: View {
    
    @StateObject var viewModel: TestViewModel2
    
    init(viewModel: TestViewModel2) {
        
        let saf = viewModel
        self._viewModel = .init(wrappedValue: saf)
    }
    
    var body: some View {
        Text(viewModel.title)
    }
    
}

#Preview {
    
    TestView()
    
}
