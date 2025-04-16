import SwiftUI

public enum StackAxis: Equatable {
    
    case horizontal(alignment: VerticalAlignment)
    case vertical(alignment: HorizontalAlignment)
    
    var isHorizontal: Bool {
        switch self {
        case .horizontal: return true
        case .vertical: return false
        }
    }
    
    var isVertical: Bool {
        switch self {
        case .horizontal: return false
        case .vertical: return true
        }
    }
    
}

struct Stack<Content: View>: View {
        
    private let axis: StackAxis
    private let spacing: CGFloat?
    private let scrollsOnOverflow: Bool
    private let content: Content
    
    init(axis: StackAxis,
         spacing: CGFloat? = nil,
         scrollsOnOverflow: Bool = false,
         @ViewBuilder content: () -> Content) {
        
        self.axis = axis
        self.spacing = spacing
        self.scrollsOnOverflow = scrollsOnOverflow
        self.content = content()
        
    }
        
    var body: some View {
        scrollContainer()
    }
    
    @ViewBuilder
    private func scrollContainer() -> some View {
        
        ScrollView(self.axis.isVertical ? .vertical : .horizontal,
                   showsIndicators: false) {
            
            switch axis {
            case .horizontal(let alignment):
                
                HStack(alignment: alignment, spacing: spacing) {
                    content
                }
                .transition(.opacity.combined(with: .blurReplace))
                
            case .vertical(let alignment):
                
                VStack(alignment: alignment, spacing: spacing) {
                    content
                }
                .transition(.opacity.combined(with: .blurReplace))
                
            }
            
        }
        .scrollBounceBehavior(
            .basedOnSize,
            axes: [.vertical, .horizontal]
        )
        
    }
    
}

#Preview {
    
    @Previewable @State var currentAxis: StackAxis = .vertical(alignment: .leading)
    
    AppBaseView {
        
        Stack(axis: currentAxis, spacing: 32) {
            
            Group {
                
                Text("Item 1")
                    .appFont(with: .title(.t10))
                Text("Item 2")
                    .appFont(with: .title(.t10))
                Text("Item 3")
                    .appFont(with: .title(.t10))
                
            }
            
        }
        .safeAreaPadding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGray6))
        .animation(.spring, value: currentAxis)
        
    }
    .safeAreaInset(edge: .bottom) {
        
        HStack {
            
            AppButton(title: "Axis",
                      titleColor: .white,
                      backgroundColor: .indigo) {
                
                switch currentAxis {
                case .horizontal:
                    
                    withAnimation(.smooth) {
                        currentAxis = .vertical(alignment: .center)
                    }
                    
                case .vertical:
                    
                    withAnimation(.smooth) {
                        currentAxis = .horizontal(alignment: .center)
                    }
                    
                default: break
                }
                
            }
            .padding(.horizontal, 48)
            
        }
        
    }
    
}
