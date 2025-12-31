//
//  KeyboardBlockingService.swift
//  keyboard cleaning tool
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
    private var overlayWindow: NSWindow?

    func startBlocking() {
        guard !isBlocking else { return }

        // Request accessibility permissions
        if !requestAccessibilityPermissions() {
            print("Accessibility permissions not granted")
            return
        }

        // Create comprehensive event mask for ALL keyboard events
        let eventMask: CGEventMask =
            (1 << CGEventType.keyDown.rawValue) |
            (1 << CGEventType.keyUp.rawValue) |
            (1 << CGEventType.flagsChanged.rawValue) |
            (1 << CGEventType.systemDefined.rawValue)

        // Create event tap with callback to block events
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                // Handle tap disabled events
                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    if let eventTap = refcon?.assumingMemoryBound(to: CFMachPort.self).pointee {
                        CGEvent.tapEnable(tap: eventTap, enable: true)
                    }
                    return Unmanaged.passRetained(event)
                }

                // Block all keyboard-related events
                let eventType = event.type
                if eventType == .keyDown || eventType == .keyUp || eventType == .flagsChanged {
                    return nil // Block the event
                }

                // Check for system-defined events (like media keys, Touch ID)
                if eventType == .systemDefined {
                    let subtype = event.getIntegerValueField(.keyboardEventKeycode)
                    // Block NX_SUBTYPE_AUX_CONTROL_BUTTONS (8) which includes media keys
                    if subtype == 8 {
                        return nil
                    }
                }

                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            isBlocking = true

            // Make window always on top and create overlay
            makeWindowAlwaysOnTop(true)
            createOverlayWindow()

            print("Keyboard blocking started successfully")
        } else {
            print("Failed to create event tap")
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

        // Restore window level and remove overlay
        makeWindowAlwaysOnTop(false)
        removeOverlayWindow()

        print("Keyboard blocking stopped")
    }

    private func createOverlayWindow() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Create a semi-transparent overlay to indicate blocking is active
            let screen = NSScreen.main ?? NSScreen.screens[0]
            let screenFrame = screen.frame

            let overlay = NSWindow(
                contentRect: screenFrame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )

            overlay.isOpaque = false
            overlay.backgroundColor = NSColor.black.withAlphaComponent(0.05)
            overlay.level = .statusBar
            overlay.ignoresMouseEvents = true
            overlay.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

            // Add visual indicator
            let contentView = NSView(frame: screenFrame)
            let label = NSTextField(labelWithString: "🔒 Keyboard Locked - Return to Keyboard Clean Tool to unlock")
            label.font = NSFont.systemFont(ofSize: 24, weight: .bold)
            label.textColor = .white
            label.backgroundColor = NSColor.black.withAlphaComponent(0.7)
            label.alignment = .center
            label.frame = CGRect(
                x: (screenFrame.width - 600) / 2,
                y: screenFrame.height - 100,
                width: 600,
                height: 50
            )
            contentView.addSubview(label)
            overlay.contentView = contentView

            overlay.orderFrontRegardless()
            self.overlayWindow = overlay
        }
    }

    private func removeOverlayWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.close()
            self?.overlayWindow = nil
        }
    }

    private func makeWindowAlwaysOnTop(_ alwaysOnTop: Bool) {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first(where: { $0.title == "Keyboard Clean Tool" || $0.contentView != nil }) {
                if alwaysOnTop {
                    self.originalWindowLevel = window.level
                    window.level = .floating
                    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                } else if let originalLevel = self.originalWindowLevel {
                    window.level = originalLevel
                    window.collectionBehavior = []
                }
            }
        }
    }

    private func requestAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func checkAccessibilityPermissions() -> Bool {
        return AXIsProcessTrusted()
    }

    deinit {
        stopBlocking()
    }
}
