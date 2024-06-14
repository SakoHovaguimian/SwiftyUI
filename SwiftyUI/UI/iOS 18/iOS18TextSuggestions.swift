//
//  iOS18TextSuggestions.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/14/24.
//

import SwiftUI

/// Commented out because `textInputSuggestions` is unregonized...
/// We can also create an object and pass images and text via `Label`
/*
 TextField("Location", text: $addressText)
     .textInputSuggestions {
         ForEach(model.suggestedVenues) { venue in
             Label(venue.name, image: venue.image)
                 .textInputCompletion(venue.address)
         }
     }
*/
struct iOS18TextSuggestions: View {
    
    @Binding var email: String
    @FocusState private var isFocused: Bool
    
    private var emailSuggestions: [String] = [
        "@gmail",
        "@yahoo",
        "@earthlink",
        "@outlook",
    ]
    
    init(email: Binding<String>) {
        self._email = email
    }
    
    var body: some View {
        
        AppBaseView(alignment: .center) {
            
            VStack(alignment: .leading, spacing: 32) {
                
                TextField("email", text: self.$email)
//                    .textInputSuggestions {
//                        Text("The Fillmore")
//                            .textInputCompletion("1805 Geary Blvd, San Francisco")
//                        Text("The Catalyst")
//                            .textInputCompletion("1011 Pacific Ave, Santa Cruz")
//                        Text("Rio Theatre")
//                            .textInputCompletion("1205 Soquel Ave, Santa Cruz")
//                    }
                    .appTextFieldStyle(
                        text: self.email,
                        icon: .init(systemName: "person"),
                        isFocused: self.isFocused,
                        borderColor: .darkPurple
                    )
                    .focused(self.$isFocused, equals: true)
                    .onTapGesture {
                        self.isFocused = true
                    }
                
            }
            .padding(.horizontal, .large)
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var email: String = ""
    iOS18TextSuggestions(email: $email)
    
}
