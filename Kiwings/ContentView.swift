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
    
    @ObservedObject var appState: AppState = AppState.shared
    
    @State var isRandomPortBtnPressed: Bool = false
    @State var kiwixLibsTableSelectedRows: [Int] = []
    
    let bundledKiwixUrl = Bundle.main.url(forAuxiliaryExecutable: "kiwix-serve")?.absoluteURL
    let fileManager = FileManager.default
    let logger = Logger()
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBarView()
            Spacer().frame(height: 8)
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
                    BrowserListHorizontalStripView(port: $appState.port)
                        .disabled(!appState.isKiwixActive)
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 5, trailing: 8))
            }.background(colorScheme == .light ? Color.white : Color(NSColor.darkGray))
            Spacer().frame(height: 8)
            StatusBarContentView(startKiwix: appState.isKiwixActive)
        }
        .frame(width: 280, height: 380)
        .background(Color.clear)
        // Fixed size for popover context - prevents layout issues
    }
}

struct StatusBarContentView: View {
    var startKiwix: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("Status:").font(.headline)
            Text(startKiwix ? "Running" : "Stopped")
                .font(.headline).fontWeight(.semibold).foregroundColor(startKiwix ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 32, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
