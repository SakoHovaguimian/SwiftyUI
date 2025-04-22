//
//  HeightPicker.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 11/25/23.
//

import SwiftUI

struct HeightPickerTestView: View {
    
    @State var selectedFeet: Int = 0
    @State var selectedInches: Int = 0

    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Your Height")
                .font(.title3)
                .fontWeight(.bold)
            
            HeightPickerView(
                selectedFeet: self.$selectedFeet,
                selectedInches: self.$selectedInches
            )
            
        }
        
    }
    
}

struct HeightPickerView: View {
    
    @Binding var selectedFeet: Int
    @Binding var selectedInches: Int
    
    let feet = [1,2,3,4,5,6,7,8]
    let inches = [1,2,3,4,5,6,7,8,9,10,11]
        
    var body: some View {
        
        HStack(spacing: 8) {
            
            HeightPickerItemView(
                selected: self.$selectedFeet,
                context: .feet,
                options: self.feet.reversed()
            )
            
            HeightPickerItemView(
                selected: self.$selectedInches,
                context: .inches,
                options: self.inches.reversed()
            )
            
        }
        
    }
}

fileprivate
struct HeightPickerItemView: View {
    
    enum Context: String {
        
        case feet
        case inches
        
        var abbreviation: String {
            switch self {
            case .feet: return "ft"
            case .inches: return "in"
            }
        }
        
    }
    
    @Binding var selected: Int
    var context: Context
    var options: [Int]
    
    var body: some View {
        
        let isSelected = (self.selected != 0)
        
        Menu {
            
            Picker(selection: self.$selected,
                   label: EmptyView()) {
                
                ForEach(self.options, id: \.self) { option in
                    
                    Text("\(option)")
                        .tag("\(option)")
                    
                }
                
            }
            
        } label: {
            
            let abbreviation = self.context.abbreviation
            let text = isSelected ? "\(self.selected) \(abbreviation)": "0 \(abbreviation)"
            
            Text(text)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(ThemeManager.shared.background(.quad))
                .cornerRadius(10)
                .foregroundStyle(.brandGreen)
            
        }
        .frame(maxWidth: 100)
        
    }
    
}

#Preview {
    HeightPickerTestView()
}

#Preview {
    
    @State var selectedFeet: Int = 0
    @State var selectedInches: Int = 0
    
    return HeightPickerView(
        selectedFeet: $selectedFeet,
        selectedInches: $selectedInches
    )
    
}
