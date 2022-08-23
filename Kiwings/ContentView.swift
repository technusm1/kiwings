//
//  ContentView.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 16/06/21.
//

import SwiftUI
import LaunchAtLogin
import os

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("port") var port: Int = 80
    @AppStorage("kiwixLibs") var kiwixLibs: [KiwixLibraryFile] = []
    
    @State var startKiwix: Bool = false
    @State var isRandomPortBtnPressed: Bool = false
    @State var kiwixProcess: Process? = nil
    @State var kiwixLibsTableSelectedRows: [Int] = []
    
    let bundledKiwixUrl = Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve")?.absoluteURL
    let fileManager = FileManager.default
    
    func unlockAccessToKiwixLibs() {
        // Enable access to all bookmarked kiwix libraries before execution
        var staleIndices: IndexSet = []
        for libIndex in 0..<kiwixLibs.count {
            let bookmark = kiwixLibs[libIndex].bookmark
            var bookmarkDataIsStale: Bool = false
            if let url = try? URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale) {
                if bookmarkDataIsStale {
                    print("WARNING: stale security bookmark")
                    staleIndices.insert(libIndex)
                    continue
                }
                if !url.startAccessingSecurityScopedResource() {
                    print("startAccessingSecurityScopedResource FAILED")
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
                print("WARNING: stale security bookmark")
                continue
            }
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    var body: some View {
        VStack {
            TitleBarContentView().padding(.top, 10)
            VStack {
                VStack {
                    HStack {
                        Text("Port:").bold().padding(.trailing)
                        Spacer()
                        StepperField(placeholderText: "Port for server", value: $port, minValue: 0, maxValue: 65535)
                            .padding(.trailing)
                        Button {
                            port = Int.random(in: 0...65535)
                        } label: {
                            Image(systemName: "shuffle.circle\(isRandomPortBtnPressed ? ".fill" : "")").resizable().frame(width: 24, height: 24, alignment: .center)
                        }.buttonStyle(MkLinkButtonStyle(isPressed: $isRandomPortBtnPressed)).help("Select a random port")

                    }.padding(.top, 5)
                    .disabled(startKiwix)
                    
                    VStack(spacing: 0) {
                        MKContentTable(data: self.$kiwixLibs, selection: self.$kiwixLibsTableSelectedRows)
                            .frame(height: 100, alignment: .center)
                            .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                                for provider in providers {
                                    provider.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                        if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
                                            if url.pathExtension.lowercased() == "zim" {
                                                let kiwixLibPaths = self.kiwixLibs.map { $0.path }
                                                self.kiwixLibs.append(contentsOf: [url].filter({
                                                    !kiwixLibPaths.contains($0.absoluteURL.path)
                                                }).map({
                                                    let data = try! $0.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
                                                    NSLog("Bookmark stored")
                                                    return KiwixLibraryFile(path: $0.absoluteURL.path, isEnabled: !startKiwix, bookmark: data)
                                                }))
                                            }
                                        }
                                    })
                                }
                                return true
                            }
                        MKTableSegmentControl { control in
                            if control.isSelected(forSegment: 0) {
                                let fpanel = NSOpenPanel()
                                fpanel.allowsMultipleSelection = true
                                fpanel.canChooseDirectories = false
                                fpanel.canChooseFiles = true
                                fpanel.canCreateDirectories = false
                                fpanel.allowedFileTypes = ["zim"]
                                fpanel.begin { response in
                                    if response == .OK {
                                        let x = self.kiwixLibs.map { $0.path }
                                        self.kiwixLibs.append(contentsOf: fpanel.urls.filter({
                                            !x.contains($0.absoluteURL.path)
                                        }).map({
                                            let data = try! $0.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
                                            NSLog("Bookmark stored")
                                            return KiwixLibraryFile(path: $0.absoluteURL.path, isEnabled: true, bookmark: data)
                                        }))
                                    }
                                }
                            } else if control.isSelected(forSegment: 1) {
                                NSLog("Remove \(kiwixLibsTableSelectedRows) from \(kiwixLibs)")
                                self.kiwixLibs.remove(atOffsets: IndexSet(self.kiwixLibsTableSelectedRows))
                            }
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }.disabled(startKiwix)
                    
                    Toggle("", isOn: $startKiwix).onChange(of: startKiwix, perform: { value in
                        let logger = Logger()
                        if value {
                            // If toggle is switched on, start kiwix-serve
                            logger.info("Preparing kiwix-serve for execution")
                            unlockAccessToKiwixLibs()
                            let kiwixLibsToUse = kiwixLibs.filter({ $0.isEnabled }).map({ $0.path })
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
                                } catch {
                                    logger.error("Unable to launch kiwix-serve. The following error occured: \(error.localizedDescription)")
                                    disableAccessToKiwixLibs()
                                    logger.error("Stopped resource access due to exception")
                                    self.startKiwix = false
                                    self.kiwixProcess = nil
                                }
                            } else {
                                logger.warning("No kiwix libraries found. Cannot start kiwix-serve")
                                self.startKiwix = false
                                self.kiwixProcess = nil
                            }
                        } else {
                            logger.info("Stopping kiwix-serve")
                            self.kiwixProcess?.terminate()
                            self.kiwixProcess = nil
                            disableAccessToKiwixLibs()
                            logger.info("kiwix-serve terminated, stopped security-scoped resource access")
                        }
                    }).toggleStyle(CheckmarkToggleStyle(scaleFactor: 2))
                    BrowserListHorizontalStrip(port: $port)
                    .disabled(!startKiwix)
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 5, trailing: 8))
            }.background(colorScheme == .light ? Color.white : Color(NSColor.darkGray))
            StatusBarContentView(startKiwix: $startKiwix).padding(.bottom, 10)
        }.frame(minWidth: 250, maxWidth: 300, maxHeight: 400).fixedSize()
        // The frame().fixedSize() change was done after consulting this answer: https://stackoverflow.com/a/64836292/4385319
    }
}

