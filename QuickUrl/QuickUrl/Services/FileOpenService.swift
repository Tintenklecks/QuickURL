//
//  FileOpenService.swift
//  QuickUrl
//
//  Created by puco on 14.02.2026.
//

import Cocoa

/// Handles opening file:// URLs in a sandbox-safe way using security-scoped bookmarks
enum FileOpenService {

    /// Opens a file URL using stored bookmark data, or prompts the user via NSOpenPanel if needed.
    /// Returns updated bookmark data if a new bookmark was created.
    @MainActor
    static func openFileURL(_ url: URL, existingBookmark: Data?) -> Data? {
        // 1. Try existing bookmark
        if let bookmarkData = existingBookmark,
            let resolvedURL = resolveBookmark(bookmarkData)
        {
            let didAccess = resolvedURL.startAccessingSecurityScopedResource()
            NSWorkspace.shared.open(resolvedURL)
            if didAccess { resolvedURL.stopAccessingSecurityScopedResource() }
            return existingBookmark
        }

        // 2. No bookmark or stale — prompt user once via NSOpenPanel
        let panel = NSOpenPanel()
        panel.directoryURL = url.deletingLastPathComponent()
        panel.nameFieldStringValue = url.lastPathComponent
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.message = "Grant access to open \"\(url.lastPathComponent)\""
        panel.prompt = "Open"

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return existingBookmark
        }

        // 3. Open the file
        NSWorkspace.shared.open(selectedURL)

        // 4. Create bookmark for future access
        return createBookmark(for: selectedURL)
    }

    private static func resolveBookmark(_ data: Data) -> URL? {
        var isStale = false
        guard
            let url = try? URL(
                resolvingBookmarkData: data,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        else {
            return nil
        }
        return isStale ? nil : url
    }

    private static func createBookmark(for url: URL) -> Data? {
        try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
    }
}
