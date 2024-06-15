//
//  iOSFormSheet.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/14/24.
//

import SwiftUI

/// This doesn't feel like it's working 😭

struct iOSFormSheet: View {
    
    enum PresentationStyle: String, Identifiable {
        
        var id: String {
            return self.rawValue
        }
        
        case form
        case page
        case fitted
        
    }
    
    @State private var presentationStyle: PresentationStyle? = nil
    
    var body: some View {
        
        AppBaseView {
            
            VStack {
                
                AppButton(title: "Present Form Style (iPad)", titleColor: .white) {
                    self.presentationStyle = .form
                }
                
                AppButton(title: "Present Page Style", titleColor: .white) {
                    self.presentationStyle = .page
                }
                
                AppButton(title: "Present Fitted Style", titleColor: .white) {
                    self.presentationStyle = .fitted
                }
                
            }
            .padding(.horizontal, .large)
            
        }
        .sheet(item: self.$presentationStyle) { style in
                        
            switch presentationStyle {
            case .form:
                
                Text("Form Sheet")
                    .presentationSizing(.form)
                
            case .page:
                
                Text("Page Sheet")
                    .presentationSizing(.page)
                
            case .fitted:
                
                VStack {
                    Text("Fitted Sheet")
                        .presentationSizing(
                            .page
                                .fitted(horizontal: false, vertical: true)
                                .sticky(horizontal: false, vertical: true))
                }
                
            case .none: EmptyView()
            }
            
        }
        
    }
    
}

#Preview {
    iOSFormSheet()
}
