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
                imageName: "drop.fill",
                color: .blue
            )

            CircleWaveView(
                percent: Int(self.percent),
                imageName: "heart.fill",
                color: .green
            )
            
            CircleWaveView(
                percent: Int(self.percent),
                imageName: "circle.fill",
                color: .indigo
            )
            
            Slider(value: self.$percent, in: 0...100)
            
            Button {
                withAnimation {
                    for i in 0...9 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + (0.06 * Double(i)), execute: {
                            self.percent += 1
                        })
                    }
                }
                
            } label: {
                
                Text("Update Progress")
                
                    .frame(width: 200)
                    .padding(.all, 12)
                    .foregroundColor(.white)
                    .background(Color.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: Color.blue.opacity(0.4), radius: 2, x: 0, y: 0)
                
            }
            
            Button {
                withAnimation {
                    for i in 0...9 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + (0.06 * Double(i)), execute: {
                            self.percent -= 1
                        })
                    }
                }
                
            } label: {
                
                Text("Subtract Progress")
                
                    .frame(width: 200)
                    .padding(.all, 12)
                    .foregroundColor(.white)
                    .background(Color.blue.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: Color.blue.opacity(0.4), radius: 2, x: 0, y: 0)
                
            }

            
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
    let color: Color
    
    var body: some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                Image(systemName: self.imageName)
                    .resizable()
                    .foregroundStyle(self.color.gradient.opacity(0.2))
                
                Image(systemName: self.imageName)
                    .resizable()
                    .foregroundStyle(self.color.gradient)
                    .mask {
                        
                        Wave(
                            offset: Angle(degrees: self.waveOffset.degrees),
                            percent: Double(self.percent)/100
                        )
                        .fill(
                            Color(red: 0, green: 0.5, blue: 0.75, opacity: 0.5)
                        )
                        
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

