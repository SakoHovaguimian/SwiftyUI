//
//  SegmentedBatteryView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 12/5/25.
//


import SwiftUI

struct SegmentedBatteryView: View {
    // MARK: - Configuration Properties
    var percentage: Double // 0.0 to 1.0
    var isCharging: Bool
    var segmentCount: Int = 40
    
    // MARK: - Computed Properties
    private var activeSegments: Int {
        return Int(percentage * Double(segmentCount))
    }
    
    // Dynamic color based on battery level
    private var batteryColor: Color {
        if isCharging { return .green }
        if percentage <= 0.2 { return .red }
        if percentage <= 0.5 { return .yellow }
        return .green
    }

    var body: some View {
        HStack(spacing: 12) {
            
            // 1. Charging Icon
            if isCharging {
                Image(systemName: "bolt.fill")
                    .foregroundColor(batteryColor)
                    .font(.system(size: 14, weight: .bold))
            }
            
            // 2. Segmented Bar
            // We use spacing: 2 to create that small gap seen in the image
            HStack(spacing: 3) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    Capsule()
                        .fill(index < activeSegments ? batteryColor : Color.gray.opacity(0.2))
                        // Fluid width: Let capsules fill available space
                        // Fixed height: Matches the design
                        .frame(height: 18)
                        .animation(.spring(), value: percentage) // Smooth fill animation
                }
            }
            
            // 3. Percentage Label
            Text("\(Int(percentage * 100))%")
                .font(.system(.body, design: .monospaced)) // Monospaced prevents jitter
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(width: 48)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 0)
        )
        // MARK: - Accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isCharging ? "Battery charging" : "Battery level")
        .accessibilityValue("\(Int(percentage * 100)) percent")
    }
}

// MARK: - Preview
struct BatteryPreview: View {
    @State private var level: Double = 0.88
    @State private var charging: Bool = true
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // The Component
                SegmentedBatteryView(percentage: level, isCharging: charging)
                    .frame(width: 350) // Constrain width as needed
                
                // Controls for testing
                Slider(value: $level, in: 0...1)
                Toggle("Charging", isOn: $charging)
            }
            .padding()
        }
    }
}

#Preview {
    BatteryPreview()
}
