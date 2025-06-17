//
//  BeforeAndAfter.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/15/25.
//

import SwiftUI

public struct CompareSliderView<BeforeContent: View, AfterContent: View>: View {
    
    private let beforeContent: BeforeContent
    private let afterContent: AfterContent
    
    @State private var sliderPosition: CGFloat
    @State private var isDragging: Bool = false
        
    public init(initialSliderPosition: CGFloat = 0.5,
                @ViewBuilder beforeContent: () -> BeforeContent,
                @ViewBuilder afterContent: () -> AfterContent) {
        
        self.sliderPosition = initialSliderPosition
        self.beforeContent = beforeContent()
        self.afterContent = afterContent()
        
    }
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            let size = geometry.size
            content(size: size)
            
        }
        
    }
    
    private func content(size: CGSize) -> some View {
        
        ZStack {
            
            afterView(size: size)
            beforeView(size: size)
            sliderControls(size: size)
            
        }
        .frame(
            width: size.width,
            height: size.height
        )
        .clipped()
        .contentShape(.rect)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    
                    self.isDragging = true
                    let pos = value.location.x / size.width
                    self.sliderPosition = min(max(pos, 0), 1)
                    
                }
                .onEnded { _ in
                    self.isDragging = false
                }
        )
        .onTapGesture { location in
            
            let pos = location.x / size.width
            
            withAnimation(.spring()) {
                self.sliderPosition = min(max(pos, 0), 1)
            }
            
        }
        
    }
    
    private func afterView(size: CGSize) -> some View {
        
        self.afterContent
            .frame(
                width: size.width,
                height: size.height
            )
            .clipped()
        
    }
    
    private func beforeView(size: CGSize) -> some View {
        
        self.beforeContent
            .frame(
                width: size.width,
                height: size.height
            )
            .clipped()
            .mask(
                Rectangle()
                    .frame(width: self.sliderPosition * size.width)
                    .alignmentGuide(.leading, computeValue: { _ in 0 })
                    .position(
                        x: self.sliderPosition * (size.width / 2),
                        y: size.height / 2
                    )
            )
        
    }
    
    private func sliderControls(size: CGSize) -> some View {
        
        SliderControl(
            position: self.sliderPosition,
            isDragging: self.isDragging
        )
        .frame(height: size.height)
        .offset(x: (self.sliderPosition - 0.5) * size.width * 1)
        
    }
    
}

#Preview {
    
    CompareSliderView {
        
        Rectangle()
            .fill(.red.gradient)
            .overlay(
                Text("BEFORE")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            )
        
    } afterContent: {
        
        Rectangle()
            .fill(.blue.gradient)
            .overlay(
                Text("AFTER")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            )
        
    }
    .ignoresSafeArea()
    
}

#Preview {
    
    @Previewable @State var sliderPosition: CGFloat = 0.1
    
    CompareSliderView(initialSliderPosition: sliderPosition) {
        
        Image(.image3)
            .resizable()
            .aspectRatio(contentMode: .fill)
        
    } afterContent: {
        
        Image(.image4)
            .resizable()
            .aspectRatio(contentMode: .fill)
        
    }
    .frame(
        width: 300,
        height: 300
    )
    .clipShape(.rect(cornerRadius: 32))
    .ignoresSafeArea()
    
}

fileprivate struct SliderControl: View {
    
    private let position: CGFloat
    private let isDragging: Bool
    
    public init(position: CGFloat,
                isDragging: Bool) {
        
        self.position = position
        self.isDragging = isDragging
        
    }
    
    public var body: some View {
        
        ZStack {
            
            // Vertical Line
            Rectangle()
                .fill(.white)
                .frame(width: 3)
                .shadow(radius: 2)
            
            // Handle
            Circle()
                .fill(.white)
                .frame(
                    width: self.isDragging ? 50 : 40,
                    height: self.isDragging ? 50 : 40
                )
                .shadow(radius: 3)
                .animation(
                    .spring(response: 0.2),
                    value: self.isDragging
                )
            
            // Drag Indicators
            HStack(spacing: 1) {
                
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                
            }
            .font(.system(size: 14, weight: .bold))
            .opacity(self.isDragging ? 0.5 : 1)
            .scaleEffect(self.isDragging ? 1.2 : 1)
            
        }
        .animation(
            .spring(response: 0.2),
            value: self.isDragging
        )
        .compositingGroup()
        
    }
    
}
