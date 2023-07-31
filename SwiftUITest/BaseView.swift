//
//  BaseView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/30/23.
//

import SwiftUI

struct HoldButtonView: View {
    
    private var duration: CGFloat
    
    @GestureState private var isLongPressing = false
    @State private var press: Bool = false
    @State private var successAction: () -> ()
    
    init(duration: CGFloat,
         successAction: @escaping () -> Void) {
        
        self.duration = duration
        self.successAction = successAction
        
    }
    
    var body: some View {
        
        ZStack {
  
            // Other Optins, replace the first two with these to test...
//            Text("Start")
//                .opacity(self.press ? 0 : 1)
////                .opacity(self.isLongPressing ? 0 : 1)
//                .scaleEffect(self.press ? 0 : 1)
            
//            Image(systemName: "heart.fill")
//                .clipShape (Rectangle() .offset (y: self.isLongPressing ? 0 : 50))
//                .opacity(self.press ? 0 : 1)
//                .scaleEffect(self.press ? 0 : 1)
//                .animation(.easeInOut, value: self.isLongPressing)
            
            Image(systemName: "heart")
                .opacity(self.press ? 0 : 1)
                .scaleEffect(self.press ? 0 : 1)
            
            Image(systemName: "heart.fill")
                .clipShape (Rectangle() .offset (y: self.isLongPressing ? 0 : 50))
                .opacity(self.press ? 0 : 1)
                .scaleEffect(self.press ? 0 : 1)
                .animation(.easeInOut, value: self.isLongPressing)
            
            Image(systemName: "checkmark.circle.fill")
                .animation(.easeInOut)
                .foregroundStyle(.green.opacity(0.3))
                .opacity(self.press ? 1 : 0)
                .scaleEffect(self.press ? 1 : 0)
            
        }
        .frame(maxWidth: .infinity, minHeight: 50)
        .background(AppColor.brandGreen)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(content: {
            
            GeometryReader { proxy in
             
                Capsule()
                    .trim(from: self.isLongPressing ? 0.001 : 1, to: 1)
                    .stroke(AppColor.brandPink, style: StrokeStyle(lineWidth: 5, lineCap: .round))
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
            
            LongPressGesture(minimumDuration: self.duration)
            
                .updating(
                    self.$isLongPressing,
                    body: { currentState, gestureState, transaction in
                        
                        gestureState = currentState
                        
                    })
            
                .onEnded { value in
                    
                    
                    self.press.toggle()
                    self.successAction()
                    
                }
        )
        
    }
    
}

struct TestBaseView: View {
    
    var body: some View {
        
        // NOTE: Check what aligning should be for this zstack that app base view has inside of the class
        
        AppBaseView {
            
            AppColor.charcoal
                .ignoresSafeArea()
            
            AppCardView {
                
                VStack {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 50)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 200)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 50)
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 50)
                    
                    HoldButtonView(
                        duration: 2) {
                            print("DID WORK")
                        }
                    
                    
                    Button("Random Button") {
                        // Ignore
                    }
                    .buttonStyle(AppButtonStyle())
                    .padding(.horizontal, .medium)
                    
                }
                .padding(.horizontal, .large)
                
                //            .frame(height: 100)
                
                //                VStack {
                //                    
                //                    Color.pink
                //                        .frame(width: 300, height: 400)
                //                        .background(Color.pink)
                //                        .cornerRadius(20)
                //                        .appShadow()
                //                    
                //                    Button(action: {
                //                        print("Working")
                //                    }, label: {
                //                        Text("Submit")
                //                            .appFont(with: .heading(.h5))
                //                            .frame(maxWidth: .infinity)
                //                            .padding(.vertical, 16)
                //                    })
                //                    .buttonStyle(AppButtonStyle())
                //                    .padding([.top, .horizontal], 48)
                //                    
                ////                    .foregroundStyle(.black)
                ////                    .background(AppColor.brandGreen)
                ////                    .clipShape(.rect(cornerRadius: 11))
                ////                    .appShadow()
                ////                    .padding(.horizontal, 48)
                //                    
                //                }
                
                
            }
            .padding(.horizontal, 48)
            
        }
        
    }
    
}

#Preview {
    TestBaseView()
}


// Fun thing
private func textContainerView(_ copy: String) -> some View {
    VStack {
        HStack {
            Text(copy)
                .multilineTextAlignment(.leading)
                .foregroundColor(.gray)
                .font(.body)
                .padding(.all, 16)
            Spacer()
        }
    }
    .background(Color.white)
    .cornerRadius(12)
}

