//
//  DashProgressView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/27/24.
//

import SwiftUI

struct DashProgressView: View {
    
    @State private var totalWidth: CGFloat = 0
    
    var foregroundColor: Color = .green
    var progress: CGFloat = 0.5
    var dashWidth: CGFloat = 8
    var dashSpacing: CGFloat = 2
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("\(Int(self.progress * 100))%")
                .bold()
                .contentTransition(.numericText())
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 4)
                    .stroke(lineWidth: 2)
                    .frame(width: self.totalWidth + 8, height: 20)
                
                HStack(spacing: self.dashSpacing) {
                    
                    let numberOfDashes = Int((self.progress * self.totalWidth) / (self.dashWidth + self.dashSpacing))
                    let filledWidth = CGFloat(numberOfDashes) * (self.dashWidth + self.dashSpacing) - self.dashSpacing
                    let remainingWidth = (self.progress * self.totalWidth) - filledWidth
                    
                    ForEach(0..<numberOfDashes, id: \.self) { int in
                        
                        Rectangle()
                            .frame(
                                width: self.dashWidth,
                                height: 15
                            )
                            .foregroundStyle(self.foregroundColor)
                            .transition(.opacity.animation(.spring().delay(Double(int) * 0.04)))
                        
                        if remainingWidth > 0 && int == (numberOfDashes - 1) && self.progress >= 1 {
                            
                            Rectangle()
                                .frame(
                                    width: remainingWidth,
                                    height: 15
                                )
                                .foregroundStyle(self.foregroundColor)
                                .transition(.opacity.animation(
                                    .spring().delay(Double(int + 1) * 0.04))
                                )
                            
                        }
                        
                    }
                    
                }
                .frame(maxWidth: self.totalWidth, alignment: .leading)
                .padding(.horizontal, self.dashSpacing + 1)
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .background(GeometryReader { geometry in
            Color.clear.onAppear {
                self.totalWidth = geometry.size.width
            }
        })
        
    }
    
}

private struct DashParentView: View {
    
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        
        let _ = Self._printChanges()
        
        AppCardView {
            
            DashProgressView(
                progress: self.progress
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    withAnimation(.spring) {
                        self.progress = 1
                    }
                })
            }
            
        }
        .padding(.horizontal, .large)
        
    }
    
}

#Preview {
    
    DashProgressView(
        progress: 1
    )
    .padding(.horizontal, .large)
    
}

#Preview {
    
    DashParentView()
    
}
