//
//  DatePickerView.swift
//  Rival
//
//  Created by Sako Hovaguimian on 10/26/23.
//

import SwiftUI

struct DatePickerView: View {
    
    let label: String
    let prompt: String
    
    @Binding var date: Date?
    @State var selectedDate: Date
    
    var body: some View {
        
        ZStack {
            
            HStack {
                
                Text(self.label)
                    .appFont(with: .title(.t6))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if self.date != nil {
                    
                    Button {
                        
                        self.date = nil
                        
                    } label: {
                        
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .tint(AppColor.brandRed.gradient)
                        
                    }
                    
                }
                
                ZStack {
                    
                    DatePicker(
                        self.label,
                        selection: self.$selectedDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .onChange(of: self.selectedDate) { oldDate, newDate in
                        self.date = newDate
                    }
                    .allowsHitTesting(true)
                    
                    if self.date == nil {
                        
                        Text(self.prompt)
                            .appFont(with: .title(.t6))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .allowsHitTesting(false)
                            .opacity(self.date == nil ? 1 : 0)
                            .frame(height: 35)
                            .padding(.horizontal, .small)
                            .background(
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColor.background(.quad))
                                    .allowsHitTesting(false)
                                
                            )
                            .multilineTextAlignment(.trailing)
                        
                    }
                    
                }
                
            }
        }
        
    }
    
}
