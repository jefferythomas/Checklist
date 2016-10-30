//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import Decodable

struct ChecklistItem {
    var title: String
    var checked: Bool

    init(title: String, checked: Bool = false) {
        self.title = title
        self.checked = checked
    }
}

extension ChecklistItem: Equatable { }
func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
    return lhs.checked == rhs.checked && lhs.title == rhs.title
}

extension ChecklistItem: Decodable {
    static func decode(_ json: Any) throws -> ChecklistItem {
        return try self.init(
            title: json => "title",
            checked: json => "checked"
        )
    }
}

extension ChecklistItem: JSONEncodable {
    func JSONEncode() throws -> Any {
        return ["title": title, "checked": checked]
    }
}
