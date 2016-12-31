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

    let title: String
    let checked: Bool

}

extension ChecklistItem: Equatable {

    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        return lhs.title == rhs.title && lhs.checked == rhs.checked
    }

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
