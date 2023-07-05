//
//  CombineInputView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/5/23.
//

import Combine
import SwiftUI

class CombineInputViewModel: ObservableObject {
    
    @Published var input = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $input
            .debounce(
                for: 1,
                scheduler: DispatchQueue.main
            )
            .filter({ $0.count >= 3 })
            .removeDuplicates()
            .sink { value in
                self.search(text: value)
            }
            .store(in: &cancellables)
    }
    
    private func search(text: String) {
        print("*** Searching \(text) ***")
    }
}

struct CombineInputView: View {
    
    @StateObject var viewModel = CombineInputViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                TextField(
                    "Search",
                    text: self.$viewModel.input
                )
                .textFieldStyle(.roundedBorder)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Debouncer Demo")
            
        }
        
    }
}

#Preview {
    CombineInputView(viewModel: CombineInputViewModel())
}
