//
//  MessageView.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 6/25/24.
//

import SwiftUI

struct MessageView: View {
    
    let username: String
    let message: String
    let avatarImage: Image
    let isSender: Bool
    
    var body: some View {
    
        AppCardView {
            
            VStack(alignment: .leading) {
                
                HStack {
                    
                    AvatarView(
                        name: self.username,
                        foregroundColor: .darkBlue,
                        size: 32
                    )
                    
                    Text(self.username)
                        .appFont(with: .title(.t1))
                    
                    if self.isSender {
                        
                        Spacer()
                        
                        Text("OP")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.darkBlue)
                            .clipShape(.capsule)
                        
                    }
                    
                }
                
                Text(self.message)
                    .appFont(with: .body(.b1))
                
            }
            
        }
        
    }
    
}

#Preview {
    
    @Previewable @State var currentOffset: CGRect = .zero
    
    VStack(spacing: .zero) {
        
        NavBarView(
            navBarStyle: .standard(
                .init(
                    title: "NavBar",
                    leftButtonView:
                        
                        Image(systemName: currentOffset.minY > 100 ? "person.fill" : "person" )
                        .foregroundStyle(.white)
                        .padding(.small)
                        .background(.darkBlue)
                        .clipShape(.circle)
                        .contentTransition(.symbolEffect(.replace))
                        .asAnyView()
                        
                        
                )),
            backgroundStyle: .material(.ultraThinMaterial)
        )
        
        ScrollView {
            
            VStack {
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: true
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
                MessageView(
                    username: "Sako Hovaguimian",
                    message: "Does anyone know how to remove some stains from the carpet?",
                    avatarImage: Image(.image3),
                    isSender: false
                )
                
            }
            .padding(.top, .large)
            .padding(.horizontal, .medium)
            
        }
        .onScrollGeometryChange(for: CGRect.self) { geo in
            return geo.bounds
        } action: { oldValue, newValue in
            currentOffset = newValue
        }
        .animation(.spring, value: currentOffset)
        .overlay {
            
            Text("\(currentOffset.minY)")
            
        }
        
    }
    
}

struct SomeTestView: View {

    @State var currentOffset: CGRect = .zero
    
    var body: some View {
        
        VStack(spacing: .zero) {
            
            NavBarView(
                navBarStyle: .standard(
                    .init(
                        title: "NavBar",
                        leftButtonView:
                            
                            Image(systemName: currentOffset.minY > 100 ? "person.fill" : "person" )
                            .foregroundStyle(.white)
                            .padding(.small)
                            .background(.darkBlue)
                            .clipShape(.circle)
                            .contentTransition(.symbolEffect(.replace))
                            .asButton {
                                print("Tapping Something")
                            }
                            .asAnyView()
                        
                        
                    )),
                backgroundStyle: .material(.ultraThinMaterial)
            )
            
            ScrollView {
                
                VStack {
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?, Does anyone know how to remove some stains from the carpet? ",
                        avatarImage: Image(.image3),
                        isSender: true
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                    MessageView(
                        username: "Sako Hovaguimian",
                        message: "Does anyone know how to remove some stains from the carpet?",
                        avatarImage: Image(.image3),
                        isSender: false
                    )
                    
                }
                .padding(.top, .large)
                .padding(.horizontal, .medium)
                
            }
            .onScrollGeometryChange(for: CGRect.self) { geo in
                return geo.bounds
            } action: { oldValue, newValue in
                currentOffset = newValue
            }
            .overlay {
                
                Text("\(currentOffset.minY)")
                
            }
            
        }
        
    }
    
}

import SwiftUI

struct SomeTestView2: View {
    
    @State private var selectedFilter: String?
    
