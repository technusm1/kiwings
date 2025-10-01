//
//  AppState.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 17/11/22.
//

import SwiftUI
import os

final class AppState: ObservableObject {
    var logger: Logger = Logger()
    static var shared: AppState = {
        let x = AppState()
        NotificationCenter.default.addObserver(x, selector: #selector(didterminatenotificationReceived), name: Process.didTerminateNotification, object: nil)
        return x
    }()
    
    @AppStorage("kiwixLibs") var kiwixLibs: [KiwixLibraryFile] = []
    @AppStorage("port") var port: Int = 80
    
    @Published var kiwixProcess: Process? = nil
    
    var isKiwixActive: Bool {
        kiwixProcess != nil && kiwixProcess!.isRunning
    }
    
    @objc func didterminatenotificationReceived() {
        logger.info("Termination notification received")
        withAnimation(.linear(duration: 0.1)) {
            kiwixProcess = nil
        }
        let icon = NSImage(named: "MenuBarIconDimmed")
        icon?.isTemplate = true
        AppDelegate.instance.statusBarItem?.button?.image = icon
    }
    
    func unlockAccessToKiwixLibs() {
        // Enable access to all bookmarked kiwix libraries before execution
        var staleIndices: IndexSet = []
        for libIndex in 0..<kiwixLibs.count {
            let bookmark = kiwixLibs[libIndex].bookmark
            var bookmarkDataIsStale: Bool = false
            if let url = try? URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale) {
                if bookmarkDataIsStale {
                    logger.warning("Stale security bookmark")
                    staleIndices.insert(libIndex)
                    continue
                }
                if !url.startAccessingSecurityScopedResource() {
                    logger.warning("startAccessingSecurityScopedResource FAILED")
                }
            } else {
                staleIndices.insert(libIndex)
            }
        }
        kiwixLibs.remove(atOffsets: staleIndices)
    }
    
    func disableAccessToKiwixLibs() {
        for lib in kiwixLibs {
            let bookmark = lib.bookmark
            var bookmarkDataIsStale: Bool = false
            let url = try! URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
            if bookmarkDataIsStale {
                logger.warning("Stale security bookmark")
                continue
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func appendToKiwixLibs(_ collection: [URL]) {
        let kiwixLibPaths = self.kiwixLibs.map(\.path)
        self.kiwixLibs.append(contentsOf: collection.filter({
            !kiwixLibPaths.contains($0.absoluteURL.path)
        }).map({
            let data = try! $0.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
            logger.info("Bookmark stored")
            return KiwixLibraryFile(path: $0.absoluteURL.path, isEnabled: !isKiwixActive, bookmark: data)
        }))
    }
    
    func launchKiwixServer() {
        // If toggle is switched on, start kiwix-serve
        logger.info("Preparing kiwix-serve for execution")
        unlockAccessToKiwixLibs()
        let kiwixLibsToUse = kiwixLibs.filter(\.isEnabled).map(\.path)
        if !kiwixLibsToUse.isEmpty {
            self.kiwixProcess = Process()
            self.kiwixProcess?.arguments = ["-a", "\(ProcessInfo().processIdentifier)","-p", "\(port)"]
            self.kiwixProcess?.arguments?.append(contentsOf: kiwixLibsToUse)
            self.kiwixProcess?.executableURL = Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve")?.absoluteURL
            do {
                logger.info("Trying to execute command: kiwix-serve")
                let programArgs: [String] = (self.kiwixProcess?.arguments) ?? ["Invalid ARGS"]
                logger.info("Program arguments: \(programArgs)")
                try self.kiwixProcess?.run()
                let icon = NSImage(named: "MenuBarIcon")
                icon?.isTemplate = true
                AppDelegate.instance.statusBarItem?.button?.image = icon
            } catch {
                logger.error("Unable to launch kiwix-serve. The following error occured: \(error.localizedDescription). Stopped resource access due to exception")
                terminateKiwixServer()
            }
        } else {
            logger.error("No kiwix libraries found. Cannot start kiwix-serve")
            terminateKiwixServer()
        }
    }
    
    func terminateKiwixServer() {
        logger.info("Terminating kiwix-serve")
        disableAccessToKiwixLibs()
        self.kiwixProcess?.terminate()
    }
}
