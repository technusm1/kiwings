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
    
    @StateObject var appState: AppState = AppState.shared
    
    @State var isRandomPortBtnPressed: Bool = false
    @State var kiwixLibsTableSelectedRows: [Int] = []
    
    let bundledKiwixUrl = Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve")?.absoluteURL
    let fileManager = FileManager.default
    let logger = Logger()
    
    var body: some View {
        VStack {
            TitleBarContentView().padding(.top, 10)
            VStack {
                VStack {
                    HStack {
                        Text("Port:").bold().padding(.trailing)
                        Spacer()
                        StepperField(placeholderText: "Port for server", value: $appState.port, minValue: 0, maxValue: 65535)
                            .padding(.trailing)
                        Button {
                            appState.port = Int.random(in: 0...65535)
                        } label: {
                            Image(systemName: "shuffle.circle\(isRandomPortBtnPressed ? ".fill" : "")").resizable().frame(width: 24, height: 24, alignment: .center)
                        }.buttonStyle(MkLinkButtonStyle(isPressed: $isRandomPortBtnPressed)).help("Select a random port")

                    }.padding(.top, 5)
                    .disabled(appState.isKiwixActive)
                    
                    VStack(spacing: 0) {
                        MKContentTable(data: appState.$kiwixLibs, selection: self.$kiwixLibsTableSelectedRows)
                            .frame(height: 100, alignment: .center)
                            .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                                for provider in providers {
                                    provider.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                                        if let data = data, let path = NSString(data: data, encoding: 4), let url = URL(string: path as String) {
                                            if url.pathExtension.lowercased() == "zim" {
                                                appState.appendToKiwixLibs([url])
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
                                        appState.appendToKiwixLibs(fpanel.urls)
                                    }
                                }
                            } else if control.isSelected(forSegment: 1) {
                                logger.info("Remove \(kiwixLibsTableSelectedRows) from \(appState.kiwixLibs)")
                                appState.kiwixLibs.remove(atOffsets: IndexSet(self.kiwixLibsTableSelectedRows))
                            }
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }.disabled(appState.isKiwixActive)
                    
                    Toggle("", isOn: Binding(get: {
                        appState.isKiwixActive
                    }, set: { val in
                        if val {
                            appState.launchKiwixServer()
                        } else {
                            appState.terminateKiwixServer()
                        }
                    }))
                    .toggleStyle(CheckmarkToggleStyle(scaleFactor: 2))
                    BrowserListHorizontalStrip(port: $appState.port)
                        .disabled(!appState.isKiwixActive)
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 5, trailing: 8))
            }.background(colorScheme == .light ? Color.white : Color(NSColor.darkGray))
            StatusBarContentView(startKiwix: appState.isKiwixActive).padding(.bottom, 10)
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
    var startKiwix: Bool
    
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
        let appBundleIdsForURLScheme: [String] = (LSCopyAllHandlersForURLScheme("https" as CFString)?.takeRetainedValue() as? [String])?.compactMap { $0 } ?? []
        let appBundleIdsForFileType: Set<String> = Set((LSCopyAllRoleHandlersForContentType("public.html" as CFString, .viewer)?.takeRetainedValue() as? [String])?.compactMap { $0 } ?? [])
        let installedBrowserIds: [String] = appBundleIdsForURLScheme.filter { bundleId in
            appBundleIdsForFileType.contains(bundleId)
        }
        return installedBrowserIds.compactMap { bundleId in
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
                        .shadow(radius: 1.1)
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
