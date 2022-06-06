//
//  CheckboxHeaderCell.swift
//
//  Created by Rachel on 2021/4/26.
//  Original: https://stackoverflow.com/questions/11961869/checkbox-in-nstableview-column-header
//  FOUND ON THIS LINK: https://gist.github.com/Lessica/176c2314336fc861398de1e1045aa368

import Cocoa

class CheckboxCell: NSButtonCell {
    var alternateState: NSControl.StateValue = .off {
        didSet {
            super.state = alternateState
        }
    }
    
    // Ignores the default behavior
    override var state: NSControl.StateValue {
        get { alternateState }
        set { }
    }
}

class CheckboxHeaderCell: NSTableHeaderCell {
    private lazy var innerCell: CheckboxCell = {
        let cell = CheckboxCell()
        cell.title = ""
        cell.setButtonType(.switch)
        cell.type = .nullCellType
        cell.isBordered = false
        cell.imagePosition = .imageOnly
        cell.alignment = .left
        cell.objectValue = NSNumber(booleanLiteral: false)
        cell.controlSize = .regular
        cell.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
        cell.allowsMixedState = true
        return cell
    }()
    
    // Hide the default "Field" text
    override var textColor: NSColor? {
        get { .clear }
        set { }
    }
    
    override var title: String {
        get { innerCell.title }
        set { innerCell.title = newValue }
    }
    
    override var image: NSImage? {
        get { innerCell.image }
        set { innerCell.image = newValue }
    }
    
    // We should not override `state` of this class.
    // Instead, a property named `alternateState` is better for accessing its innerCell's state.
    var alternateState: NSControl.StateValue {
        get { innerCell.alternateState }
        set { innerCell.alternateState = newValue }
    }
    
    func toggleAlternateState() -> NSControl.StateValue {
        innerCell.alternateState = (alternateState != .on ? .on : .off)
        return innerCell.alternateState
    }
    
    // Override the original -drawWithFrame:inView: will also remove the background or border of the original cell, which is not recommended.
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: cellFrame, in: controlView)
        // MAHEEP'S NOTE: I set the below value to 6 to change the alignment to LEFT. It was CENTERED before.
        let centeredRect = CGRect(
            x: cellFrame.minX + 6,
            y: cellFrame.midY - innerCell.cellSize.height / 2.0,
            width: innerCell.cellSize.width,
            height: innerCell.cellSize.height
        )
        innerCell.draw(withFrame: centeredRect, in: controlView)
    }
}