struct TitleBarContentView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("KiWings").font(.headline)
                if #available(macOS 12.0, *) {
                    Text("by ***[Maheep Kumar Kathuria](https://maheepk.net)***").font(.footnote)
                } else {
                    Text("by Maheep Kumar Kathuria").font(.footnote)
                }
            }.padding(.leading, 8)
            Spacer()
            MenuButton(
                label: Label("Settings", systemImage: "gearshape.fill").labelStyle(IconOnlyLabelStyle()),
                content: {
                    LaunchAtLogin.Toggle {
                        Text("Launch at login")
                    }
                    Button("Exit", action: {
                        NSRunningApplication.current.terminate()
                    })
                }
            ).menuButtonStyle(BorderlessPullDownMenuButtonStyle()).frame(width: 32, height: 32, alignment: .center).padding(.trailing, 8)
        }
    }
}

struct StatusBarContentView: View {
    @Binding var startKiwix: Bool
    
    var body: some View {
        HStack {
            Text("Status:").font(.headline)
            Text(startKiwix ? "Running" : "Stopped")
                .font(.headline).fontWeight(.semibold).foregroundColor(startKiwix ? .green : .red)
        }
    }
}

struct BrowserListHorizontalStrip: View {
    var appURLs: [URL] = {
        // Solved using the approach mentioned in this answer: https://stackoverflow.com/a/931277/4385319
        let appBundleIdsForURLScheme: Set<String> = Set((LSCopyAllHandlersForURLScheme("https" as CFString)?.takeRetainedValue() as? [String])?.compactMap { $0 } ?? [])
        let appBundleIdsForFileType: Set<String> = Set((LSCopyAllRoleHandlersForContentType("public.html" as CFString, .viewer)?.takeRetainedValue() as? [String])?.compactMap { $0 } ?? [])

        let installedBrowserBundleIds = appBundleIdsForFileType.intersection(appBundleIdsForURLScheme)
        return installedBrowserBundleIds.compactMap { bundleId in
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId)
        }
    }()
    
    @Binding var port: Int
    
    var body: some View {
        VStack {
            ForEach(appURLs.chunked(into: 7), id: \.self) { appURLChunk in
                HStack {
                    ForEach(appURLChunk, id: \.self) { appURL in
                        Button(action: {
                            NSWorkspace.shared.open([URL(string: "http://localhost:\(self.port)")!], withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
                        }, label: {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: Bundle(url: appURL)?.bundlePath ?? "")).resizable().frame(width: 32, height: 32, alignment: .center)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
