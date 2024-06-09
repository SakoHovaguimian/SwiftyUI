//
//  ToastListView.swift
//  Rival
//
//  Created by Sako Hovaguimian on 1/29/24.
//

import SwiftUI

struct ToastGroup: View {
    
    var model = ToastManager.shared
    
    var isTopDirection: Bool {
        return self.model.toasts.map { $0.direction }.contains(.top)
    }
    
    var body: some View {
        
        GeometryReader {
            
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            ZStack {
                
                ForEach(self.model.toasts) { toast in
                    
                    Group {
                        
                        switch toast.style {
                        case .standard:
                            
                            ToastView(size: size, item: toast)
                            
                        case .custom:
                            
                            CustomToastView(size: size, item: toast)
                        }
                        
                    }
                    .scaleEffect(self.scale(toast))
                    .offset(y: self.offsetY(toast))
                    .zIndex(Double(self.model.toasts.firstIndex(where: { $0.id == toast.id }) ?? 0))
                    
                }
                
            }
            .padding(
                self.isTopDirection ? .top : .bottom,
                safeArea.top == .zero ? 15 : 10
            )
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: self.isTopDirection ? .top : .bottom
            )
            
        }
        
    }
    
    func offsetY(_ item: ToastItem) -> CGFloat {
        
        let index = CGFloat(self.model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(self.model.toasts.count) - 1
        
        return (totalCount - index) >= 2 ? -20 : ((totalCount - index) * -10)
        
    }
    
    func scale(_ item: ToastItem) -> CGFloat {
        
        let index = CGFloat(self.model.toasts.firstIndex(where: { $0.id == item.id }) ?? 0)
        let totalCount = CGFloat(self.model.toasts.count) - 1
        
        return 1.0 - ((totalCount - index) >= 2 ? 0.2 : ((totalCount - index) * 0.1))
        
    }
    
}

#Preview {
    
    let items: [ToastItem] = [
        
        .init(
            title: "Some Toast",
            titleColor: .black,
            message: "This is kinda cool",
            messageColor: .black,
            symbol: "person.fill",
            tint: .blue,
            direction: .top
        ),
        
        .init(
            style: .custom,
            title: "Saved & Updated",
            titleColor: .green,
            message: "2383289238 90923908 23892 890 23 89  9329 8823 0823809",
            messageColor: .black,
            symbol: "checkmark.circle.fill",
            tint: .green,
            isUserInteractionEnabled: true,
            timing: nil
        ),
    
        .init(
            style: .custom,
            title: "Something Went Wrong",
            titleColor: .red,
            messageColor: .black,
            symbol: "exclamationmark.square.fill",
            tint: .red,
            isUserInteractionEnabled: true,
            timing: nil
        )
        
    ]
    
    return ZStack {
        
        Color.white.ignoresSafeArea()
        
        Button("Make Toast") {
            
            ToastManager
                .shared
                .present(toastItem: items.randomElement()!)
            
        }
        
        
    }
    .withToastOverlay()
    
}
