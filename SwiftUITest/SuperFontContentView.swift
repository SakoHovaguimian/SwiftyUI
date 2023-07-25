//
//  SuperFontContentView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/24/23.
//

import SwiftUI

protocol FormError {
    
    var title: String { get }
    
}

enum EmailFormError: FormError {
    
    case invalid
    case misc
    
    var title: String {
        return "Sample Error Message"
    }
    
}

enum NameFormError: FormError {
    
    case invalid
    case short
    
    var title: String {
        return "Sample Error Message"
    }
    
}

//struct MyForm: Hashable {
//    
//    var title: String
//    var value: String
//    var formError: FormError?
//    
//}

enum AutoJoinHotspotOption: String, CaseIterable, Identifiable {
    
    var id: Self {
        return self
    }
    
    case never
    case askToJoin
    case automatic
    
}

struct SuperFormContentView: View {
    
    @State private var deviceName: String = ""
    @State private var isWifiEnabled: Bool = false
    @State private var autoJoinOption: AutoJoinHotspotOption = .never
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            Form {

                Section {
                    TextField("Name", text: $deviceName)
                    LabeledContent("iOS Version", value: "16.2")
                } header: {
                    Text("About")
                }

                Section {
                    Toggle("Wi-Fi", isOn: self.$isWifiEnabled)
                    Picker("Auto-Join Hotspot", selection: self.$autoJoinOption) {
                        
                        ForEach(AutoJoinHotspotOption.allCases, id: \.self) {
                            Text($0.rawValue)
                                .tag(Optional($0.rawValue))
                        }

                    }

                } header: {
                    Text("Internet")
                }
                
                Section {
                    DatePicker("Date picker", selection: $date)
                }
                
                Section {
                    Button("Reset All Content and Settings") {
                        // Reset logic
                    }
                }
            }

            .tint(.pink)
            .navigationBarTitle("Settings")
        }
    }
    
}

#Preview {
    SuperFormContentView()
}
