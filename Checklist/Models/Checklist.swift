//
//  Checklist.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import Decodable

class Checklist {
    var title: String
    var items: [ChecklistItem]

    required init(title: String, items: [ChecklistItem]) {
        self.title = title
        self.items = items
    }
}

extension Checklist: Decodable {
    static func decode(json: AnyObject) throws -> Self {
        return try self.init(
            title: json => "title",
            items: json => "items"
        )
    }
}
