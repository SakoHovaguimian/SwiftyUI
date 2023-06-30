//
//  CustomButton.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI

struct ButtonStyleViewModifier: ButtonStyle {
    
    let scale: CGFloat
    let opacity: Double
    let brightness: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? opacity : 1)
            .brightness(configuration.isPressed ? brightness : 0)
    }
    
}

@available(iOS 14, *)
public extension View {
    
    /// Wrap a View in a Link and add a custom ButtonStyle.
    @ViewBuilder
    func asWebLink(scale: CGFloat = 0.95, opacity: Double = 1, brightness: Double = 0, url: @escaping () -> URL?) -> some View {
        if let url = url() {
            Link(destination: url) {
                self
            }
            .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
        } else {
            self
        }
    }
    
    func asButton(scale: CGFloat = 0.95, opacity: Double = 1, brightness: Double = 0, action: @escaping @MainActor () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(ButtonStyleViewModifier(scale: scale, opacity: opacity, brightness: brightness))
    }
    
}

@available(iOS 14, *)
struct ButtonStyleViewModifier_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            CardView {
                
                ZStack {
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            
                            Text("Card")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .fontDesign(.rounded)
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.leading)
                                .padding([.top], 24)
                            
                            Spacer()
                            
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(Gradient(colors: [.orange, .red]))
                                .padding([.top], 24)
                            
                        }
                        
                        HStack {
                            
                            Text("Buy now, pay later")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(.gray)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                        }
                        
                        Spacer()
                        
                        Text("Sako Hovaguimian")
                            .font(.headline)
                            .fontWeight(.black)
                            .fontDesign(.rounded)
                            .foregroundStyle(.black.opacity(0.8))
                            .multilineTextAlignment(.leading)
                        
                        Text("0000-0000-0000-0000")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.leading)
                            .padding([.bottom], 24)
                        
                    }
                    .padding(.horizontal, 24)
                }
                
                
            }
            .frame(height: 200)
            
            Spacer()
            
            Label(
                title: { Text("Click me") },
                icon: { Image(systemName: "heart.fill") }
            )
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .padding(.horizontal)
            .background(Color.green)
            .clipShape(Capsule())
            .asButton {
                print("Test")
            }
            
            Text("Animated Button")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .padding(.horizontal)
                .background(Color.red)
                .cornerRadiusIfNeeded(cornerRadius: 12)
                .asButton {
                    print("Tapped")
                }
//                .asWebLink {
//                    URL(string: "https://www.google.com")
//                }
        }
        
    }
}
