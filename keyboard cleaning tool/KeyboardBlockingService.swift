//
//  KeyboardBlockingService.swift
//  keyboard cleaning tool
//
//  Created by Nguyen Huynh Anh Khoa on 26/7/25.
//

import AppKit
import CoreGraphics
import Foundation
import ApplicationServices

class KeyboardBlockingService: ObservableObject {
    @Published var isBlocking = false
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func startBlocking() {
        guard !isBlocking else { return }

        // Request accessibility permissions using native macOS dialog
        if !requestAccessibilityPermissions() {
            return
        }

        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
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
