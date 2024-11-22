//
//  AccelerometerBallView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 11/13/24.
//


import SwiftUI
import CoreMotion

struct AccelerometerBallView: View {
    
    // MARK: - Ball Position -
    
    enum BallPosition {
        
        case left
        case center
        case right
        
        var displayName: String {
            switch self {
            case .left: return "Left"
            case .center: return "Center"
            case .right: return "Right"
            }
        }
        
        var color: Color {
            switch self {
            case .left: return .indigo
            case .center: return .mint
            case .right: return .pink
            }
        }
        
        var gradientColors: [Color] {
            switch self {
            case .left: return [.blue, .indigo]
            case .center: return [.purple, .mint]
            case .right: return [.pink, .purple]
            }
        }
        
    }
    
    // MARK: - Properties -
    
    @State private var motionManager = CMMotionManager()
    
    @State private var xOffset: CGFloat = 0.0
    @State private var ballPosition: BallPosition = .left
    
    // MARK: - Body -

    var body: some View {
        
        ZStack {
            
            backgroundGradient()
            content()
            
        }
        .onAppear {
            startAccelerometerUpdates()
        }
        .onDisappear {
            self.motionManager.stopAccelerometerUpdates()
        }
        
        // Animations
        
        .animation(
            .smooth,
            value: self.ballPosition
        )
        
    }
    
    // MARK: - Subviews -
    
    private func backgroundGradient() -> some View {
        
        let colors =  self.ballPosition.gradientColors.map { $0.opacity(0.5) }
        
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
        
    }
    
    private func content() -> some View {
        
        VStack {
            
            title()
            ball()

        }
        
    }
    
    private func title() -> some View {
     
        Text("Ball Position: \(self.ballPosition.displayName)")
            .foregroundStyle(self.ballPosition.color)
            .contentTransition(.numericText())
            .font(.title2)
            .fontWeight(.heavy)
            .fontDesign(.monospaced)
            .padding()
        
    }
    
    private func ball() -> some View {
        
        Circle()
            .fill(self.ballPosition.color)
            .frame(width: 80, height: 80)
            .offset(x: self.xOffset)
            .animation(.easeOut, value: self.xOffset)
        
    }
    
    // MARK: - Business Logic -
    
    private func startAccelerometerUpdates() {
        
        self.motionManager.accelerometerUpdateInterval = 0.1

        self.motionManager.startAccelerometerUpdates(to: .main) { data, error in
            
            guard error == nil, let acceleration = data?.acceleration else { return }
            
            xOffset = CGFloat(acceleration.x) * 200 // Adjust multiplier as needed
            updateBallPosition(for: acceleration.x)
            
        }
        
    }
    
    private func updateBallPosition(for xValue: Double) {

        if xValue < -0.3 {
            self.ballPosition = .left
        } else if xValue > 0.3 {
            self.ballPosition = .right
        } else {
            self.ballPosition = .center
        }
        
    }
    
}

#Preview {
    AccelerometerBallView()
}
