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
    var id: String
    var title: String
    var items: [ChecklistItem]
}

extension Checklist: Decodable {
    static func decode(_ json: Any) throws -> Checklist {
        return try self.init(
            id: json => "id",
            title: json => "title",
            items: json => "items"
        )
    }
}

extension Checklist: JSONEncodable {
    func JSONEncode() throws -> Any {
        return ["id": id, "title": title, "items": try items.JSONEncode()]
    }
}
