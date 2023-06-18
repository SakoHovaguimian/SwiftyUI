//
//  HorizontalPagingView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/16/23.
//

import SwiftUI

struct User: Identifiable{
    var id = UUID().uuidString
    var userName: String
    var userImage: String
}

struct Carousel<Content: View,T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    
    // Trailing space changes the distance from the edge
    init(spacing: CGFloat = 15,trailingSpace: CGFloat = 48, index: Binding<Int>,items: [T],@ViewBuilder content: @escaping (T)->Content){
        
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View{
        
        GeometryReader{proxy in
            
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustMentWidth = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing){
                ForEach(list){item in
                    content(item)
                        .frame(width: proxy.size.width - trailingSpace, height: 100)
                }
            }
            .padding(.horizontal,spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustMentWidth : 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        currentIndex = index
                    })
                    .onChanged({ value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / width
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        .animation(.easeInOut, value: offset == 0)
    }
}

struct HorizontalPagingView: View {
    
    @State var currentIndex: Int = 0
    @State var users: [User] = [
        .init(userName: "Sako", userImage: "sunset"),
        .init(userName: "Sako", userImage: "sunset"),
        .init(userName: "Sako", userImage: "sunset"),
        .init(userName: "Sako", userImage: "sunset")
    ]
    
    var body: some View {
        
        VStack() {
            
            Carousel(index: $currentIndex, items: users) { user in
                
                GeometryReader{ proxy in
                    
                    let size = proxy.size
                    
                    Image(user.userImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width)
                        .cornerRadius(12)
                        .overlay(alignment: .bottomLeading) {
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                Spacer()
                                
                                Text(user.userName)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .padding([.leading], 24)
                                
                                HStack(spacing: 0) {
                                    
                                    Text("Image name: ")
                                        .font(.callout)
                                        .fontWeight(.light)
                                        .fontDesign(.rounded)
                                    
                                    Text(user.userImage)
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .fontDesign(.rounded)
                                    
                                }
                                .padding([.leading, .bottom], 24)
                                
                            }
                            
                        }
                }
            }
            .padding(.vertical,40)
            
            // Indicator dots
            HStack(spacing: 10){
                
                ForEach(users.indices,id: \.self){index in
                    
                    Circle()
                        .fill(Color.black.opacity(currentIndex == index ? 1 : 0.1))
                        .frame(width: 10, height: 10)
                        .scaleEffect(currentIndex == index ? 1.4 : 1)
                        .animation(.spring(), value: currentIndex == index)
                }
            }
            .padding(.bottom,40)
        }
        .onAppear {
            for index in 1...5{
                self.users.append(User(userName: "User\(index)", userImage: "sunset"))
            }
        }
    }
}
