//
//  TextFieldTableViewCell.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/13/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet var textTextField: UITextField?
    
}

class EditableTextFieldTableViewCell: TextFieldTableViewCell {

    override func willTransition(to state: UITableViewCellStateMask) {
        super.willTransition(to: state)
        textTextField?.setAppearanceForEditing(state.contains(.showingEditControlMask))
    }

}

extension UITextField {

    func setAppearanceForEditing(_ editing: Bool) {
        isUserInteractionEnabled = editing
        borderStyle = editing ? .bezel : .none

        // NOTE: This fixes an issue in UITextField.borderStyle. When borderStyle is set to .none,
        //       an outline will appear if the backgroundColor is nil.
        if backgroundColor == nil { backgroundColor = UIColor.clear }
    }

}
