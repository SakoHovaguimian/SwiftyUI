//
//  CardFlipView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/9/23.
//

import SwiftUI

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)

            Image(systemName: "suit.club.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.red)

        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double

    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.7), lineWidth: 3)
                .frame(width: width, height: height)

            RoundedRectangle(cornerRadius: 20)
                .fill(.blue.opacity(0.2))
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)

            RoundedRectangle(cornerRadius: 20)
                .fill(.blue.opacity(0.7))
                .padding()
                .frame(width: width, height: height)

            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue.opacity(0.7), lineWidth: 3)
                .padding()
                .frame(width: width, height: height)

            Image(systemName: "seal.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue.opacity(0.7))

            Image(systemName: "seal")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.white)

            Image(systemName: "seal")
                .resizable()
                .frame(width: 150, height: 150)
                .foregroundColor(.blue.opacity(0.7))

        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))

    }
}

#Preview {
    FlipView()
}

struct FlipView: View {

    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = false
    
    let width: CGFloat = 200
    let height: CGFloat = 250
    let durationAndDelay: CGFloat = 0.3
    
    var body: some View {
        
        ZStack {
            
            CardFront(
                width: self.width,
                height: self.height,
                degree: self.$frontDegree
            )
            
            CardBack(
                width: self.width,
                height: self.height,
                degree: self.$backDegree
            )
            
        }.onTapGesture {
            flipCard()
        }
        
    }
    
    func flipCard () {
        
        self.isFlipped = !isFlipped
        
        if self.isFlipped {
            
            withAnimation(.linear(duration: self.durationAndDelay)) {
                self.backDegree = 90
            }
            withAnimation(.linear(duration: self.durationAndDelay).delay(self.durationAndDelay)){
                self.frontDegree = 0
            }
            
        } else {
            
            withAnimation(.linear(duration: self.durationAndDelay)) {
                self.frontDegree = -90
            }
            withAnimation(.linear(duration: self.durationAndDelay).delay(self.durationAndDelay)){
                self.backDegree = 0
            }
            
        }
        
    }
    
}


struct AppFlipView<Front: View, Back: View>: View {
    
    @State var isFlipped = false
    @State var backDegree: CGFloat
    @State var frontDegree: CGFloat
    
    private var front: Front
    private var back: Back
    private var duration: CGFloat = 0.3
    
    init(isFlipped: Bool = false,
         duration: CGFloat = 0.3,
         @ViewBuilder front: () -> Front,
         @ViewBuilder back: () -> Back) {
        
        self.duration = duration
        
        self.front = front()
        self.back = back()
        
        self._isFlipped = State(initialValue: isFlipped)
        
        let degrees = AppFlipView.calculateInitialDegrees(isFlipped: isFlipped)
        self._frontDegree = State(initialValue: degrees.front)
        self._backDegree = State(initialValue: degrees.back)
        
    }
    
    var body: some View {
        
        ZStack {
            
            back
                .rotation3DEffect(
                    Angle(degrees: backDegree),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            front
                .rotation3DEffect(
                    Angle(degrees: frontDegree),
                    axis: (x: 0, y: 1, z: 0)
                )
        
        }.appOnTapGesture {
            flipCard()
        }
        
    }
    
    func flipCard () {
        
        if self.isFlipped {
            
            withAnimation(.linear(duration: self.duration)) {
                self.backDegree = 90
            }
            withAnimation(.linear(duration: self.duration).delay(self.duration)){
                self.frontDegree = 0
            }
            
        } else {
            
            withAnimation(.linear(duration: self.duration)) {
                self.frontDegree = -90
            }
            withAnimation(.linear(duration: self.duration).delay(self.duration)){
                self.backDegree = 0
            }
            
        }
        
        self.isFlipped = !self.isFlipped
        
    }
    
    static func calculateInitialDegrees(isFlipped: Bool) -> (front: CGFloat, back: CGFloat) {
        
        if isFlipped {
            return (front: -90, back: 0)
        }
        else {
            return (front: 0, back: 90)
        }
        
    }
    
}

#Preview {
    
    AppFlipView() {
        
        AppCardView {
            
            Text("Front")
                .appFont(with: .title(.t6))
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
        
    } back: {
        
        AppCardView {
            
            Text("Back")
                .appFont(with: .title(.t6))
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
        
    }
    .padding(.horizontal, 32)
    
}
