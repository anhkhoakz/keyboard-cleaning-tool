//
//  keyboard_cleaning_toolApp.swift
//  keyboard cleaning tool
//
//  Created by Nguyen Huynh Anh Khoa on 26/7/25.
//

import SwiftUI

@main
struct keyboard_cleaning_toolApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 300, height: 200)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
