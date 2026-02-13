import SwiftUI
import MetalKit

struct SexyWeatherView: View {
    @State private var startTime = Date()
    
    // 0 = Wave, 1 = Rain, 2 = Snow
    @State private var weatherMode: Int = 0
    
    var body: some View {
        GeometryReader { proxy in
            let screenSize = proxy.size
            
            ZStack {
                // 1. DYNAMIC BACKGROUND
                LinearGradient(
                    colors: weatherMode == 0 ? [.cyan.opacity(0.3), .blue] :
                            weatherMode == 1 ? [.gray, .black] :
                            [.black, .blue.opacity(0.4)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // 2. THE SHADER LAYER
                TimelineView(.animation) { timeline in
                    let time = Float(timeline.date.timeIntervalSince(startTime))
                    
                    Rectangle()
                        .fill(.white.opacity(0.0001)) // Important!
                        .frame(width: screenSize.width, height: screenSize.height)
                        .colorEffect(
                            getShader(time: time, size: screenSize)
                        )
                        .ignoresSafeArea()
                }
                .ignoresSafeArea()
                
                // 3. THE CONTROLS
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        WeatherButton(icon: "water.waves", title: "Ocean", isSelected: weatherMode == 0) { weatherMode = 0 }
                        WeatherButton(icon: "cloud.rain", title: "Storm", isSelected: weatherMode == 1) { weatherMode = 1 }
                        WeatherButton(icon: "snowflake", title: "Snow", isSelected: weatherMode == 2) { weatherMode = 2 }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    // Helper to pick the right shader
    func getShader(time: Float, size: CGSize) -> Shader {
        let width = Float(size.width)
        let height = Float(size.height)
        
        switch weatherMode {
        case 0:
            return ShaderLibrary.default.sexyWave(.float2(width, height), .float(time))
        case 1:
            return ShaderLibrary.default.sexyRain(.float2(width, height), .float(time))
        default:
            return ShaderLibrary.default.sexySnow(.float2(width, height), .float(time))
        }
    }
}

// Button Helper
struct WeatherButton: View {
    var icon: String; var title: String; var isSelected: Bool; var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon).font(.title2)
                Text(title).font(.caption).bold()
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding()
            .background(isSelected ? Color.white.opacity(0.2) : Color.clear)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    SexyWeatherView()
}
