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
    @State private var isEditMode = false
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
                    Label(
                        "Add Divider",
                        systemImage:
                            "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"
                    )
                    .rotationEffect(.degrees(90))
                    .scaleEffect(0.7)
                }
                .help("Add a divider to organize your URLs")

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                    }
                }) {
                    Label(
                        "Reorder",
                        systemImage: isEditMode ? "checkmark.circle.fill" : "arrow.up.arrow.down")
                }
                .help(isEditMode ? "Done reordering" : "Reorder URLs via drag & drop")
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
        .onExitCommand {
            NSApp.keyWindow?.close()
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
            ForEach(viewModel.urlItems) { item in
                let index = viewModel.urlItems.firstIndex(where: { $0.id == item.id }) ?? 0
                if item.isDivider {
                    HStack(spacing: 8) {
                        if isEditMode {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                        }
                        DividerRow(
                            item: item,
                            isHovered: hoveredItemId == item.id,
                            onDelete: { deleteItem(item) }
                        )
                    }
                    .id(item.id)
                    .listRowSeparator(.hidden)
                    .onHover { hovering in
                        hoveredItemId = hovering ? item.id : nil
                    }
                } else {
                    HStack(spacing: 8) {
                        if isEditMode {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                        }
                        URLItemRow(
                            item: item,
                            isHovered: isEditMode ? false : hoveredItemId == item.id,
                            colorGroup: sectionColorGroup(for: index),
                            onEdit: {
                                editingItem = item
                                newTitle = item.title
                                newURL = item.url
                            },
                            onOpen: {
                                if !isEditMode {
                                    openURL(item)
                                }
                            },
                            onDelete: {
                                deleteItem(item)
                            }
                        )
                    }
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
                        Text(
                            isEditMode
                                ? "Drag the ☰ handles to reorder items"
                                : "Tip: Hover to edit or delete items"
                        )
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
        return urlRowCount % 2 == 0
            ? Color.clear : Color(nsColor: .unemphasizedSelectedContentBackgroundColor).opacity(0.3)
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

    private func openURL(_ item: URLItem) {
        guard let url = URL(string: item.url) else { return }
        if url.isFileURL {
            let newBookmark = FileOpenService.openFileURL(url, existingBookmark: item.bookmarkData)
            if newBookmark != item.bookmarkData {
                viewModel.updateBookmark(for: item.id, bookmarkData: newBookmark)
            }
        } else {
            NSWorkspace.shared.open(url)
        }
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
