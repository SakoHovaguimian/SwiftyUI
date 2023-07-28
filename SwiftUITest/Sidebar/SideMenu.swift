//
//  SideMenu.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 7/25/23.
//

import SwiftUI

struct SideMenu<Content: View>: View {
    
    @Binding var isSidebarVisible: Bool
    private let width: CGFloat
    private let content: Content
    
    public init(
        isSidebarVisible: Binding<Bool>,
        width: CGFloat = UIScreen.main.bounds.size.width * 0.6,
        @ViewBuilder content: () -> Content) {
            
            self._isSidebarVisible = isSidebarVisible
            self.width = width
            self.content = content()
            
        }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { _ in
                EmptyView()
            }
            .background(.black.opacity(0.6))
            .opacity(self.isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0), value: self.isSidebarVisible)
            .onTapGesture {
                self.isSidebarVisible.toggle()
            }
            
            wrappedContent
            
        }
        .edgesIgnoringSafeArea(.all)
        
        
    }
    
    var wrappedContent: some View {
        
        HStack(alignment: .top) {
            
            self.content
                .frame(width: self.width)
                .offset(x: isSidebarVisible ? 0 : -self.width)
                .animation(.default, value: isSidebarVisible)
            
            Spacer()
            
        }
        
    }
    
}

struct SideMenuTestView: View {
    
    @State private var isSideBarOpened = false
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(0..<8) { _ in
                        AsyncImage(
                            url: URL(
                                string: "https://picsum.photos/600"
                            )) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 240)
                            } placeholder: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.gray.opacity(0.6))
                                        .frame(height: 240)
                                    ProgressView()
                                }
                            }
                            .aspectRatio(3 / 2, contentMode: .fill)
                            .cornerRadius(12)
                            .padding(.vertical)
                            .shadow(radius: 11)
                    }
                }
                .toolbar {
                    
                    Button {
                        self.isSideBarOpened.toggle()
                    } label: {
                        Label("Toggle SideBar",
                              systemImage: "line.3.horizontal.circle.fill")
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
            }

            SideMenu(isSidebarVisible: $isSideBarOpened,
                     content: {
//                HStack(alignment: .top) {
                    
                    ZStack(alignment: .top) {
                        Color.yellow
                            .ignoresSafeArea()
//                    }
                    
//                    Spacer()
                    
                }
            })
        }
        
    }
    
}

#Preview {
    SideMenuTestView()
}
