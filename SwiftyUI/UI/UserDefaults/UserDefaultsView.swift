//
//  UserDefaultsView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 3/17/25.
//

import Combine
import SwiftUI

enum Speacilzation: String, CaseIterable, Codable, UserDefaultsKeyProtocol {
    
    case warrior
    case wizard
    case assassin
    
}

@Observable
class UserDefaultsViewModel {
    
    private var defaults = UserDefaultsService()
    var specializationsDict: [Speacilzation: String] = [:]
    
//    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadValues()
    }
    
    func setValue(key speacilzation: Speacilzation,
                  value: String) {
        
        self.specializationsDict[speacilzation] = value
        
        self.defaults
            .set(
                key: speacilzation,
                value: value
            )
        
    }
    
    func loadValues() {
        
        var tempDict: [Speacilzation: String] = [:]
        
        Speacilzation.allCases
            .forEach { specialization in
                
                let fetchedValue: String = self.defaults.get(key: specialization) ?? "No Value"
                tempDict[specialization] = fetchedValue
                
            }
        
        self.specializationsDict = tempDict
        
    }
    
    // MARK: - YOU DON'T NEED THIS (BELOW) IF YOU ARE THE ONLY TRIGGER TO THESE PROPERTIES
    // UPDATING
    
//    private func bindSubscribers() {
//        
//        self.defaults
//            .objectWillChange
//            .sink { [weak self] in
//                self?.loadValues()
//            }
//            .store(in: &self.cancellables)
//        
//    }
    
}

struct UserDefaultsView: View {
    
    @State var viewModel: UserDefaultsViewModel
    
    var body: some View {
        
        List {
            
            ForEach(Array(self.viewModel.specializationsDict.keys), id: \.self) { speacilzation in
                specializationItem(forSpeacilzation: speacilzation)
            }
            
        }
        
    }
    
    private func specializationItem(forSpeacilzation speacilzation: Speacilzation) -> some View {
        
        HStack {
            
            Text(speacilzation.rawValue.capitalized)
            
            Spacer()
            
            Text(self.viewModel.specializationsDict[speacilzation] ?? "No Value")
                .contentTransition(.numericText())
            
        }
        .asButton {
            setNewValue(
                key: speacilzation,
                value: String(UUID().uuidString.prefix(8))
            )
        }
        
    }
    
    private func setNewValue(key: Speacilzation,
                             value: String) {
        
        withAnimation {
            
            self.viewModel.setValue(
                key: key,
                value: value
            )
            
        }
        
    }
    
}

#Preview {
    
    UserDefaultsView(
        viewModel: UserDefaultsViewModel()
    )
    
}
