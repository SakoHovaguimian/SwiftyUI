//
//  MenuOption.swift
//  SwiftUITest
//
//  Created by Sako Hovaguimian on 6/20/23.
//

import Foundation

enum MenuOption: Int, CaseIterable {
    
    case profile
    case lists
    case bookmarks
    case messages
    case notifications
    
    var title: String {
        switch self {
        case .profile: return "Profile"
        case .lists: return "Lists"
        case .bookmarks: return "Bookmarks"
        case .messages: return "Messages"
        case .notifications: return "Notifications"
        }
    }
    
    var iconName: String {
        switch self {
        case .profile: return "person"
        case .lists: return "list.bullet"
        case .bookmarks: return "bookmark"
        case .messages: return "bell"
        case .notifications: return "arrow.left.square"
        }
    }
    
}
