//
//  AppSegmentedControl.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/8/25.
//

import SwiftUI

struct CommonSegmentedControl<S: Selectable>: View {
    
    @Namespace private var selectionNamespace
    @Binding var selectedOption: S?
    var options: [S]
    
    var body: some View {
        
        Group {
        
            HStack(spacing: 0) {
                
                ForEach(options) { option in
                    
                    let isSelected = (self.selectedOption == option)
                    
                    Button(action: {
                        
                        withAnimation(.spring) {
                            self.selectedOption = option
                        }
                        
                    }, label: {
                        
                        Text(option.description)
                            .font(.body)
                            .fontWeight(.semibold)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(isSelected ? .white : .black)
                        
                    })
                    .background {
                        
                        if isSelected {
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue)
                                .padding(.vertical, 6)
                                .matchedGeometryEffect(id: "selection", in: self.selectionNamespace)
                            
                        }
                        
                    }
                    
                }
                
            }
            .padding(.horizontal, 4)
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .white))
        )
        .shadow(radius: 8)
        
    }
    
}

fileprivate struct AppSegmentedControlTest: View {
    
    enum Pokemon: Selectable, CaseIterable {
        
        case charmander
        case bulbasaur
        
        var description: String {
            switch self {
            case .charmander: return "Charmander"
            case .bulbasaur: return "Bulbasaur"
            }
        }
        
        var id: String {
            return self.description
        }
        
    }
    
    @State private var selectedPokemon: Pokemon?
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                CommonSegmentedControl(
                    selectedOption: self.$selectedPokemon,
                    options: Pokemon.allCases
                )
                
                Text("Seleted Pokemon: \(selectedPokemon?.description ?? "NO POKEMON")")
                    .contentTransition(.numericText())
                    .padding(.top, 24)
                
            }
            .padding(.horizontal, 16)
            .onAppear {
                self.selectedPokemon = Pokemon.charmander
            }
            
        }
        
    }
    
}

#Preview {
    
    AppSegmentedControlTest()
    
}

fileprivate struct AppSegmentedControlTest2: View {
    
    enum LoanType: Selectable, CaseIterable {
        
        case debt
        case creditCard
        case mortgage
        
        var description: String {
            switch self {
            case .debt: return "Debt"
            case .creditCard: return "Credit Card"
            case .mortgage: return "Mortgage"
            }
        }
        
        var id: String {
            return self.description
        }
        
    }
    
    @State private var selectedLoanType: LoanType?
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                CommonSegmentedControl(
                    selectedOption: self.$selectedLoanType,
                    options: LoanType.allCases
                )
                
                Text("Seleted Loan Type: \(selectedLoanType?.description ?? "NO LOAN TYPE")")
                    .contentTransition(.numericText())
                    .padding(.top, 24)
                
            }
            .padding(.horizontal, 16)
            .onAppear {
                self.selectedLoanType = .creditCard
            }
            
        }
        
    }
    
}

#Preview {
    
    AppSegmentedControlTest2()
    
}
