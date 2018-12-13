//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

struct ChecklistItem : Codable {

    let title: String
    let checked: Bool

}

extension ChecklistItem: Equatable {

    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        return lhs.title == rhs.title && lhs.checked == rhs.checked
    }

}
