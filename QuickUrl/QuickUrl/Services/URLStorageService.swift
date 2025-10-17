//
//  URLStorageService.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import Foundation

/// Service responsible for persisting and retrieving URL items
class URLStorageService {
    static let shared = URLStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "savedURLItems"
    
    private init() {}
    
    /// Saves URL items to UserDefaults
    func save(items: [URLItem]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(items)
        userDefaults.set(data, forKey: storageKey)
    }
    
    /// Loads URL items from UserDefaults
    func load() -> [URLItem] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return defaultURLItems()
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode([URLItem].self, from: data)
        } catch {
            print("Error decoding URL items: \(error)")
            return defaultURLItems()
        }
    }
    
    /// Returns default URL items for first launch
    private func defaultURLItems() -> [URLItem] {
        return [
            URLItem(title: "Google", url: "https://www.google.com"),
            URLItem(title: "GitHub", url: "https://github.com"),
            URLItem.divider(),
            URLItem(title: "Stack Overflow", url: "https://stackoverflow.com")
        ]
    }
}

