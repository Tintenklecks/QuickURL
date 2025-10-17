//
//  URLItem.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import Foundation

/// Model representing a URL item or divider in the menu
struct URLItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var url: String
    var isDivider: Bool
    
    init(id: UUID = UUID(), title: String, url: String, isDivider: Bool = false) {
        self.id = id
        self.title = title
        self.url = url
        self.isDivider = isDivider
    }
    
    /// Creates a divider item
    static func divider() -> URLItem {
        URLItem(title: "", url: "", isDivider: true)
    }
    
    /// Validates if the URL is valid
    var isValid: Bool {
        if isDivider { return true }
        guard !url.isEmpty else { return false }
        return URL(string: url) != nil
    }
}

