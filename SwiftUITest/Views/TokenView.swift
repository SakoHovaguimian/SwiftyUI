//
//  TokenView.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/18/23.
//

import SwiftUI

struct ChipDemoContentView: View {
    
    @State private var selectedToken: Token?
    @State private var selectedTokens: [Token] = []
    
    @State private var tokens: [Token] = [
        .init(systemImage: "heart.fill", title: "Favorites"),
        .init(systemImage: "heart.fill", title: "Favorites"),
        .init(systemImage: "heart.fill", title: "Words"),
        .init(systemImage: "heart.fill", title: "RPG"),
        .init(systemImage: "heart.fill", title: "Test"),
        .init(systemImage: "heart.fill", title: "The Adventures of raindance maggie"),
        .init(systemImage: "heart.fill", title: "Test"),
        .init(systemImage: "heart.fill", title: "Test"),
    ]
    
    var body: some View {
        
        VStack {
            
            Text("Single Select")
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .font(.largeTitle)
            
            TokenListView(tokens: tokens, selectedToken: $selectedToken, padding: 24)
            
            if let selectedToken {
                Text(selectedToken.title)
                    .padding(.bottom, 32)
            }
            
            Text("Multi Select")
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .font(.largeTitle)
            
            TokenListView(mode: .multi, tokens: tokens, selectedTokens: $selectedTokens, padding: 24)
            Text(self.selectedTokens.map({ $0.title }).joined(separator: ","))
                .padding([.horizontal, .bottom], 32)
            
        }
        .background(LinearGradient(colors: [Color.pink, Color.purple], startPoint: .bottomLeading, endPoint: .topTrailing))
        
    }
    
}

struct Token: Identifiable {
    
    let id = UUID()
    let systemImage: String
    let title: String
    
}

struct TokenListView: View {
    
    enum SelectionType {
        
        case single
        case multi
        
    }
    
    var mode: SelectionType
    var tokens: [Token]
    var padding: CGFloat = 0
    
    @Binding var selectedToken: Token?
    @Binding var selectedTokens: [Token]
    
    init(mode: SelectionType = .single,
         tokens: [Token],
         selectedToken: Binding<Token?> = .constant(nil),
         selectedTokens: Binding<[Token]> = .constant([]),
         padding: CGFloat = 0) {
        
        self.mode = mode
        self.tokens = tokens
        self._selectedToken = selectedToken
        self._selectedTokens = selectedTokens
        self.padding = padding
        
    }
    
    var body: some View {
        
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        ZStack(alignment: .topLeading) {
            
            Color.clear // Don't know why this fixes everthing?...
            
            ForEach(self.tokens) { token in
                
                TokenView(
                    token: token,
                    isSelected: isTokenSelected(token)
                )
                .onTapGesture {
                    
                    switch self.mode {
                    case .single: handleSingeSelection(token)
                    case .multi: handleMultiSelection(token)
                    }
                    
                }
                
                .padding(.all, 5)
                .alignmentGuide(.leading) { dimension in
                    
                    if (abs(width - dimension.width) > (UIScreen.main.bounds.width - (self.padding * 2))) {
                        width = 0
                        height -= dimension.height
                    }
                    
                    let result = width
                    if token.id == self.tokens.last!.id {
                        width = 0
                    } else {
                        width -= dimension.width
                    }
                    return result
                }
                .alignmentGuide(.top) { dimension in
                    let result = height
                    if token.id == self.tokens.last!.id {
                        height = 0
                    }
                    return result
                }
                
            }
        }
        .padding(.horizontal, self.padding)
    }
    
    private func handleSingeSelection(_ token: Token) {
        
        if self.selectedToken?.id == token.id {
            self.selectedToken = nil
        }
        else {
            self.selectedToken = token
        }
        
    }
    
    private func handleMultiSelection(_ token: Token) {
        
        if self.selectedTokens.contains(where: { $0.id == token.id }) {
            self.selectedTokens.removeAll { $0.id == token.id }
        }
        else {
            self.selectedTokens.append(token)
        }
        
    }
    
    private func isTokenSelected(_ token: Token) -> Bool {
        
        switch self.mode {
        case .single:
            
            return (token.id == selectedToken?.id)
            
        case .multi:
            
            return self.selectedTokens.contains(where: { $0.id == token.id })
            
        }
        
    }
    
}


struct TokenView: View {
    
    let token: Token
    let isSelected: Bool
    
    var body: some View {
        
        HStack {
            
            Image.init(systemName: self.token.systemImage).font(.title3)
            Text(self.token.title).font(.title3).lineLimit(1)
            
        }
        .padding(.all, 10)
        .shadow(radius: 11)
        .foregroundColor(self.isSelected ? .white : .red.opacity(0.9))
        .background(self.isSelected ? .red.opacity(0.9) : Color.white)
        .cornerRadius(40)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(.red.opacity(0.9), lineWidth: 1.5)
            
        )
        
    }
    
}
