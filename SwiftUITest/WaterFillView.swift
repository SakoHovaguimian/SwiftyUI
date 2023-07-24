//
//  WaterFillView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/24/23.
//

import SwiftUI

struct WaterFillView: View {
    
    @State private var percent = 0.0
    
    var body: some View {
        
        VStack {
            
            CircleWaveView(
                percent: Int(self.percent),
                imageName: "drop.fill"
            )
            
            CircleWaveView(
                percent: Int(self.percent),
                imageName: "person.fill"
            )
            
            CircleWaveView(
                percent: Int(self.percent),
                imageName: "heart.fill"
            )
            
            CircleWaveView(
                percent: Int(self.percent),
                imageName: "circle.fill"
            )
            
            Slider(value: self.$percent, in: 0...100)
            
        }
        .padding(.all)
        
    }
    
}

struct Wave: Shape {

    var offset: Angle
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        
        var p = Path()

        // empirically determined values for wave to be seen
        // at 0 and 100 percent
        let lowfudge = 0.02
        let highfudge = 1.0
        
        let newpercent = lowfudge + (highfudge - lowfudge) * self.percent
        let waveHeight = 0.015 * rect.height
        let yoffset = CGFloat(1 - newpercent) * (rect.height - 4 * waveHeight) + 2 * waveHeight
        let startAngle = self.offset
        let endAngle = self.offset + Angle(degrees: 360)
        
        p.move(to: CGPoint(x: 0, y: yoffset + waveHeight * CGFloat(sin(self.offset.radians))))
        
        for angle in stride(from: startAngle.degrees, through: endAngle.degrees, by: 5) {
            let x = CGFloat((angle - startAngle.degrees) / 360) * rect.width
            p.addLine(to: CGPoint(x: x, y: yoffset + waveHeight * CGFloat(sin(Angle(degrees: angle).radians))))
        }
        
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        
        return p
    }
}

struct CircleWaveView: View {
    
    @State private var waveOffset = Angle(degrees: 0)
    let percent: Int
    let imageName: String
    
    var body: some View {
        
        GeometryReader { geo in
            
            let _ = print(self.percent)
            
            ZStack {
                
                Image(systemName: self.imageName)
                    .resizable()
                    .foregroundStyle(.blue.gradient.opacity(0.2))
                
                Image(systemName: self.imageName)
                    .resizable()
                    .foregroundStyle(.blue.gradient)
                    .mask {
                        Wave(offset: Angle(degrees: self.waveOffset.degrees), percent: Double(self.percent)/100)
                            .fill(Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5))
                        //                                .clipShape(Circle().scale(1))
                    }
                
                Text("\(self.percent)%")
                    .foregroundColor(.black)
                    .font(Font.system(size: 0.25 * min(geo.size.width, geo.size.height)))
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                
            }
            
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            
            withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                self.waveOffset = Angle(degrees: 360)
            }
            
        }
    }
}

#Preview {
    WaterFillView()
}

