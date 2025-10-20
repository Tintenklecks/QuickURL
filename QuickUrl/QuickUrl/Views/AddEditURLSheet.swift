//
//  AddEditURLSheet.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import SwiftUI

/// Sheet view for adding or editing a URL item
struct AddEditURLSheet: View {
    @Binding var title: String
    @Binding var url: String
    @Binding var editingItem: URLItem?
    @Binding var isPresented: Bool
    var focusedField: FocusState<URLManagerView.Field?>.Binding
    let onSave: (String, String, URLItem?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title
            VStack(alignment: .leading, spacing: 4) {
                Text(editingItem == nil ? "Add URL" : "Edit URL")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(editingItem == nil ? "Add a new URL to your collection" : "Update the URL information")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            // Form content
            VStack(alignment: .leading, spacing: 20) {
                // Title field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    TextField("e.g., GitHub, Documentation, Website", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .focused(focusedField, equals: .title)
                }
                
                // URL field
                VStack(alignment: .leading, spacing: 6) {
                    Text("URL")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 8) {
                        TextField("https://", text: $url)
                            .textFieldStyle(.roundedBorder)
                            .focused(focusedField, equals: .url)
                        
                        Button(action: {
                            testURL()
                        }) {
                            Text("Test")
                                .font(.body)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!isValidURL(url))
                        .help("Open URL in browser to test")
                    }
                    
                    // Error message
                    if !url.isEmpty && !isValidURL(url) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                            Text("Please enter a valid URL starting with http:// or https://")
                                .font(.caption)
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Divider()
            
            // Bottom buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    cancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button(editingItem == nil ? "Add" : "Save") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(width: 480, height: 320)
        .onAppear {
            focusedField.wrappedValue = .title
        }
    }
    
    // MARK: - Helper Properties
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !url.trimmingCharacters(in: .whitespaces).isEmpty &&
        isValidURL(url)
    }
    
    // MARK: - Helper Methods
    
    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
    
    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedURL = url.trimmingCharacters(in: .whitespaces)
        
        onSave(trimmedTitle, trimmedURL, editingItem)
        
        isPresented = false
        clearFields()
    }
    
    private func cancel() {
        isPresented = false
        clearFields()
    }
    
    private func clearFields() {
        editingItem = nil
        title = ""
        url = ""
        focusedField.wrappedValue = nil
    }
    
    private func testURL() {
        guard isValidURL(url), let urlToOpen = URL(string: url) else { return }
        NSWorkspace.shared.open(urlToOpen)
    }
}

