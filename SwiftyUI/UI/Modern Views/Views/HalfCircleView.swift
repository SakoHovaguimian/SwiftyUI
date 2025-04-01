//
//  HalfCircleView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 10/10/24.
//

import SwiftUI

struct NormalHalfCircleProgressView: View {
    
    var progress: CGFloat // Expecting progress between 0 and 1
    
    var body: some View {
        
        ZStack {
            
            HalfCircleShape()
                .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.gray.opacity(0.3))

            HalfCircleShape().trim(from: 0.0, to: self.progress)
                .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.blue, .indigo]), startPoint: .leading, endPoint: .trailing))
            
            Text("\(Int(self.progress * 100))%")
                .font(.largeTitle.bold())
                .contentTransition(.numericText(value: progress))
                .animation(.smooth(duration: 0.5), value: progress)
            
        }
        
    }
    
}

struct NormalHalfCirclePreviewView: View {
    
    @State var progress: CGFloat = 0.0
    
    var body: some View {
        
        VStack {
            
            NormalHalfCircleProgressView(progress: self.progress)
                .padding(.horizontal, .custom(64))
            
            Button("Randomize Progress") {
                let newProgress = CGFloat.random(in: 0...1)
                
                withAnimation(.bouncy(duration: 1.5)) {
                    self.progress = newProgress
                }
            }
            .padding()
            
        }
        
    }
    
}

#Preview {
    
    NormalHalfCirclePreviewView()
    
}

// THIS USES STEPS / MAX PROGRESS / ETC to Normalize Data
struct HalfCircleProgressView: View {
    
    var progress: CGFloat
    var totalSteps: Int
    var minValue: CGFloat
    var maxValue: CGFloat
    
    var body: some View {
        
        ZStack {
            
            HalfCircleShape()
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundStyle(
                    .gray.opacity(
                        0.3
                    )
                )
                .frame(
                    width: 200,
                    height: 100
                )
            
            HalfCircleShape()
                .trim(
                    from: 0.0,
                    to: self.normalizedProgress
                )
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                .blue,
                                .indigo
                            ]
                        ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(
                    width: 200,
                    height: 100
                )
            
            VStack {
                
                Text("\(Int((self.progress / self.maxValue) * 100))%")
                    .font(.largeTitle.bold())
                
                Text("\(self.remainingSteps) steps left")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
            }
            
        }
        
    }
    
    private var normalizedProgress: CGFloat {
        (self.progress - self.minValue) / (self.maxValue - self.minValue)
    }
    
    private var remainingSteps: Int {
        self.totalSteps - Int(self.progress)
    }
    
}

struct HalfCircleShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 0), clockwise: false)
        return path
        
    }
    
}

struct HalfCirclePreviewView: View {
    
    @State var progress: CGFloat = 0
    @State var displayedProgress: CGFloat = 0
    
    var body: some View {
        
        VStack {
            
            HalfCircleProgressView(progress: self.progress, totalSteps: 500, minValue: 0, maxValue: 500)
            
            Button {
                
                let newProgress = CGFloat.random(in: 0..<500)
                
                withAnimation(
                    .spring(
                        response: 0.5,
                        dampingFraction: 0.7,
                        blendDuration: 0.5
                    )
                ) {
                    self.startIncrementing(to: newProgress)
                }
                
            } label: {
                
                Text("Randomize Progress")
                
            }
            .padding()
            
        }
        
    }
    
    func startIncrementing(to targetValue: CGFloat) {
        
        let step: CGFloat = targetValue > self.displayedProgress ? 1 : -1
        Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { timer in
            
            if (step > 0 && self.displayedProgress < targetValue) || (step < 0 && self.displayedProgress > targetValue) {
                
                self.displayedProgress += step
                self.progress = self.displayedProgress
                
            } else {
                
                timer.invalidate()
                self.displayedProgress = targetValue
                self.progress = self.displayedProgress
                
            }
            
        }
        
    }
    
}

#Preview {
    
    HalfCirclePreviewView()
    
}
