//
//  RelativeBarView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/16/25.
//

import SwiftUI

struct RelativeBarView: View {
    
    var segments: [RelativeBarViewSegment]
    var mode: RelativeBarViewMode
    
    var cornerRadius: CornerRadius = .extraSmall
    var backgroundColor: AppBackgroundStyle = .color(.gray.opacity(0.2))
    var barHeight: CGFloat = 32
    
    var shouldShowTitles: Bool = true
    var showLegend: Bool = false
    
    @State private var animatedSegments: [RelativeBarViewSegment] = []
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            barContent()
                .frame(height: self.barHeight)
            
            if self.showLegend {
                
                LegendView(
                    segments: self.segments,
                    mode: self.mode
                )
                
            }
            
        }
        
        // Lifecycle
        
            .onAppear {
                self.animateSegments()
            }
        
            .onChange(of: self.segments) { _ in
                self.animateSegments()
            }
        
    }
    
    // MARK: - Views
    
    private func barContent() -> some View {
        
        GeometryReader { geometry in
            
            let availableWidth = geometry.size.width
            let totalValue = self.totalSegmentValue()
            let maxReference = self.referenceMax(for: totalValue)
            
            ZStack(alignment: .leading) {
                
                // Background
                
                backgroundView(geometry: geometry)
                
                // Segments
                
                segmentListView(
                    availableWidth: availableWidth,
                    maxReference: maxReference,
                    geometry: geometry
                )
                
            }
            .clipShape(.rect(cornerRadius: self.cornerRadius.value))
            
        }
        
    }
    
    private func backgroundView(geometry: GeometryProxy) -> some View {
        
        Rectangle()
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
            .foregroundStyle(self.backgroundColor.backgroundStyle())
        
    }
    
    private func segmentListView(availableWidth: CGFloat,
                                 maxReference: CGFloat,
                                 geometry: GeometryProxy) -> some View {
        
        HStack(spacing: 0) {
            
            ForEach(self.animatedSegments) { segment in
                
                segmentView(
                    segment: segment,
                    availableWidth: availableWidth,
                    maxReference: maxReference,
                    geometry: geometry
                )
                
            }
            
        }
        
    }
    
    private func segmentView(segment: RelativeBarViewSegment,
                             availableWidth: CGFloat,
                             maxReference: CGFloat,
                             geometry: GeometryProxy) -> some View {
        
        let segmentWidth = maxReference > 0
        ? (segment.value / maxReference) * availableWidth
        : 0
        
        return segment.color
            .viewStyle()
            .frame(width: segmentWidth, height: geometry.size.height)
            .overlay {
                
                if self.shouldShowTitles, segmentWidth > 20 {
                    
                    Text(segment.title)
                        .appFont(with: .title(.t2))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.5)
                    
                }
                
            }
        
    }
    
    // MARK: - Business Logic
    
    private func totalSegmentValue() -> CGFloat {
        self.segments.reduce(0) { $0 + $1.value }
    }
    
    private func referenceMax(for totalValue: CGFloat) -> CGFloat {
        
        switch self.mode {
        case .relativeFill: return totalValue
        case .fixed(let maxValue): return max(totalValue, maxValue)
        }
        
    }
    
    private func animateSegments() {
        
        withAnimation(.easeInOut(duration: 0.4)) {
            self.animatedSegments = self.segments
        }
        
    }
    
}

