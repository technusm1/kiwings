//
//  ContentView.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 16/06/21.
//

import SwiftUI
import LaunchAtLogin
import os
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("port") var port: Int = 80
    @AppStorage("kiwixLibs") var kiwixLibs: [KiwixLibraryFile] = []
    
    @State var startKiwix: Bool = false
    @State var kiwixProcess: Process? = nil
    @State var kiwixLibsTableSelectedRows: [Int] = []
    let bundledKiwixUrl = Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve")?.absoluteURL
    let fileManager = FileManager.default
    
    var body: some View {
        VStack {
            TitleBarContentView()
            VStack {
                VStack {
                    HStack {
                        Text("Port:").bold().padding(.trailing)
                        Spacer()
                        StepperField(placeholderText: "Port for server", value: $port, minValue: 0, maxValue: 65535)
                    }.padding(.top, 5)
                    
                    VStack(spacing: 0) {
                        MKContentTable(data: self.$kiwixLibs, selection: self.$kiwixLibsTableSelectedRows)
                            .frame(height: 100, alignment: .center)
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
                                        self.kiwixLibs.append(contentsOf: fpanel.urls.map({
                                            let data = try! $0.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
                                            print("Bookmark stored")
                                            return KiwixLibraryFile(path: $0.absoluteURL.path, isEnabled: true, bookmark: data)
                                        }))
                                    }
                                }
                            } else if control.isSelected(forSegment: 1) {
                                print("Remove \(kiwixLibsTableSelectedRows) from \(kiwixLibs)")
                                self.kiwixLibs.remove(atOffsets: IndexSet(self.kiwixLibsTableSelectedRows))
                            }
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }
                    
                    Toggle("", isOn: $startKiwix).onChange(of: startKiwix, perform: { value in
                        let logger = Logger()
                        if value {
                            logger.info("Preparing kiwix-serve for execution")
                            // Enable access to all bookmarked kiwix libraries before execution
                            var staleIndices: IndexSet = []
                            for libIndex in 0..<kiwixLibs.count {
                                let bookmark = kiwixLibs[libIndex].bookmark
                                var bookmarkDataIsStale: Bool = false
                                let url = try! URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkDataIsStale)
                                if bookmarkDataIsStale {
                                    print("WARNING: stale security bookmark")
                                    staleIndices.insert(libIndex)
                                    continue
                                }
                                if !url.startAccessingSecurityScopedResource() {
                                    print("startAccessingSecurityScopedResource FAILED")
                                }
                            }
                            kiwixLibs.remove(atOffsets: staleIndices)
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
                            logger.info("kiwix-serve terminated, stopped security-scoped resource access")
                        }
                    }).toggleStyle(CheckmarkToggleStyle(scaleFactor: 2))
                    BrowserListHorizontalStrip(port: $port)
                    .disabled(!startKiwix)
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 5, trailing: 8))
            }.background(colorScheme == .light ? Color.white : Color(NSColor.darkGray))
            StatusBarContentView(startKiwix: $startKiwix)
        }.padding(.vertical, 20)
    }
}

struct TitleBarContentView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text("KiWings").font(.headline)
                Text("by Maheep Kumar Kathuria").font(.footnote)
            }.padding([.leading])
            Spacer()
            MenuButton(
                label: Label("Settings", systemImage: "gearshape.fill").labelStyle(IconOnlyLabelStyle()),
                content: {
                    LaunchAtLogin.Toggle {
                        Text("Launch at login")
                    }
//                    Button("Preferences", action: {
//                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
//                        NSApp.activate(ignoringOtherApps: true)
//                    })
                    Button("Exit", action: {
                        NSRunningApplication.current.terminate()
                    })
                }
            ).menuButtonStyle(BorderlessPullDownMenuButtonStyle()).frame(width: 32, height: 32, alignment: .center).padding([.trailing])
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
    var appURLs: [URL] = LSCopyApplicationURLsForURL(URL(string: "https:")! as CFURL, .viewer)?.takeRetainedValue() as? [URL] ?? []
    
    var appPaths: [String] {
        appURLs.map({ Bundle(url: $0)?.bundlePath ?? "" })
    }
    
    @Binding var port: Int
    
    var body: some View {
        HStack {
            ForEach(0..<appURLs.count) { index in
                Button(action: {
                    NSWorkspace.shared.open([URL(string: "http://localhost:\(self.port)")!], withApplicationAt: appURLs[index], configuration: NSWorkspace.OpenConfiguration(), completionHandler: nil)
                }, label: {
                    Image(nsImage: NSWorkspace.shared.icon(forFile: appPaths[index])).resizable().frame(width: 32, height: 32, alignment: .center)
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
