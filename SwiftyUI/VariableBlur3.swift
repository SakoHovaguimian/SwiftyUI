////
////  VariableBlur3.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 8/20/25.
////
//
//import SwiftUI
//
//struct TestVst: View {
//    
//    let uiImage: UIImage = UIImage(resource: .welcome)
//    @State private var extractedColors: [Color] = []
//    
//    var body: some View {
//        
//        Image(.welcome)
//            .resizable()
//            .scaledToFill()
//            .gradientBlur(
//                tint: .red,//extractedColors.first ?? .red,
//                tintOpacity: 1,
//                blurRadius: 0,
//                gradientDirection: .topToBottom,
//                alignment: .bottom,
//                heightStyle: .fixed(450)
//            )
//            .clipShape(.rect(cornerRadius: 24))
//            .ignoresSafeArea()
//            .onAppear {
//                extractColor()
//            }
//        
//    }
//
//    
//    func extractColor() {
//        
//        // Heavy work off the main thread
//        DispatchQueue.global(qos: .userInitiated).async {
//            
//            do {
//                
//                let uiColors = try uiImage.extractColors(
//                    numberOfColors: 1,
//                    sortByProminence: true
//                )
//                
//                let swiftUIColors = uiColors.map { Color($0) }
//                
//                DispatchQueue.main.async {
//                    extractedColors = swiftUIColors
//                }
//                
//            } catch {
//                print("Failed to extract colors:", error)
//            }
//            
//        }
//        
//    }
//    
//}
//
//#Preview {
//    TestVst()
//}
