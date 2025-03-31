//
//  CustomEnvironment.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/3/24.
//

import SwiftUI

/// ENV keys are from parent -> child
/// mutating them from children is hard and not recommended.
/// Use this to pass data down....
private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: String = "Theme String"
}

extension EnvironmentValues {
    
    var theme: String {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
    
}

internal struct DemoParentView: View {
    
    @State private var isOn: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Toggle("isOn", isOn: self.$isOn)
            DemoReadEnvValue()
            
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 32)
        .background(.gray.opacity(0.2))
        .clipShape(.rect(cornerRadius: 12))
        .padding(32)
        .environment(\.theme, self.isOn ? "True" : "False")
        
    }
    
}

internal struct DemoReadEnvValue: View {
    
    @Environment(\.theme) private var themeString
    
    var body: some View {
        Text(self.themeString)
            .environment(\.theme, "Theme String Default Value")
    }
    
}

#Preview("Read ENV") {
    DemoParentView()
}
