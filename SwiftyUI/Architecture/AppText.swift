//
//  AppText.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 9/10/24.
//


import SwiftUI

// MARK: - View Models

struct AppText: Codable {
    let fontSize: CGFloat
    let textColor: String
    let text: String
}

struct MyAppButton: Codable {
    let fontSize: CGFloat
    let textColor: String
    let text: String
    let cornerRadius: CGFloat
}

struct CardView: Codable {
    let backgroundColor: String
    let cornerRadius: CGFloat
    let padding: CGFloat
}

struct AppSpacer: Codable {
    let height: CGFloat
}

// MARK: - View Type Enum

enum ViewType: String, Codable {
    case text
    case button
    case card
    case spacer
}

// MARK: - Server Response Model

struct ServerResponseItem: Codable {
    let type: ViewType
    let payload: ViewPayload
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
    
    init(type: ViewType, payload: ViewPayload) {
        self.type = type
        self.payload = payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ViewType.self, forKey: .type)
        
        let payloadContainer = try container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .payload)
        switch type {
        case .text:
            payload = .text(try AppText(from: payloadContainer.superDecoder()))
        case .button:
            payload = .button(try MyAppButton(from: payloadContainer.superDecoder()))
        case .card:
            payload = .card(try CardView(from: payloadContainer.superDecoder()))
        case .spacer:
            payload = .spacer(try AppSpacer(from: payloadContainer.superDecoder()))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        var payloadContainer = container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .payload)
        switch payload {
        case .text(let appText):
            try appText.encode(to: payloadContainer.superEncoder())
        case .button(let appButton):
            try appButton.encode(to: payloadContainer.superEncoder())
        case .card(let cardView):
            try cardView.encode(to: payloadContainer.superEncoder())
        case .spacer(let spacer):
            try spacer.encode(to: payloadContainer.superEncoder())
        }
    }
}

// MARK: - View Payload Enum

enum ViewPayload {
    case text(AppText)
    case button(MyAppButton)
    case card(CardView)
    case spacer(AppSpacer)
}

// MARK: - Dynamic Coding Keys

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

// MARK: - View Factory

struct ViewFactory {
    static func createView(from item: ServerResponseItem) -> some View {
        switch item.payload {
        case .text(let appText):
            return AnyView(Text(appText.text)
                .font(.system(size: appText.fontSize))
                .foregroundColor(Color(hex: appText.textColor)))
        case .button(let appButton):
            return AnyView(Button(action: {
                print("jsdfhgjkhdfk")
            }) {
                Text(appButton.text)
                    .font(.system(size: appButton.fontSize))
                    .foregroundColor(Color(hex: appButton.textColor))
            }
            .cornerRadius(appButton.cornerRadius))
        case .card(let cardView):
            return AnyView(RoundedRectangle(cornerRadius: cardView.cornerRadius)
                .fill(Color(hex: cardView.backgroundColor))
                .padding(cardView.padding)
                .frame(height: 200))
        case .spacer(let spacer):
            return AnyView(Spacer(minLength: spacer.height))
        }
    }
}

// MARK: - Main View

struct DynamicContentView: View {
    let serverResponse: [ServerResponseItem]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(serverResponse.indices, id: \.self) { index in
                    ViewFactory.createView(from: serverResponse[index])
                }
            }
        }
    }
}

#Preview {
    
    DynamicContentView(serverResponse: [
        
        .init(type: .text, payload: .text(.init(
            fontSize: 24,
            textColor: "#43f32b",
            text: "ioeru9toeuruot"
        ))),
        
        .init(type: .button, payload: .button(
            .init(fontSize: 48,
                  textColor: "#181e48",
                  text: "Button",
                  cornerRadius: 12
                 ))),
        .init(type: .card, payload: .card(.init(
            backgroundColor: "#86a0cf",
            cornerRadius: 11,
            padding: 32
        )))
    ])
    
}
