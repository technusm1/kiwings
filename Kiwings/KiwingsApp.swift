//
//  KiwingsApp.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 16/06/21.
//

import SwiftUI
import LaunchAtLogin

@main
struct KiwingsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate! = nil
    var popover = NSPopover()
    var statusBarItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        // Setup popover
        setupPopover()
        
        // Setup status bar item
        setupStatusBarItem()
        
        // Show popover initially if not launched at login
        if !LaunchAtLogin.wasLaunchedOnLogin {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showPopover(nil)
            }
        }
    }
    
    private func setupPopover() {
        let contentView = ContentView()
        
        let hostingController = NSHostingController(rootView: contentView)
        
        popover.contentViewController = hostingController
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 300, height: 400)
        
        print("DEBUG: Popover setup completed, contentViewController: \(popover.contentViewController != nil)")
    }
    
    private func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusBarItem?.button {
            button.image = NSImage(named: "MenuBarIconDimmed")
            button.image?.isTemplate = true
            button.imageScaling = .scaleProportionallyUpOrDown
            button.imagePosition = .imageOnly
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        AppState.shared.terminateKiwixServer()
        NotificationCenter.default.removeObserver(AppState.shared)
    }
    
    @objc func showPopover(_ sender: AnyObject?) {
        guard let button = statusBarItem?.button else { 
            print("DEBUG: No status bar button found")
            return 
        }
        
        if popover.isShown {
            print("DEBUG: Popover already shown")
            return
        }
        
        print("DEBUG: Attempting to show popover")
        
        // Ensure the popover content is ready
        if let hostingController = popover.contentViewController as? NSHostingController<ContentView> {
            hostingController.view.needsLayout = true
        }
        
        // Position popover below the menu bar button
        // Use button bounds but specify minY to ensure it appears below
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        
        print("DEBUG: Popover show called, isShown: \(popover.isShown)")
        
        // Activate the app to bring it to the foreground
        NSApp.activate(ignoringOtherApps: true)
    }
    @objc func closePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        }
    }
    @objc func togglePopover(_ sender: AnyObject?) {
        print("DEBUG: togglePopover called, option key: \(NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option))")
        
        if NSEvent.modifierFlags.contains(NSEvent.ModifierFlags.option) {
            if !AppState.shared.isKiwixActive {
                AppState.shared.launchKiwixServer()
            } else {
                AppState.shared.terminateKiwixServer()
            }
        } else {
            print("DEBUG: Popover current state - isShown: \(popover.isShown)")
            if popover.isShown {
                closePopover(sender)
            } else {
                showPopover(sender)
            }
        }
    }
}
