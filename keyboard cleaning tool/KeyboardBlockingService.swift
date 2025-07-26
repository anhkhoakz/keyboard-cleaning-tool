//
//  KeyboardBlockingService.swift
//  keyboard cleaning tool
//
//  Created by Nguyen Huynh Anh Khoa on 26/7/25.
//

import AppKit
import ApplicationServices
import CoreGraphics
import Foundation

class KeyboardBlockingService: ObservableObject {
    @Published var isBlocking = false
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var originalWindowLevel: NSWindow.Level?

    func startBlocking() {
        guard !isBlocking else { return }

        // Request accessibility permissions using native macOS dialog
        if !requestAccessibilityPermissions() {
            return
        }

        // Block more comprehensive keyboard events including Touch ID and Caps Lock
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.tapDisabledByTimeout.rawValue) |
            (1 << CGEventType.tapDisabledByUserInput.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { _, _, _, _ -> Unmanaged<CGEvent>? in
                // Block all keyboard events by returning nil
                return nil
            },
            userInfo: nil
        )

        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            isBlocking = true

            // Make window always on top
            makeWindowAlwaysOnTop(true)
        }
    }

    func stopBlocking() {
        guard isBlocking else { return }

        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isBlocking = false

        // Restore window level
        makeWindowAlwaysOnTop(false)
    }

    private func makeWindowAlwaysOnTop(_ alwaysOnTop: Bool) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first {
                if alwaysOnTop {
                    self.originalWindowLevel = window.level
                    window.level = .floating
                } else if let originalLevel = self.originalWindowLevel {
                    window.level = originalLevel
                }
            }
        }
    }

    private func requestAccessibilityPermissions() -> Bool {
        // Use native macOS permission request with prompt
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }
}
