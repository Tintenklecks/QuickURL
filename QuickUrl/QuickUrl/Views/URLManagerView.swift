//
//  URLManagerView.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import SwiftUI

/// View for managing URL items
struct URLManagerView: View {
    @ObservedObject var viewModel: URLManagerViewModel
    @State private var newTitle = ""
    @State private var newURL = ""
    @State private var editingItem: URLItem?
    @State private var showingAddSheet = false
    @State private var hoveredItemId: UUID?
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case title, url
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            if viewModel.urlItems.isEmpty {
                emptyStateView
            } else {
                urlListView
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: {
                    showingAddSheet = true
                    focusedField = .title
                }) {
                    Label("Add URL", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
                .help("Add a new URL (⌘N)")
                
                Button(action: {
                    viewModel.addDivider()
                }) {
                    Label("Add Divider", systemImage: "minus")
                }
                .help("Add a divider to organize your URLs")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            addEditSheet
        }
        .onChange(of: editingItem) { _, newValue in
            if newValue != nil {
                showingAddSheet = true
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "link.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text("No URLs Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first URL to get started")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: {
                showingAddSheet = true
                focusedField = .title
            }) {
                Label("Add Your First URL", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - URL List
    
    private var urlListView: some View {
        List {
            ForEach(Array(viewModel.urlItems.enumerated()), id: \.element.id) { index, item in
                if item.isDivider {
                    DividerRow(
                        item: item,
                        isHovered: hoveredItemId == item.id,
                        onDelete: { deleteItem(item) }
                    )
                    .id(item.id)
                    .listRowSeparator(.hidden)
                    .onHover { hovering in
                        hoveredItemId = hovering ? item.id : nil
                    }
                } else {
                    URLItemRow(
                        item: item,
                        isHovered: hoveredItemId == item.id,
                        colorGroup: sectionColorGroup(for: index),
                        onEdit: {
                            editingItem = item
                            newTitle = item.title
                            newURL = item.url
                        },
                        onOpen: {
                            openURL(item.url)
                        },
                        onDelete: {
                            deleteItem(item)
                        }
                    )
                    .listRowBackground(rowBackgroundColor(for: index))
                    .listRowSeparator(.hidden)
                    .onHover { hovering in
                        hoveredItemId = hovering ? item.id : nil
                    }
                }
            }
            .onMove(perform: viewModel.moveURLs)
            
            // Hint section
            if !viewModel.urlItems.isEmpty {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                        Text("Tip: Drag URLs to reorder, hover to delete")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.visible)
    }
    
    private func rowBackgroundColor(for index: Int) -> Color {
        // Count only non-divider items before this index
        var urlRowCount = 0
        for i in 0..<index {
            if !viewModel.urlItems[i].isDivider {
                urlRowCount += 1
            }
        }
        
        // Alternate backgrounds: clear for even, colored for odd
        return urlRowCount % 2 == 0 ? Color.clear : Color(nsColor: .unemphasizedSelectedContentBackgroundColor).opacity(0.3)
    }
    
    private func sectionColorGroup(for index: Int) -> Int {
        // Count dividers before this index to determine the section number
        var sectionNumber = 0
        for i in 0..<index {
            if viewModel.urlItems[i].isDivider {
                sectionNumber += 1
            }
        }
        return sectionNumber
    }
    
    // MARK: - Add/Edit Sheet
    
    private var addEditSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(editingItem == nil ? "Add New URL" : "Edit URL")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showingAddSheet = false
                    cancelEditing()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Form
            Form {
                Section {
                    LabeledContent("Title:") {
                        TextField("e.g., GitHub", text: $newTitle)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .title)
                    }
                    
                    LabeledContent("URL:") {
                        TextField("e.g., https://github.com", text: $newURL)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .url)
                    }
                } header: {
                    Text("URL Details")
                        .font(.headline)
                        .foregroundStyle(.primary)
                } footer: {
                    if !newURL.isEmpty && !isValidURL(newURL) {
                        Label("Please enter a valid URL starting with http:// or https://", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 8)
            }
            .formStyle(.grouped)
            .scrollDisabled(true)
            
            // Buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    showingAddSheet = false
                    cancelEditing()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(editingItem == nil ? "Add URL" : "Update URL") {
                    saveURL()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .frame(width: 500, height: 300)
        .onAppear {
            focusedField = .title
        }
    }
    
    // MARK: - Helper Properties
    
    private var canSave: Bool {
        !newTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        !newURL.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidURL(newURL)
    }
    
    // MARK: - Helper Methods
    
    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    private func saveURL() {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespaces)
        let trimmedURL = newURL.trimmingCharacters(in: .whitespaces)
        
        if let editing = editingItem {
            viewModel.updateURL(item: editing, title: trimmedTitle, url: trimmedURL)
        } else {
            viewModel.addURL(title: trimmedTitle, url: trimmedURL)
        }
        
        showingAddSheet = false
        cancelEditing()
    }
    
    private func cancelEditing() {
        editingItem = nil
        newTitle = ""
        newURL = ""
        focusedField = nil
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    private func deleteItem(_ item: URLItem) {
        guard let index = viewModel.urlItems.firstIndex(where: { $0.id == item.id }) else { return }
        viewModel.deleteURLs(at: IndexSet(integer: index))
    }
}

// MARK: - Divider Row

struct DividerRow: View {
    let item: URLItem
    let isHovered: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 1)
            
            // Delete button (shown on hover) - always reserve space
            ZStack {
                // Invisible placeholder to maintain consistent height
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 20))
                    .opacity(0)
                
                // Actual button (shown on hover)
                if isHovered {
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .help("Delete Divider")
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}

// MARK: - URL Item Row

/// Row view for a single URL item
struct URLItemRow: View {
    let item: URLItem
    let isHovered: Bool
    let colorGroup: Int
    let onEdit: () -> Void
    let onOpen: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconGradient)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "link")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(item.url)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer(minLength: 12)
            
            // Action buttons (shown on hover)
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: onOpen) {
                        Image(systemName: "arrow.up.forward.square")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .help("Open URL")
                    
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .help("Edit URL")
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.accentColor)
                    .help("Delete URL")
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rowBackground)
        )
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onOpen()
            }
        }
    }
    
    private var iconGradient: LinearGradient {
        let colors = iconColors(for: colorGroup)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var rowBackground: Color {
        if isPressed {
            return Color.accentColor.opacity(0.1)
        } else if isHovered {
            return Color(nsColor: .controlBackgroundColor)
        } else {
            return Color.clear
        }
    }
    
    private func iconColors(for group: Int) -> [Color] {
        let colorPairs: [[Color]] = [
            [.orange, .red],
            [.blue, .cyan],
            [.purple, .pink],
            [.green, .mint],
            [.indigo, .purple]
        ]
        return colorPairs[group % colorPairs.count]
    }
}

// MARK: - Preview

#Preview {
    URLManagerView(viewModel: URLManagerViewModel())
}

