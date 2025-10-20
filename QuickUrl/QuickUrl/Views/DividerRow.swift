//
//  DividerRow.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import SwiftUI

/// Row view for a divider item
struct DividerRow: View {
    let item: URLItem
    let isHovered: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.secondary.opacity(0.5))
                .frame(height: 1)
            
            Spacer(minLength: 12)
            
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
                    .foregroundStyle(.primary)
                    .help("Delete Divider")
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .listRowBackground(Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}

