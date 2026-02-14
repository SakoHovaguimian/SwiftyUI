//
//  SwipeAction.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 2/14/26.
//


import SwiftUI


public struct SwipeAction<Content: View, ActionContent: View>: View {
    @ViewBuilder public var content: Content
    @ViewBuilder public var actionContent: ActionContent
    public var deleteAction: () -> Void
    
    private let viewID = "CONTENT_VIEW_ID"

    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder actionContent: () -> ActionContent,
        deleteAction: @escaping () -> Void
    ) {
        self.content = content()
        self.actionContent = actionContent()
        self.deleteAction = deleteAction
    }
    
    public var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    content
                        .containerRelativeFrame(.horizontal)
                        .id(viewID)
                        .transition(.identity)
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 60)
                        .overlay(alignment: .trailing) {
                            actionButton(scrollProxy: scrollProxy)
                                .background(.red)
                        }
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    let minX = geometryProxy.frame(in: .scrollView(axis: .horizontal)).minX
                    let scrollOffset = (minX > 0 ? -minX : 0)
                    
                    return content
                        .offset(x: scrollOffset)
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background(.red)
            .clipShape(.rect(cornerRadius: 60))
        }
        .transition(CustomTransition())
    }
    
    private func actionButton(scrollProxy: ScrollViewProxy) -> some View {
        Button(action: {
            withAnimation(.snappy) {
                scrollProxy.scrollTo(viewID, anchor: .topLeading)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut) {
                    deleteAction()
                }
            }
        }) {
            actionContent
                .frame(maxHeight: .infinity)
                .contentShape(.rect)
                .padding(.trailing, 20)
        }
        .buttonStyle(.plain)
    }
}

public struct CustomTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .mask {
                GeometryReader {
                    let size = $0.size
                    Rectangle()
                        .offset(y: phase == .identity ? 0 : -size.height)
                }
                .containerRelativeFrame(.horizontal)
            }
    }
}

//
//#Preview {
//    
//    AppBaseView {
//        
//        SwipeAction {
//            
//            AppCardView {
//                
//                Text("Swipe To Delete")
//                    .padding(.vertical, 32)
//                
//            }
//            
//        } actionContent: {
//            
//            AppCardView(backgroundColor: .darkRed) {
//                
//                Text("Test")
//                    .foregroundStyle(.white)
////                    .padding(.vertical, 32)
//                
//            }
//            .fixedSize(horizontal: false, vertical: true)
//            .clipped()
//            
//        } deleteAction: {
//            print("Delete")
//        }
//
//        
//    }
//    
//}

#Preview {
    
    AppBaseView {
        
        ScrollView {
            
            ForEach(0..<50) { _ in
                
                item()
                
            }
            
        }
        
    }
    
}

func item() -> some View {
    
    SwipeAction(
        content: {
            ZStack {
                RoundedRectangle(cornerRadius: 60)
                    .fill(.black)
                    .frame(height: 65)
                Text("Swipe to Delete")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
            }
        },
        actionContent: {
            Image(systemName: "trash.fill")
                .foregroundColor(.white)
                .font(.body)
        },
        deleteAction: {
            ///Handle Delete
        }
    )
    .padding(.horizontal, 32)
    .fixedSize(horizontal: false, vertical: true)
    
}
