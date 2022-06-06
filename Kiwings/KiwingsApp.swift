//
//  KiwingsApp.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 16/06/21.
//

import SwiftUI

@main
struct KiwingsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    var statusBarItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()

        // Set the SwiftUI's ContentView to the Popover's ContentViewController
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: contentView)
        popover.contentViewController?.view.window?.makeKey()
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(contentsOf: Bundle.main.urlForImageResource("AppIcon")!)
        statusBarItem?.button?.image?.size = NSSize(width: 24, height: 24)
        statusBarItem?.button?.imageScaling = .scaleProportionallyUpOrDown
        statusBarItem?.button?.imagePosition = .imageOverlaps
        statusBarItem?.button?.action = #selector(AppDelegate.togglePopover(_:))
    }
    
    @objc func showPopover(_ sender: AnyObject?) {
        // Function created based on answer at: https://stackoverflow.com/a/48604455/4385319
        // Create a window
        let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 10, 5), styleMask: .borderless, backing: .buffered, defer: false)
        invisibleWindow.backgroundColor = .clear
        invisibleWindow.alphaValue = 0

        if let button = statusBarItem?.button {
            // find the coordinates of the statusBarItem in screen space
            let buttonRect: NSRect = button.convert(button.bounds, to: nil)
            let screenRect: NSRect = button.window!.convertToScreen(buttonRect)

            // calculate the bottom center position (5 is the half of the window width)
            let posX = screenRect.origin.x + (screenRect.width / 2) - 5
            let posY = screenRect.origin.y

            // position and show the window
            invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
            invisibleWindow.makeKeyAndOrderFront(self)

            // position and show the NSPopover
            popover.show(relativeTo: invisibleWindow.contentView!.frame, of: invisibleWindow.contentView!, preferredEdge: NSRectEdge.minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    @objc func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
}
