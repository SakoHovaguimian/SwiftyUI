//
//  SegmentedControlView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/26/23.
//

import SwiftUI

struct SegmentedControlView: View {
    
    // TODO: CREATE ENUM OF SEGMENT TYPES TO INHERIT FROM
    // TODO: BINDING SHOULD ACCEPT SAID TYPE

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

    let segments: [String] = ["OPEN", "COMPLETED", "CANCELLED", "ALL"]
    @State private var selectedSegment: String = "OPEN"

    var body: some View {
        
        VStack {
            
            SegmentedControlView(
                segments: self.segments,
                selected: self.$selectedSegment
            )
//            .animation(.linear, value: self.selectedSegment)
            
            Spacer()
            
        }
        
    }
    
}

#Preview {
    
    SegmentedControlTestView()
    
}
