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
            AddEditURLSheet(
                title: $newTitle,
                url: $newURL,
                editingItem: $editingItem,
                isPresented: $showingAddSheet,
                focusedField: $focusedField,
                onSave: { title, url, item in
                    if let editing = item {
                        viewModel.updateURL(item: editing, title: title, url: url)
                    } else {
                        viewModel.addURL(title: title, url: url)
                    }
                }
            )
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
    
    // MARK: - Helper Methods
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    private func deleteItem(_ item: URLItem) {
        guard let index = viewModel.urlItems.firstIndex(where: { $0.id == item.id }) else { return }
        viewModel.deleteURLs(at: IndexSet(integer: index))
    }
}

// MARK: - Preview

#Preview {
    URLManagerView(viewModel: URLManagerViewModel())
}
