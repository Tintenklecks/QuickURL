//
//  QuickUrlApp.swift
//  QuickUrl
//
//  Created by puco on 17.10.2025.
//

import SwiftUI

@main
struct QuickUrlApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