    var body: some View {
    
        BaseHeaderScrollView(horizontalPadding: .none) {
            
            NavBarView(
                navBarStyle: .standard(
                    .init(
                        title: "GentlePath",
                        leftButtonView:
                            
                            Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                            .padding(.small)
                            .background(.black)
                            .clipShape(.circle)
                            .contentTransition(.symbolEffect(.replace))
                            .asButton {
                                print("Tapping Something")
                            }
                            .asAnyView()
                        
                        
                    )),
                backgroundStyle: .color(.white)
            )
            
        } scrollViewContent: {
            
            VStack {
                
                SearchBar()
                
                FiltersViewPreview2(
                    filters: [
                        "Behavioral",
                        "Speech",
                        "Spectrum",
                        "Autism",
                        "Feeding",
                        "Teaching",
                        "Skills"
                    ],
                    selectedFilter: self.$selectedFilter
                )
                .padding(.top, .xSmall)
                
                VStack(spacing: .appMedium) {
                    
                    section(title: "Blogs", smallSize: true)
                    section(title: "Links", smallSize: true)
                    section(title: "Videos")
                    section(title: "Photos")
                    
                }
                .padding(.top, .medium)
                
            }
            
        }

    }
    
    private func section(title: String,
                         smallSize: Bool = false) -> some View {
        
        let size: CGSize = smallSize
        ? CGSize(width: 150, height: 200)
        : CGSize(width: 300, height: 200)
        
        return VStack(alignment: .leading) {
            
            Text(title)
                .fontWeight(.semibold)
                .font(.body)
                .fontDesign(.rounded)
            
            ScrollView(.horizontal) {
                
                HStack(spacing: .appSmall) {
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkGreen)
                        .frame(width: size.width, height: size.height)
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkBlue)
                        .frame(width: size.width, height: size.height)
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkPurple)
                        .frame(width: size.width, height: size.height)
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkYellow)
                        .frame(width: size.width, height: size.height)
                    
                }
                
            }
            
        }
        .safeAreaPadding(.horizontal, .appMedium)
        
    }
    
}

#Preview {
    SomeTestView2()
}

// THIS IS A LOCAL VERSION OF FILTERS VIEW

//
//  ScrollFilters.swift
//  SwiftUIDemo
//
//  Created by Sako Hovaguimian on 4/8/24.
//

import SwiftUI

struct FilterView2: View {
    
    let title: String
    let isSelected: Bool
    
    var body: some View {
        
        HStack {
            
            Text(self.title)
                .font(.caption)
                .foregroundStyle(self.isSelected ? .white : .black)
            
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background {
            
            ZStack {
                
                Capsule(style: .circular)
                    .fill(.black.opacity(0.8))
                    .opacity(self.isSelected ? 1 : 0)
                
                Capsule(style: .circular)
                    .strokeBorder(self.isSelected ? .black : .black.opacity(0.3), lineWidth: 1)

            }
            
        }
        
    }
    
}

struct FiltersView2: View {
    
    var filters: [String]
    var selectedFilter: String? = nil
    var onFilterTapped: (String) -> ()
    var onCloseTapped: () -> ()
    
    @State private var isUserInteractionEnabled: Bool = true
    
    var body: some View {
        
        ScrollView(.horizontal) {
            
            HStack {
                
                if self.selectedFilter != nil {
                    
                    Image(systemName: "xmark")
                        .padding(6)
                        .background {
                            Circle()
                                .stroke(.black)
                        }
                        .transition(AnyTransition(.move(edge: .leading)).combined(with: .opacity))
                        .onTapGesture {
                            
                            withAnimation(.smooth) {
                                onCloseTapped()
                            }
                            
                        }
                    
                }
                
                ForEach(self.filters, id: \.self) { filter in
                    
                    if selectedFilter == nil || selectedFilter == filter {
                        
                        FilterView2(
                            title: filter,
                            isSelected: selectedFilter == filter
                        )
                        .onTapGesture {
                            
                            throttleTouch()
                            onFilterTapped(filter)
                            
                        }
                        
                    }
                    
                }
                
            }
            .allowsHitTesting(self.isUserInteractionEnabled)
            .animation(.bouncy(duration: 0.5), value: selectedFilter)
            .padding(.leading, 16)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func throttleTouch() {
        
        self.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            self.isUserInteractionEnabled = true
        })
        
    }

}

struct FiltersViewPreview2: View {
    
    var filters = ["Sako", "Mitch", "KC", "Michael"]
    @Binding var selectedFilter: String?
    
    var body: some View {
        
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                FiltersView2(filters: filters,
                selectedFilter: selectedFilter) { filter in
                    self.selectedFilter = filter
                } onCloseTapped: {
                    self.selectedFilter = nil
                }

            }
            
        }
        
    }
    
}

