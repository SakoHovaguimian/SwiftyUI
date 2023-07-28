//
//  SegmentedControlView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/26/23.
//

import SwiftUI

struct SegmentedControlView: View {

    let segments: [String]
    @Binding var selected: String
    
    @Namespace var name

    var body: some View {
        
        HStack(spacing: 0) {
            
            ForEach(self.segments, id: \.self) { segment in
                
                Button {
                    self.selected = segment
                } label: {
                    
                    VStack {
                        Text(segment)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(self.selected == segment ? .green : Color(uiColor: .systemGray))
                        
                        ZStack {
                            
                            Capsule()
                                .fill(Color.clear)
                                .frame(height: 4)
                            
                            if self.selected == segment {
                                
                                Capsule()
                                    .fill(Color.green)
                                    .frame(height: 4)
                                    .matchedGeometryEffect(id: "Tab", in: self.name)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .animation(.linear, value: self.selected)
        
    }
    
}

import SwiftUI

struct SegmentedControlTestView: View {

    let segments: [String] = ["OPEN", "COMPLETED", "CLOSED"]
    @State private var selectedSegment: String = "OPEN"

    var body: some View {
        
        VStack {
            
            SegmentedControlView(
                segments: self.segments,
                selected: self.$selectedSegment
            )
            
            Text(self.selectedSegment)
            
            Spacer()
            
        }
        
    }
    
}

#Preview {
    
    SegmentedControlTestView()
    
}


// MARK: - Styled differently

//struct SegmentedControlView: View {
//
//    let segments: [String]
//    @Binding var selected: String
//    
//    @Namespace var name
//
//    var body: some View {
//        
//        HStack(spacing: 0) {
//            
//            ForEach(self.segments, id: \.self) { segment in
//                
//                Button {
//                    self.selected = segment
//                } label: {
//                    
//                    VStack {
//                        Text(segment)
//                            .font(.footnote)
//                            .fontWeight(.medium)
//                            .foregroundColor(self.selected == segment ? .green : Color(uiColor: .systemGray))
//                        
//                        ZStack {
//                            
//                            Capsule()
//                                .fill(Color.clear)
//                                .frame(height: 4)
//                            
//                            if self.selected == segment {
//                                
//                                Capsule()
//                                    .fill(Color.green)
//                                    .frame(height: 4)
//                                    .matchedGeometryEffect(id: "Tab", in: self.name)
//                                
//                            }
//                            
//                        }
//                        
//                    }
////                    .frame(maxWidth: .infinity)
//                    .padding(.horizontal, .small)
//                    
//                }
//                
//            }
//            
//        }
//        .padding(.vertical, .large)
//        .background { RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .systemGray6)) }
//        .background(content: {
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(.gray.opacity(0.3), lineWidth: 2)
//        })
//        .padding(.horizontal, .large)
//        .animation(.linear, value: self.selected)
//        
//    }
//    
//}
