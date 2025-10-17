//
//  URLManagerViewModel.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import Foundation
import Combine
import SwiftUI

/// ViewModel for managing URL items
class URLManagerViewModel: ObservableObject {
    @Published var urlItems: [URLItem] = []
    
    private let storageService: URLStorageService
    
    init(storageService: URLStorageService = .shared) {
        self.storageService = storageService
        loadURLs()
    }
    
    // MARK: - Public Methods
    
    /// Loads URLs from storage
    func loadURLs() {
        urlItems = storageService.load()
    }
    
    /// Adds a new URL item
    func addURL(title: String, url: String) {
        let newItem = URLItem(title: title, url: url)
        urlItems.append(newItem)
        saveURLs()
    }
    
    /// Adds a divider
    func addDivider() {
        urlItems.append(URLItem.divider())
        saveURLs()
    }
    
    /// Deletes URL items at specified offsets
    func deleteURLs(at offsets: IndexSet) {
        urlItems.remove(atOffsets: offsets)
        saveURLs()
    }
    
    /// Moves URL items
    func moveURLs(from source: IndexSet, to destination: Int) {
        urlItems.move(fromOffsets: source, toOffset: destination)
        saveURLs()
    }
    
    /// Updates an existing URL item
    func updateURL(item: URLItem, title: String, url: String) {
        guard let index = urlItems.firstIndex(where: { $0.id == item.id }) else { return }
        urlItems[index].title = title
        urlItems[index].url = url
        saveURLs()
    }
    
    // MARK: - Private Methods
    
    private func saveURLs() {
        do {
            try storageService.save(items: urlItems)
        } catch {
            print("Error saving URLs: \(error)")
        }
    }
}

