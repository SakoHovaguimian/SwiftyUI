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
                
                VStack(spacing: .appMedium) {
                    
                    section(title: "Videos")
                    section(title: "Photos")
                    section(title: "Links")
                    section(title: "Blogs")
                    
                }
                .padding(.top, .medium)
                
            }
            
        }

    }
    
    private func section(title: String) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(title)
                .fontWeight(.semibold)
                .font(.body)
                .fontDesign(.rounded)
            
            ScrollView(.horizontal) {
                
                HStack(spacing: .appSmall) {
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkGreen)
                        .frame(width: 300, height: 200)
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkBlue)
                        .frame(width: 300, height: 200)
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkPurple)
                        .frame(width: 300, height: 200)
                    
                    RoundedRectangle(cornerRadius: .appLarge)
                        .fill(.darkYellow)
                        .frame(width: 300, height: 200)
                    
                }
                
            }
            
        }
        .safeAreaPadding(.horizontal, .appMedium)
        
    }
    
}

#Preview {
    SomeTestView2()
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