fileprivate struct LegendView: View {
    
    var segments: [RelativeBarViewSegment]
    var mode: RelativeBarViewMode
    
    private var totalValue: CGFloat {
        self.segments.reduce(0) { $0 + $1.value }
    }
    
    private func referenceMax(for total: CGFloat) -> CGFloat {
        
        switch self.mode {
        case .relativeFill: return total
        case .fixed(let maxValue): return max(total, maxValue)
        }
        
    }
    
    var body: some View {
        
        let maxReference = self.referenceMax(for: self.totalValue)
        
        WStack {
            
            ForEach(self.segments) { segment in
                
                HStack {
                    
                    // Color Indicator
                    
                    Circle()
                        .fill(segment.color.foregroundStyle())
                        .frame(width: 12, height: 12)
                    
                    // Title
                    
                    Text(segment.title)
                        .appFont(with: .body(.b1))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                                        
                    // Percentage Value
                    let percentage = maxReference > 0
                    ? (segment.value / maxReference) * 100
                    : 0
                    
                    Text("\(Int(percentage))%")
                        .appFont(with: .body(.b1))
                        .foregroundStyle(.black)
                    
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .background(segment.color.foregroundStyle().opacity(0.2))
                .clipShape(.capsule)
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        
    }
    
}

// MARK: - Models

enum RelativeBarViewMode {
    
    case relativeFill
    case fixed(maxValue: CGFloat)
    
}

struct RelativeBarViewSegment: Identifiable, Equatable {
    
    static func == (lhs: RelativeBarViewSegment, rhs: RelativeBarViewSegment) -> Bool {
        
        lhs.id == rhs.id &&
        lhs.value == rhs.value &&
        lhs.title == rhs.title
        
    }
    
    
    let id = UUID()
    let value: CGFloat
    let title: String
    let color: AppForegroundStyle
    
}

#Preview {
    
    @Previewable @State var items: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Apple", color: .color(.red)),
        RelativeBarViewSegment(value: 600, title: "Microsoft", color: .color(.green)),
        RelativeBarViewSegment(value: 200, title: "FNGU", color: .color(.blue))
    ]
    
    @Previewable @State var itemsGradient: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Apple", color: .linearGradient(.redColor())),
        RelativeBarViewSegment(value: 600, title: "Microsoft", color: .linearGradient(.greenColor())),
        RelativeBarViewSegment(value: 200, title: "FNGU", color: .linearGradient(.blueColor()))
    ]
    
    @Previewable @State var items2: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Apple", color: .color(.red)),
        RelativeBarViewSegment(value: 600, title: "Microsoft", color: .color(.green)),
        RelativeBarViewSegment(value: 200, title: "FNGU", color: .color(.blue)),
        RelativeBarViewSegment(value: 200, title: "SOXL", color: .color(.indigo))
    ]
    
    @Previewable @State var items3: [RelativeBarViewSegment] = [
        RelativeBarViewSegment(value: 300, title: "Logic Pro X", color: .color(.red)),
        RelativeBarViewSegment(value: 200, title: "XCode", color: .color(.blue))
    ]
    
    VStack(spacing: .appXLarge) {
        
        RelativeBarView(
            segments: items,
            mode: .relativeFill,
            cornerRadius: .small,
            shouldShowTitles: false,
            showLegend: true
        )
        
        RelativeBarView(
            segments: itemsGradient,
            mode: .relativeFill,
            cornerRadius: .small,
            shouldShowTitles: true,
            showLegend: false
        )
        
        RelativeBarView(
            segments: items2,
            mode: .relativeFill,
            cornerRadius: .small,
            showLegend: true
        )
        
        RelativeBarView(
            segments: items3,
            mode: .fixed(maxValue: 1000),
            cornerRadius: .small,
            showLegend: true
        )
        
    }
    .padding(.horizontal, 24)
    
}

extension LinearGradient {
    
    static func redColor() -> LinearGradient {
        
        LinearGradient(
            gradient: Gradient(
                colors: [
                    .red,
                    .purple
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    static func blueColor() -> LinearGradient {
        
        LinearGradient(
            gradient: Gradient(
                colors: [
                    .blue,
                    .purple
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    static func greenColor() -> LinearGradient {
        
        LinearGradient(
            gradient: Gradient(
                colors: [
                    .green,
                    .pink
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
    static func purpleColor() -> LinearGradient {
        
        LinearGradient(
            gradient: Gradient(
                colors: [
                    .indigo,
                    .yellow
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
    }
    
}
