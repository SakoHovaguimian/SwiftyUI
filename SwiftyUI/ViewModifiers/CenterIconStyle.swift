//
//  CenterIconStyle.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 4/18/24.
//

import SwiftUI

struct CenterIconStyle: LabelStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        HStack(alignment: .center) {
            configuration.icon
            configuration.title
        }
        
    }
    
}

extension LabelStyle where Self == CenterIconStyle {
    static var centerIcon: CenterIconStyle {
        CenterIconStyle()
    }
}
