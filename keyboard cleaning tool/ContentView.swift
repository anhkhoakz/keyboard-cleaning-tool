//
//  ContentView.swift
//  keyboard cleaning tool
//
//  Created by Nguyen Huynh Anh Khoa on 26/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var keyboardService = KeyboardBlockingService()
    @State private var showingPermissionAlert = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: keyboardService.isBlocking ? "lock.fill" : "keyboard")
                    .font(.system(size: 40))
                    .foregroundColor(keyboardService.isBlocking ? .red : .blue)
                    .animation(.easeInOut(duration: 0.1), value: keyboardService.isBlocking)
                    .frame( height: 40)

                Text("Keyboard Clean Tool")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            // Control Button
            Button(action: toggleLock) {
                HStack {
                    Image(systemName: keyboardService.isBlocking ? "lock.open" : "lock")
                    Text(keyboardService.isBlocking ? "Unlock Keyboard" : "Lock Keyboard")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(keyboardService.isBlocking ? Color.green : Color.red)
                .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .focusable(false)

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: 560, maxHeight: 200)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func toggleLock() {
        if keyboardService.isBlocking {
            keyboardService.stopBlocking()
        } else {
            keyboardService.startBlocking()
        }
    }
}

#Preview {
    ContentView()
}
