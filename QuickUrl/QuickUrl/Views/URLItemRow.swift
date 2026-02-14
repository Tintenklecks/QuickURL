//
//  URLItemRow.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import SwiftUI

/// Row view for a single URL item
struct URLItemRow: View {
    let item: URLItem
    let isHovered: Bool
    let colorGroup: Int
    let onEdit: () -> Void
    let onOpen: () -> Void
    let onDelete: () -> Void

    @State private var isPressed = false
    @State private var isOpenButtonHovered = false
    @State private var isEditButtonHovered = false
    @State private var isDeleteButtonHovered = false

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
                    .foregroundStyle(sectionColor)
                    .opacity(isOpenButtonHovered ? 1.0 : 0.8)
                    .help("Open URL")
                    .onHover { hovering in
                        isOpenButtonHovered = hovering
                    }

                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(sectionColor)
                    .opacity(isEditButtonHovered ? 1.0 : 0.8)
                    .help("Edit URL")
                    .onHover { hovering in
                        isEditButtonHovered = hovering
                    }

                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(sectionColor)
                    .opacity(isDeleteButtonHovered ? 1.0 : 0.8)
                    .help("Delete URL")
                    .onHover { hovering in
                        isDeleteButtonHovered = hovering
                    }
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
        .simultaneousGesture(
            TapGesture().onEnded {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                    onOpen()
                }
            }
        )
    }

    private var iconGradient: LinearGradient {
        let colors = iconColors(for: colorGroup)
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var sectionColor: Color {
        let colors = iconColors(for: colorGroup)
        return colors[0]
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
            [.indigo, .purple],
        ]
        return colorPairs[group % colorPairs.count]
    }
}
