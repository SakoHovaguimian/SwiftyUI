//
//  CombineInputView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/5/23.
//

import Combine
import SwiftUI

//class CombineInputViewModel: ObservableObject {
//    
//    @Published var input = ""
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        setupBindings()
//    }
//    
//    private func setupBindings() {
//        $input
//            .debounce(
//                for: 1,
//                scheduler: DispatchQueue.main
//            )
//            .filter({ $0.count >= 3 })
//            .removeDuplicates()
//            .sink { value in
//                self.search(text: value)
//            }
//            .store(in: &cancellables)
//    }
//    
//    private func search(text: String) {
//        print("*** Searching \(text) ***")
//    }
//}

struct CustomObservorTextFieldView: View {
    
    @State var debouncedText = ""
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                TextFieldWithDebounce(debouncedText: self.$debouncedText)
                Text(self.debouncedText)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Debouncer Demo")
            
        }
        
    }
    
}

class TextFieldObserver : ObservableObject {
    
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        
        self.$searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            } )
            .store(in: &self.subscriptions)
    }
    
}

struct TextFieldWithDebounce : View {
    
    @Binding var debouncedText : String
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
    
        VStack {
            TextField("Enter Something", text: $textObserver.searchText)
                .frame(height: 30)
                .padding(.leading, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .padding(.horizontal, 20)
        }.onReceive(self.textObserver.$debouncedText) { (val) in
            self.debouncedText = val
        }
    }
    
}

#Preview {
    CustomObservorTextFieldView(debouncedText: "")
}
