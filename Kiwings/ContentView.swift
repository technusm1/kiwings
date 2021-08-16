//
//  ContentView.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 16/06/21.
//

import SwiftUI
import LaunchAtLogin

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("port") var port: Int = 80
    @AppStorage("kiwixLibs") var kiwixLibs: [KiwixLibraryFile] = []
    @AppStorage("kiwixPath") var kiwixPath: String = "bundled"
    @AppStorage("savedKiwixPaths") var savedKiwixPaths: [String] = []
    
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
                    Picker(selection: $kiwixPath, label: Text("Kiwix-serve:").bold(), content: {
                        // Bundled Kiwix. Version is hardcoded for now
                        if (Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve") != nil) {
                            Text("3.1.2 (bundled)").tag("bundled")
                        }
                        // Any kiwix that user has browsed before and are currently available
                        ForEach(self.savedKiwixPaths, id: \.self) { item in
                            if fileManager.fileExists(atPath: item) {
                                Text(item).tag(item)
                            } else {
                                Text(item).foregroundColor(.red).tag(item)
                            }
                            
                        }
                        Text("Browse").tag("browse")
                        Divider()
                        Text("Clear").tag("clear")
                    })
                    .onReceive([self.kiwixPath].publisher.first()) { (value) in
                        if value == "browse" {
                            self.kiwixPath = "bundled"
                            let fpanel = NSOpenPanel()
                            fpanel.allowsMultipleSelection = false
                            fpanel.canChooseDirectories = false
                            fpanel.canChooseFiles = true
                            fpanel.canCreateDirectories = false
                            fpanel.begin { response in
                                if response == .OK {
                                    if let filePath = fpanel.url?.absoluteURL.path {
                                        self.savedKiwixPaths.append(filePath)
                                        self.kiwixPath = filePath
                                        NSApp.activate(ignoringOtherApps: true)
                                    }
                                }
                            }
                            NSApp.activate(ignoringOtherApps: true)
                        } else if value == "clear" {
                            self.kiwixPath = "bundled"
                            self.savedKiwixPaths.removeAll()
                        }
                    }
                    HStack {
                        Text("Port:").bold().padding(.trailing)
                        Spacer()
                        StepperField(placeholderText: "Port for server", value: $port, minValue: 0, maxValue: 65535)
                    }
                    
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
                        if value {
                            print("Starting kiwix")
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
                                if self.kiwixPath == "bundled" {
                                    self.kiwixProcess?.executableURL = Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve")?.absoluteURL
                                } else {
                                    self.kiwixProcess?.executableURL = URL(fileURLWithPath: self.kiwixPath).absoluteURL
                                }
                                do {
                                    print("Gonna run now")
                                    print(self.kiwixProcess?.arguments)
                                    try self.kiwixProcess?.run()
                                } catch {
                                    print("unable to launch kiwix")
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
                                    print("Stopped resource access due to exception")
                                    self.startKiwix = false
                                    self.kiwixProcess = nil
                                }
                            } else {
                                self.startKiwix = false
                                self.kiwixProcess = nil
                            }
                        } else {
                            print("Stopping kiwix")
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
                            print("Program terminated. Stopped resource access.")
                        }
                    }).toggleStyle(CheckmarkToggleStyle(scaleFactor: 2))
                    BrowserListHorizontalStrip(port: $port)
                    .disabled(!startKiwix)
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 2, trailing: 8))
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
    var appURLs: [URL] = ((LSCopyApplicationURLsForURL(URL(string: "https:")! as CFURL, .all)?.takeRetainedValue()) as? [URL]) ?? []
    var appPaths: [String] {
        appURLs.map({ Bundle(url: $0)!.bundlePath })
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
