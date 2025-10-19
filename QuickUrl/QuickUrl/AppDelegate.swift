//
//  AppDelegate.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import Cocoa
import SwiftUI

/// AppDelegate managing the status bar and menu
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var managerWindow: NSWindow?
    private let viewModel = URLManagerViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "link.circle.fill", accessibilityDescription: "Quick URLs")
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        
        // Initial menu update
        updateMenu()
        
        // Observe changes to update menu
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenu),
            name: NSNotification.Name("URLsUpdated"),
            object: nil
        )
    }
    
    @objc private func statusBarButtonClicked() {
        updateMenu()
        statusItem.menu = createMenu()
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
    
    @objc private func updateMenu() {
        // Reload URLs from storage to ensure menu is up-to-date
        viewModel.loadURLs()
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Add URL items
        for item in viewModel.urlItems {
            if item.isDivider {
                menu.addItem(NSMenuItem.separator())
            } else {
                let menuItem = NSMenuItem(
                    title: item.title,
                    action: #selector(openURL(_:)),
                    keyEquivalent: ""
                )
                menuItem.target = self
                menuItem.representedObject = item.url
                menu.addItem(menuItem)
            }
        }
        
        // Add separator before management options
        menu.addItem(NSMenuItem.separator())
        
        // Add "Manage URLs..." option
        let manageItem = NSMenuItem(
            title: "Manage URLs...",
            action: #selector(openManager),
            keyEquivalent: ","
        )
        manageItem.target = self
        menu.addItem(manageItem)
        
        // Add "Quit" option
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc private func openURL(_ sender: NSMenuItem) {
        guard let urlString = sender.representedObject as? String,
              let url = URL(string: urlString) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @objc private func openManager() {
        if managerWindow == nil {
            let contentView = URLManagerView(viewModel: viewModel)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = "Quick URL Manager"
            window.titlebarAppearsTransparent = false
            window.toolbarStyle = .unified
            window.center()
            window.contentView = NSHostingView(rootView: contentView)
            window.setFrameAutosaveName("URLManagerWindow")
            
            // Post notification when window closes to update menu
            window.delegate = self
            
            managerWindow = window
        }
        
        managerWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow === managerWindow {
            managerWindow = nil
            // Update menu when manager window closes
            updateMenu()
        }
    }
}

