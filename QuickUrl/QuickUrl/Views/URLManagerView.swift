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
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Text("Quick URL Manager")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // URL List
            List {
                ForEach(viewModel.urlItems) { item in
                    if item.isDivider {
                        Divider()
                            .id(item.id)
                    } else {
                        URLItemRow(item: item, onEdit: {
                            editingItem = item
                            newTitle = item.title
                            newURL = item.url
                        })
                    }
                }
                .onDelete(perform: viewModel.deleteURLs)
                .onMove(perform: viewModel.moveURLs)
            }
            .listStyle(.inset)
            
            Divider()
            
            // Add new URL section
            VStack(alignment: .leading, spacing: 12) {
                Text(editingItem == nil ? "Add New URL" : "Edit URL")
                    .font(.headline)
                
                HStack {
                    TextField("Title", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("URL", text: $newURL)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    if editingItem != nil {
                        Button("Cancel") {
                            cancelEditing()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(editingItem == nil ? "Add URL" : "Update URL") {
                        if let editing = editingItem {
                            viewModel.updateURL(item: editing, title: newTitle, url: newURL)
                            cancelEditing()
                        } else {
                            viewModel.addURL(title: newTitle, url: newURL)
                            newTitle = ""
                            newURL = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTitle.isEmpty || newURL.isEmpty)
                    
                    Button("Add Divider") {
                        viewModel.addDivider()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private func cancelEditing() {
        editingItem = nil
        newTitle = ""
        newURL = ""
    }
}

/// Row view for a single URL item
struct URLItemRow: View {
    let item: URLItem
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.url)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .help("Edit URL")
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    URLManagerView(viewModel: URLManagerViewModel())
}

