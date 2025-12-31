//
//  ContentView.swift
//  keyboard cleaning tool
//

import SwiftUI

struct ContentView: View {
    @StateObject private var keyboardService = KeyboardBlockingService()
    @State private var showingPermissionAlert = false
    @State private var showingInfoAlert = false
    @AppStorage("autoStartCleaning") private var autoStartCleaning = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(keyboardService.isBlocking ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)

                    Image(systemName: keyboardService.isBlocking ? "lock.fill" : "keyboard")
                        .font(.system(size: 40))
                        .foregroundColor(keyboardService.isBlocking ? .red : .blue)
                        .animation(.easeInOut(duration: 0.3), value: keyboardService.isBlocking)
                }

                Text("Keyboard Clean Tool")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(keyboardService.isBlocking ? "🔒 All keys disabled" : "Ready to clean your keyboard")
                    .font(.caption)
                    .foregroundColor(keyboardService.isBlocking ? .red : .secondary)
            }

            // Settings
            HStack {
                Toggle("Auto-lock on startup", isOn: $autoStartCleaning)
                    .font(.subheadline)

                Spacer()

                Button(action: { showingInfoAlert = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .help("About this app")
            }
            .padding(.horizontal)

            // Main Control Button
            Button(action: toggleLock) {
                HStack {
                    Image(systemName: keyboardService.isBlocking ? "lock.open.fill" : "lock.fill")
                    Text(keyboardService.isBlocking ? "Unlock Keyboard" : "Lock Keyboard")
                        .fontWeight(.semibold)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    keyboardService.isBlocking
                        ? LinearGradient(colors: [.green, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [.red, .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
                .shadow(color: keyboardService.isBlocking ? .green.opacity(0.3) : .red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .keyboardShortcut(.defaultAction)

            // Permission Status
            if !keyboardService.checkAccessibilityPermissions() {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Accessibility permission required")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Button("Grant Access") {
                        openSystemPreferences()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                }
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            checkAndStartIfNeeded()
        }
        .alert("About Keyboard Clean Tool", isPresented: $showingInfoAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("""
            This app blocks all keyboard input to help you safely clean your keyboard.

            • Blocks all keys including modifier keys
            • Blocks media keys and Touch ID
            • Shows overlay indicator when locked

            Click "Lock Keyboard" to start cleaning, then click "Unlock Keyboard" when done.
            """)
        }
    }

    private func toggleLock() {
        if keyboardService.isBlocking {
            keyboardService.stopBlocking()
        } else {
            if !keyboardService.checkAccessibilityPermissions() {
                showingPermissionAlert = true
            }
            keyboardService.startBlocking()
        }
    }

    private func checkAndStartIfNeeded() {
        if autoStartCleaning && keyboardService.checkAccessibilityPermissions() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                keyboardService.startBlocking()
            }
        }
    }

    private func openSystemPreferences() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

#Preview {
    ContentView()
        .frame(width: 400, height: 400)
}
