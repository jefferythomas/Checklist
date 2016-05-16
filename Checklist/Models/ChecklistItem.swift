//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

class ChecklistItem {

    var title: String
    var checked: Bool

    init(title: String, checked: Bool) {
        self.title = title
        self.checked = checked
    }

    convenience init(title: String) {
        self.init(title: title, checked: false)
    }

}

extension ChecklistItem: Equatable { }
func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
    return lhs.checked == rhs.checked && lhs.title == rhs.title
}
