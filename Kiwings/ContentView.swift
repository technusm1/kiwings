//
//  ContentView.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 16/06/21.
//

import SwiftUI
import LaunchAtLogin

struct MKContentTable: NSViewRepresentable {
    @Binding var data: [KiwixLibraryFile]
    @Binding var selection: [Int]
    
    final class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var parent: MKContentTable
        
        init(_ parent: MKContentTable) {
            self.parent = parent
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int {
            return parent.data.count
        }
        
        func tableViewSelectionDidChange(_ notification: Notification) {
            let tableView = notification.object as! NSTableView
            parent.selection = tableView.selectedRowIndexes.map({ $0 })
        }
        
        @objc func setEnableValue(_ sender: NSButton) {
            self.parent.data[sender.tag].isEnabled = (sender.state == .on) ? true : false
        }
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            if tableColumn?.identifier.rawValue == "libFiles" {
//                let textField = NSHostingView(rootView: Text("MK1-Nib"))
                let x = NSTableCellView()
                let textField = NSTextField(labelWithAttributedString: NSAttributedString(string: URL(fileURLWithPath: self.parent.data[row].path).absoluteURL.lastPathComponent, attributes: [.font : NSFont.systemFont(ofSize: 11, weight: .medium)]))
                x.addSubview(textField)
                textField.translatesAutoresizingMaskIntoConstraints = false
                x.addConstraint(NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: x, attribute: .centerY, multiplier: 1, constant: 0))
                return x
            } else if tableColumn?.identifier.rawValue == "isEnabled" {
                let checkboxField = NSButton()
                checkboxField.setButtonType(.switch)
                checkboxField.state = self.parent.data[row].isEnabled ? .on : .off
                checkboxField.title = ""
                checkboxField.target = self
                checkboxField.action = #selector(setEnableValue(_:))
                checkboxField.tag = row
                return checkboxField
            } else {
                return nil
            }
        }
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()
        tableView.allowsMultipleSelection = true
        tableView.headerView = NSTableHeaderView()
        let col1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "libFiles"))
        col1.title = "Library Files"
        tableView.addTableColumn(col1)
        
        let col2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "isEnabled"))
        col2.title = "Enabled"
        tableView.addTableColumn(col2)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.rowHeight = 18
        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.borderType = .lineBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let tableView = (nsView.documentView as! NSTableView)
        context.coordinator.parent = self
        // actually, model should tell us if reload is needed or not
        tableView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
}

struct MKTableSegmentControl: NSViewRepresentable {
    
    var onChange: ((_ control: NSSegmentedControl) -> Void)?
    
    func makeCoordinator() -> MKTableSegmentControl.Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: NSViewRepresentableContext<MKTableSegmentControl>) -> NSSegmentedControl {
        let control = NSSegmentedControl(
            images: [
                NSImage(named: NSImage.addTemplateName)!,
                NSImage(named: NSImage.removeTemplateName)!,
                NSImage()
            ],
            trackingMode: .momentary,
            target: context.coordinator,
            action: #selector(Coordinator.onChange(_:))
        )
        control.setWidth(32, forSegment: 0)
        control.setWidth(32, forSegment: 1)
        control.setEnabled(false, forSegment: 2)
        control.segmentStyle = .smallSquare
        return control
    }
    
    func updateNSView(_ nsView: NSSegmentedControl, context: NSViewRepresentableContext<MKTableSegmentControl>) {
    }
    
    class Coordinator {
        let parent: MKTableSegmentControl
        
        init(parent: MKTableSegmentControl) {
            self.parent = parent
        }
        
        @objc func onChange(_ control: NSSegmentedControl) {
            if let onChangeFunc = self.parent.onChange {
                onChangeFunc(control)
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("port") var port: Int = 80
    @AppStorage("kiwixLibs") var kiwixLibs: [KiwixLibraryFile] = []
    @AppStorage("kiwixPath") var kiwixPath: String = ""
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
                                        self.kiwixLibs.append(contentsOf: fpanel.urls.map({ KiwixLibraryFile(path: $0.absoluteURL.path, isEnabled: true) }))
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
                            self.kiwixProcess = Process()
                            self.kiwixProcess?.arguments = ["-a", "\(ProcessInfo().processIdentifier)","-p", "\(port)"]
                            self.kiwixProcess?.arguments?.append(contentsOf: kiwixLibs.filter({ $0.isEnabled }).map({ $0.path }))
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
                                self.startKiwix = false
                                self.kiwixProcess = nil
                            }
                        } else {
                            print("Stopping kiwix")
                            self.kiwixProcess?.terminate()
                            self.kiwixProcess = nil
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
                    Button("Exit", action: { NSRunningApplication.current.terminate()
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
