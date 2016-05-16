//
//  Checklist.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

class Checklist {
    var title: String
    var items: [ChecklistItem]

    init(title: String, items: [ChecklistItem]) {
        self.title = title
        self.items = items
    }
}
