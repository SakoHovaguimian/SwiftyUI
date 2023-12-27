//
//  DropDownView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 12/27/23.
//

import SwiftUI

struct DropDownView: View {
    
    let title: String
    let placeholder: String
    let options: [String]
    
    @State private var isExpaneded: Bool = false
    @Binding var selection: String?
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            // Title
            
            Text(self.title)
                .font(.footnote)
                .foregroundStyle(.gray)
                .opacity(0.8)
            
            containerView()
            
        }
        
    }
    
    @ViewBuilder func containerView() -> some View {
        
        VStack {
            
            // Header
            
            containerHeader()
            
            // ExpandedView
            
            if self.isExpaneded {
                expandedView()
            }
            
        }
        .background(.white)
        .clipShape(.rect(cornerRadius: 10))
        .shadow(radius: 4)
        
    }
    
    @ViewBuilder func containerHeader() -> some View {
        
        HStack {
            
            Text(self.selection ?? self.placeholder)
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .rotationEffect(.degrees(self.isExpaneded ? -180 : 0))
            
        }
        .frame(height: 40)
        .background(.white)
        .padding(.horizontal)
        .onTapGesture {
            
            withAnimation(.snappy) {
                self.isExpaneded.toggle()
            }
            
        }
        
    }
    
    @ViewBuilder func expandedView() -> some View {
     
        VStack {
            
            ForEach(self.options, id: \.self) { option in
                
                // ItemView
                
                HStack {
                    
                    Text(option)
                        .foregroundStyle(selection == option ? .black : .gray)
                    
                    Spacer()
                    
                    if self.selection == option {
                        
                        Image(systemName: "checkmark")
                            .font(.subheadline)
                        
                    }
                    
                }
                .frame(height: 40)
                .padding(.horizontal)
                .onTapGesture {
                    
                    withAnimation(.snappy) {
                        
                        self.selection = option
                        self.isExpaneded = false
                        
                    }
                    
                }
                
            }
            
        }
        .transition(.move(edge: .bottom))
        
    }
    
}

#Preview {
    
    @State var selectedPokemon: String? = nil
    
    return DropDownView(
        title: "Pokemon",
        placeholder: "Starter",
        options: [
            "Charmander",
            "Bulbasaur",
            "Squirtle",
            "Pickachu",
            "Pidgey",
            "Caterpie",
            "Weedle",
            "Diglet"
        ],
        selection: $selectedPokemon
    )
    .frame(width: 140)
    
}


/// Supports Scrolling
/// Support Scroll Proxy for scrolling to top if the user has made a selection
struct DropDownViewV2: View {
    
    let title: String
    let placeholder: String
    let options: [String]
    
    @State private var isExpaneded: Bool = false
    @Binding var selection: String?
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            // Title
            
            Text(self.title)
                .font(.footnote)
                .foregroundStyle(.gray)
                .opacity(0.8)
            
            containerView()
            
        }
        
    }
    
    @ViewBuilder func containerView() -> some View {
        
        VStack {
            
            // Header
            
            containerHeader()
            
            // ExpandedView
            
            if self.isExpaneded {
                expandedView()
            }
            
        }
        .background(.white)
        .clipShape(.rect(cornerRadius: 10))
        .shadow(radius: 4)
        
    }
    
    @ViewBuilder func containerHeader() -> some View {
        
        HStack {
            
            Text(self.selection ?? self.placeholder)
            
            Spacer()
            
            Image(systemName: "chevron.down")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .rotationEffect(.degrees(self.isExpaneded ? -180 : 0))
            
        }
        .frame(height: 40)
        .background(.white)
        .padding(.horizontal)
        .onTapGesture {
            
            withAnimation(.snappy) {
                self.isExpaneded.toggle()
            }
            
        }
        
    }
    
    @ViewBuilder func expandedView() -> some View {
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                VStack {
                    
                    ForEach(self.options, id: \.self) { option in
                        
                        // ItemView
                        
                        optionView(
                            option,
                            proxy: proxy
                        )
                        
                    }
                    
                }
                
            }
            
        }
        .transition(.move(edge: .bottom))
        
    }
    
    @ViewBuilder func optionView(_ option: String,
                                 proxy: ScrollViewProxy) -> some View {
        
        HStack {
            
            Text(option)
                .foregroundStyle(selection == option ? .black : .gray)
            
            Spacer()
            
            if self.selection == option {
                
                Image(systemName: "checkmark")
                    .font(.subheadline)
                
            }
            
        }
        .id(option)
        .background(.white)
        .frame(height: 30)
        .padding(.horizontal)
        .onTapGesture {
            
            withAnimation(.snappy) {
                
                self.selection = option
                self.isExpaneded = false
                
                proxy.scrollTo(
                    option,
                    anchor: .top
                )
                
            }
            
        }
        
    }
    
}

#Preview {
    
    @State var selectedPokemon: String? = nil
    
    return DropDownView(
        title: "Pokemon",
        placeholder: "Starter",
        options: [
            "Charmander",
            "Bulbasaur",
            "Squirtle",
            "Pickachu",
            "Pidgey",
            "Caterpie",
            "Weedle",
            "Diglet"
        ],
        selection: $selectedPokemon
    )
    .frame(width: 140)
    
}

#Preview {
    
    @State var selectedPokemon: String? = nil
    
    return DropDownViewV2(
        title: "Pokemon V2",
        placeholder: "Starter",
        options: [
            "Charmander",
            "Bulbasaur",
            "Squirtle",
            "Pickachu",
            "Pidgey",
            "Caterpie",
            "Weedle",
            "Diglet"
        ],
        selection: $selectedPokemon
    )
    .frame(width: 140)
    .frame(maxHeight: 300)
    
}
