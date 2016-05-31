//
//  Checklist.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import Decodable

struct Checklist {
    var title: String
    var items: [ChecklistItem]
}

extension Checklist: Decodable {
    static func decode(json: AnyObject) throws -> Checklist {
        return try self.init(
            title: json => "title",
            items: json => "items"
        )
    }

    func encode() -> AnyObject {
        return ["title": title, "items": items.map { item in item.encode() }]
    }
}
