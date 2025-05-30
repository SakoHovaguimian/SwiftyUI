//
//  HoldButtonView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 5/26/25.
//


import SwiftUI

struct HoldButtonView: View {
    
    private var title: String
    private var duration: CGFloat
    private var unselectedImage: Image
    private var selectedImage: Image
    private var backgroundColor: Color
    private var heldBackgroundColor: Color
    
    @GestureState private var isLongPressing = false
    @State private var press: Bool = false
    @State private var successAction: () -> ()
    
    init(title: String,
         duration: CGFloat,
         unselectedImage: Image,
         selectedImage: Image,
         backgroundColor: Color,
         heldBackgroundColor: Color,
         successAction: @escaping () -> Void) {
        
        self.title = title
        self.duration = duration
        self.unselectedImage = unselectedImage
        self.selectedImage = selectedImage
        self.backgroundColor = backgroundColor
        self.heldBackgroundColor = heldBackgroundColor
        self.successAction = successAction
        
    }
    
    var body: some View {
        
        ZStack {
            
            HStack {
                
                Text(self.title)
                    .appFont(with: .title(.t6))
                    .animation(.easeInOut, value: self.isLongPressing)
                
                ZStack {
                    
                    self.unselectedImage
//                        .opacity(self.press ? 0 : 1)
//                        .scaleEffect(self.press ? 0 : 1)
                    
                    self.selectedImage
                        .clipShape (Rectangle() .offset (y: self.isLongPressing ? 0 : 50))
//                        .opacity(self.press ? 0 : 1)
//                        .scaleEffect(self.press ? 0 : 1)
                        .animation(.easeInOut, value: self.isLongPressing)
                    
//                    Image(systemName: "checkmark.circle.fill")
//                        .animation(.easeInOut)
//                        .foregroundStyle(.green.opacity(0.3))
//                        .opacity(self.press ? 1 : 0)
//                        .scaleEffect(self.press ? 1 : 0)
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(self.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(content: {
            
            GeometryReader { proxy in
             
                Capsule()
                    .trim(from: self.isLongPressing ? 0.001 : 1, to: 1)
                    .stroke(self.heldBackgroundColor.gradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .rotationEffect(Angle(degrees: 90))
                    .rotation3DEffect(
                        Angle(degrees: 180),
                        axis: (x: 1, y: 1.0, z: 0.0)
                    )
                    .animation(self.isLongPressing ? .easeInOut(duration: self.duration) : .easeOut(duration: 0.3), value: self.isLongPressing)
                
            }
                
            
        })
        .simultaneousGesture(
            
            LongPressGesture(minimumDuration: self.duration, maximumDistance: 1000)
            
                .updating(
                    self.$isLongPressing,
                    body: { currentState, gestureState, transaction in
                        
                        Haptics.shared.vibrate(option: .error)
                        gestureState = currentState
                        
                    })
            
                .onEnded { value in
                    
                    
                    self.press.toggle()
                    self.successAction()
                    
                }
        )
        
    }
    
}

#Preview {
    
    HoldButtonView(
        title: "Press and see",
        duration: 4,
        unselectedImage: Image(systemName: "trash"),
        selectedImage: Image(systemName: "trash.fill"),
        backgroundColor: .red,
        heldBackgroundColor: .blue
    ) {
//        print("I held it")
    }
    .padding(.horizontal, .large)
    
}
