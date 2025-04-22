////
////  OldMessageView.swift
////  SwiftyUI
////
////  Created by Sako Hovaguimian on 7/2/24.
////
//
////
////  MessageView.swift
////  GentlePath
////
////  Created by Sako Hovaguimian on 4/21/24.
////
//
//import SwiftUI
//
//struct MessageView: View {
//    
//    struct Message {
//        
//        let message: String
//        let isSender: Bool
//        
//    }
//    
//    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
//    @StateObject private var keyboardManager = KeyboardManager()
//    @State private var messages: [Message] = []
//    
//    @State private var messageFrame: CGRect = .zero // isn't being used
//    @State private var text: String = ""
//        
//    var body: some View {
//        
//        ZStack(alignment: .bottom) {
//            
//            Color.white
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                
//                // Turns out that scrollView cannot be raised when a keyboard is presented
//                // That's by design. Use the rectangle and overlay the scrollView
//                // That way the system lifts up the screen for you
//                
//                Rectangle()
//                    .frame(maxHeight: .infinity)
//                    .overlay {
//                        
//                        ScrollViewReader { scrollReader in
//                            
//                            VStack(spacing: 0) {
//                                
//                                ScrollView {
//                                    
//                                    LazyVStack(spacing: 8) {
//                                        
//                                        ForEach(self.messages, id: \.message) { message in
//                                            messageView(message: message)
//                                                .padding(.bottom, message.message == self.messages.last?.message ? 16 : 0)
//                                        }
//                                        
//                                    }
//                                    .readingFrame(onChange: { frame in
//                                        self.messageFrame = frame
//                                    })
//                                    //                            .padding(.top, self.messageFrame.height > UIScreen.main.bounds.height / 1.5 ? -(self.keyboardManager.keyboardHeight) : 0)
//                                    .onChange(of: self.keyboardManager.isVisible) { oldValue, newValue in
//                                        
//                                        if newValue {
//                                            
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                                                withAnimation {
//                                                    scrollReader.scrollTo(messages.last?.message, anchor: .bottom)
//                                                }
//                                            })
//                                            
//                                        }
//                                        
//                                    }
//                                    
//                                }
//                                .scrollDismissesKeyboard(.immediately)
//                                sendMessageView(proxy: scrollReader)
//                                
//                            }
//                            .onAppear {
//                                onAppear()
//                            }
//                            
//                        }
//                        .frame(maxHeight: .infinity)
//                        
//                    }
//                
//            }
//            
//        }
//        
//    }
//    
//    func onAppear() {
//        
//        self.tabBarNavigationService.shouldShowTabBar(false)
//        
//        // If this isn't here then the original messages load, but do not animate
//        // this could be the desired effect.
//        
//        withAnimation {
//            
//            self.messages.append(contentsOf: [
//                .init(message: "Hi, how r you?", isSender: false),
//                .init(message: "Good, & you?", isSender: true),
//                .init(message: "I'm fine. I found out that i have to do some work today, which sucks, but whatever", isSender: false),
//                .init(message: "oof", isSender: true),
//                .init(message: "I'm fine. I found out that i have to do some work today, which sucks, but whateve2r", isSender: false),
//                .init(message: "oo3f", isSender: true),
//                .init(message: "I'11m fine. I found out that i have to do some work today, which sucks, but whatever", isSender: false),
//                .init(message: "oo1f", isSender: true),
//                .init(message: "oo2f", isSender: true),
//                .init(message: "oo6f", isSender: true),
//                .init(message: "I'11m fine. I found out that i have to do some work today, which sucks, but aasd", isSender: false),
//                .init(message: "I'11m fine. I sdf out that i have to do some work today, which sucks, but whatever", isSender: false),
//                .init(message: "fsddsf'11m fine. I found out that i have to do some work today, which sucks, but whatever", isSender: false),
//                .init(message: "I'f. I found out that i have to do some work today, which sucks, but whatever", isSender: false),
//            ])
//            
//        }
//        
//    }
//    
//    func messageView(message: Message) -> some View {
//        
//        HStack {
//            
//            Text(message.message)
//                .multilineTextAlignment(.leading)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(.blue)
//                .foregroundStyle(.white)
//                .clipShape(.rect(cornerRadius: 16))
//                .padding(.horizontal, 16)W
//                .frame(
//                    maxWidth: UIScreen.main.bounds.width / 1.8,
//                    alignment: message.isSender ? .trailing : .leading
//                )
//                .onTapGesture {
//                    withAnimation(.spring) {
//                        self.messages.removeAll { $0.message == message.message}
//                    }
//                }
//            
//        }
//        .frame(
//            maxWidth: .infinity,
//            alignment: message.isSender ? .trailing : .leading
//        )
//        .transition(.asymmetric(
//            insertion: .move(edge: .bottom).combined(with: .opacity),
//            removal: .opacity
//        ))
//        .id(message.message)
//        
//    }
//    
//    func sendMessageView(proxy: ScrollViewProxy) -> some View {
//        
//        VStack(spacing: 0) {
//            
//            HStack {
//                
//                Spacer()
//                
//                Circle()
//                    .fill(.gray)
//                    .frame(width: 32, height: 32)
//                    .asButton {
//                        
//                        self.dismissKeyboard()
//                        
//                        withAnimation {
//                            scrollToBottom(proxy: proxy)
//                        }
//                        
//                    }
//                    .animation(.bouncy, value: self.keyboardManager.isVisible)
//                
//                TextField("1", text: $text, prompt: Text("Asome"), axis: .vertical)
//                    .textFieldStyle(.roundedBorder)
//                    .padding(.top, 12)
//                    .padding(.bottom, 16)
//                    .lineLimit(5, reservesSpace: false)
//                
//                CircularIconView(
//                    foregroundColor: .white,
//                    backgroundColor: .blue,
//                    size: 32,
//                    systemImage: "paperplane.fill"
//                )
//                .asButton {
//                    
//                    let message = Message(
//                        message: self.text,
//                        isSender: .random()
//                    )
//                    
//                    self.messages.append(message)
//                    self.text = ""
//                    
//                    scrollToBottom(proxy: proxy)
//                    
//                }
//                
//                Spacer()
//                
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.horizontal, 16)
//            
//        }
//        .frame(minHeight: 50)
//        .background(.white)
//        .clipped()
//        .ignoresSafeArea()
//        
//    }
//    
//    private func scrollToBottom(proxy: ScrollViewProxy) {
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
//            
//            withAnimation {
//                proxy.scrollTo(self.messages.last?.message, anchor: .bottom)
//            }
//            
//        })
//        
//    }
//    
//}
//
//#Preview {
//    
//    MessageView()
//        .mockServicesForPreviews()
//    
//}
