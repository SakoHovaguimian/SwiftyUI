//
//  SafariWebView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/15/23.
//

import SwiftUI
import SafariServices

struct SafariWebContentView: View {
    
    let url: URL
    
    var body: some View {
        
        Button("Present SFSafariViewController") {
            let vc = SFSafariViewController(url: url)
            UIApplication.shared.firstKeyWindow?.rootViewController?.present(vc, animated: true)
        }
        
    }

}
