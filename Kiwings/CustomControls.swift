//
//  CustomControls.swift
//  Kiwings
//
//  Created by Maheep Kumar Kathuria on 21/06/21.
//

import SwiftUI

// Code adopted from the following StackOverflow answer: https://stackoverflow.com/a/70191752/4385319
struct MkLinkButtonStyle : ButtonStyle {
    @Binding var isPressed : Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed, perform: {newVal in
                isPressed = newVal
            })
            .foregroundColor(.accentColor)
    }
}

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
                let x = NSTableCellView()
                let textField = NSTextField(labelWithAttributedString: NSAttributedString(string: URL(fileURLWithPath: self.parent.data[row].path).absoluteURL.lastPathComponent, attributes: [.font : NSFont.systemFont(ofSize: 11, weight: .medium)]))
                x.addSubview(textField)
                textField.translatesAutoresizingMaskIntoConstraints = false
                x.addConstraint(NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: x, attribute: .centerY, multiplier: 1, constant: 0))
                return x
            } else if tableColumn?.identifier.rawValue == "isEnabled" {
                if let headerCell = tableColumn?.headerCell as? CheckboxHeaderCell {
                    if self.parent.data.allSatisfy({ $0.isEnabled == true }) {
                        headerCell.alternateState = .on
                    } else if self.parent.data.allSatisfy({ $0.isEnabled == false }) {
                        headerCell.alternateState = .off
                    } else {
                        headerCell.alternateState = .mixed
                    }
                }
                
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

        func setupAlternateState(_ state: NSControl.StateValue) {
            // modify data source
            if state == .on {
                for i in self.parent.data.indices {
                    self.parent.data[i].isEnabled = true
                }
            } else if state == .off {
                for i in self.parent.data.indices {
                    self.parent.data[i].isEnabled = false
                }
            }
        }

        func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
            if tableColumn.identifier.rawValue == "isEnabled" {
                if let headerCell = tableColumn.headerCell as? CheckboxHeaderCell {
                    // apply state changes to its data source
                    setupAlternateState(headerCell.toggleAlternateState())
                    
                    // reload display, select or deselect all checkboxes
                    tableView.reloadData(
                        forRowIndexes: IndexSet(integersIn: 0..<tableView.numberOfRows),
                        columnIndexes: IndexSet(integer: 0)
                    )
                }
            }
        }
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let tableView = NSTableView()
        tableView.allowsMultipleSelection = true
        tableView.headerView = NSTableHeaderView()
        
        let col1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "isEnabled"))
        col1.headerCell = CheckboxHeaderCell()
        col1.maxWidth = 18
        tableView.addTableColumn(col1)
        let col2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "libFiles"))
        col2.title = NSLocalizedString("Library Files", comment: "Library Files")
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

        // Remove corner radius to match table's sharp edges
        if let cell = control.cell as? NSSegmentedCell {
            cell.trackingMode = .momentary
        }
        control.wantsLayer = true
        control.layer?.cornerRadius = 0

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

struct CheckmarkToggleStyle: ToggleStyle {
    var scaleFactor: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .background(configuration.isOn ? LinearGradient(gradient: Gradient(colors: [.pink, .blue]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [.gray]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20*scaleFactor)
            ZStack {
                Circle()
                    .foregroundColor(.white)
                Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .font(Font.title.weight(.black))
                    .frame(width: 8*scaleFactor, height: 8*scaleFactor, alignment: .center)
                    .foregroundColor(configuration.isOn ? .green : .black)
            }
            .frame(width: 25*scaleFactor, height: 25*scaleFactor)
            .offset(x: configuration.isOn ? 11*scaleFactor : -11*scaleFactor, y: 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
        }
        .frame(width: 51*scaleFactor, height: 31*scaleFactor)
        .fixedSize()
        .cornerRadius(20*scaleFactor)
        .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 0))
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}

struct MKTextField: NSViewRepresentable {
    @Binding var value: Int
    var minValue: Int?
    var maxValue: Int?
    var placeholderText: String
    
    func makeCoordinator() -> MKTextField.Coordinator {
        Coordinator(parent: self)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.bezelStyle = .roundedBezel
        textField.alignment = .center
        textField.formatter = NumberFormatter()
        textField.placeholderString = placeholderText
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if let minVal = minValue, let maxVal = maxValue {
            if !(minVal...maxVal).contains(value) || value == 0 {
                value = 80
            }
            nsView.integerValue = value
        }
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: MKTextField
        
        init(parent: MKTextField) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            self.parent.value = textField.integerValue
        }
    }
}

struct StepperField: View {
    var placeholderText: String
    var value: Binding<Int>
    var minValue: Int?
    var maxValue: Int?
    var body: some View {
        ZStack {
            MKTextField(value: value, minValue: minValue, maxValue: maxValue, placeholderText: placeholderText)
            HStack(alignment: .center) {
                Button(action: {
                    self.value.wrappedValue -= 1
                    if let minimumVal = minValue {
                        self.value.wrappedValue = max(minimumVal, self.value.wrappedValue)
                    }
                }, label: {
                    Text("−").bold()
                }).buttonStyle(PlainButtonStyle()).frame(width: 16, height: 16, alignment: .center)
                Spacer()
                Button(action: {
                    self.value.wrappedValue += 1
                    if let maxVal = maxValue {
                        self.value.wrappedValue = min(maxVal, self.value.wrappedValue)
                    }
                }, label: {
                    Text("+").bold()
                }).buttonStyle(PlainButtonStyle()).frame(width: 16, height: 16, alignment: .center)
            }
        }
    }
}
