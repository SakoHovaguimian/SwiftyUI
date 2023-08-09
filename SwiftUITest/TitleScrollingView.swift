//
//  TitleScrollingView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 8/8/23.
//

import SwiftUI

struct TitleScrollingView: View {
    
    @State private var scrollViewOffset: CGPoint = .zero
    @State private var isInCollpasedState: Bool = false
    
    var body: some View {
        
        ZStack {
            
            let _ = print(self.scrollViewOffset)
            
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                HStack {
                    
                    CircularIconView(
                        foregroundColor: .white,
                        backgroundColor: .green,
                        size: isInCollpasedState ? 32 : 40,
                        systemImage: "bell.fill"
                    )
                    
                    Text("TESTING TITLE")
                        .font(isInCollpasedState ? .title2 : .largeTitle)
                        .foregroundStyle(.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
    //                    .background(.clear)
                    
                    Spacer()
                    
                    CircularIconView(
                        foregroundColor: .white,
                        backgroundColor: .green,
                        size: isInCollpasedState ? 32 : 0,
                        systemImage: "bell.fill"
                    )
                    .offset(x: isInCollpasedState ? 0 : 400)
                    
                    CircularIconView(
                        foregroundColor: .white,
                        backgroundColor: .green,
                        size: isInCollpasedState ? 32 : 0,
                        systemImage: "bell.fill"
                    )
                    .offset(x: isInCollpasedState ? 0 : 400)
                    
//                    CircularIconView(
//                        foregroundColor: .white,
//                        backgroundColor: .green,
//                        size: isInCollpasedState ? 32 : 40,
//                        systemImage: "bell.fill"
//                    )
//                    .offset(x: isInCollpasedState ? 0 : 300)
                    
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.black)
                .offset(y: isInCollpasedState ? -20 : (scrollViewOffset.y > 0 ? -scrollViewOffset.y : 0))
                .shadow(color: .black.opacity(0.3), radius: 4, y: 4)
                
                Spacer()
                
            }
            .zIndex(1)
                
                OffsetObservingScrollView(
                    axes: .vertical,
                    showsIndicators: false,
                    offset: self.$scrollViewOffset
                ) {
                    VStack(spacing: 16) {
                        
                        ForEach(0..<100) { _ in
                            
                            RoundedRectangle(cornerRadius: 11)
                                .fill(Color.teal.opacity(0.8))
                                .frame(width: UIScreen.main.bounds.width - 48, height: 100)
                                .tint(Color.purple)
                        }
                        
                    }
                    .offset(y: 120)
                }
            //            }
//            .background(.pink)
            
        }
        
        .onChange(of: self.scrollViewOffset) { _, _ in
            withAnimation(.smooth(duration: 0.2)) {
                self.isInCollpasedState = (self.scrollViewOffset.y >= 20)
            }
        }
        
        
    }
    
}

#Preview {
    TitleScrollingView()
}
