//
//  JoeTEst.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 11/13/23.
//

import SwiftUI

struct JoeTest: View {
    
    @State private var hue = 0.5
    @State private var saturation = 0.36
    @State private var brightness = 0.43

    var body: some View {
        
        ZStack {
            
            Color(hue: 0.66, saturation: 0.20, brightness: 0.08) // #101014
                .ignoresSafeArea(.all)
            
            VStack {
                VStack {
                    VStack(spacing: 24) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text("Challenge name")
                                    .font(.title).fontWeight(.semibold)
                                HStack {
                                    Label("Most Acitivty", systemImage: "figure.walk")
                                    
                                    Label{
                                        Text("Most Rivals")
                                    } icon: {
                                        Image(systemName: "person.3.sequence.fill")
                                    }
                                    
                                    Label("Place", systemImage: "trophy.fill")
                                }
                            }
                            .font(.caption)
                            
                            Spacer()
                            
                            Label("Icon Only", systemImage: "waveform.path.ecg")
                                .font(.title3)
                                .padding(8)
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.background)
                                .background(
                                    Color(hue: hue, saturation: 0.61, brightness: 0.75)
                                )
                                .clipShape(Circle())
                        }
                        
                        HStack {
                            
                            ForEach(0 ..< 3) { item in
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Mile").font(.caption)
                                    Text("5411.0")
                                    
                                }
                                .font(.title2)
                                
                                Spacer()
                                
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                        
                    }
                    .foregroundStyle(.background)
                    .padding()
                    .background(
                        Color(hue: 0.62, saturation: 0.25, brightness: 0.22)
                    )
                    .clipShape(.rect(cornerRadius: 16))
                    .padding(2)
                    
                    HStack(alignment: .center){
                        HStack(spacing: -12) {
                            ForEach(0 ..< 3) { item in
                                Text("AB")
                                    .bold()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(
                                        Color(hue: 0.59, saturation: 0.39, brightness: 0.42)
                                    )
                                    .background( .black )
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                            }
                        }
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("Log Activity").padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(
                            Color(hue: 0.59, saturation: 0.39, brightness: 0.62)
                        )
                    }
                    .padding(8)
                    
                }
                .padding(3)
                .background(
                    Color(hue: 0.59, saturation: 0.39, brightness: 0.42)
                )
//                .saturation(0.5)
                .clipShape(.rect(cornerRadius: 16))
                .padding(8)
//                .shadow(color: Color.white.opacity(0.05), radius: 8, x: 0, y: 8)
                .overlay() {
                    Color(hue: hue, saturation: saturation, brightness: brightness)
                    .blendMode(.hue)
                }
                
                Spacer()
            }
            
            VStack(alignment: .trailing) {
                Spacer()
                
                VStack {
                    Slider(
                        value: $hue,
                        in: 0...1
                    ) {
                        Text("Speed")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("100")
                    }
                    Text("Hue: \(hue, specifier: "%.2f") is \(hue * 360, specifier: "%.0f") ")
                        }
            }
            .foregroundStyle(.background)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
    }
}

#Preview {
    JoeTest()
}
