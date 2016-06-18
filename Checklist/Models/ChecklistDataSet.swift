//
//  ChecklistDataSet.swift
//  Checklist
//
//  Created by Jeffery Thomas on 6/3/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Decodable

enum ChecklistDataSetError: ErrorType {
    case InvalidIndex(index: Int)
}

class ChecklistDataSet {
    let identifier: String
    var checklists: [Checklist]

    required init(identifier: String, checklists: [Checklist]) {
        self.identifier = identifier
        self.checklists = checklists
    }
}

extension ChecklistDataSet: Decodable {
    static func decode(json: AnyObject) throws -> Self {
        return try self.init(identifier: json => "identifier", checklists: json => "checklists")
    }
}

extension ChecklistDataSet: JSONEncodable {
    func JSONEncode() throws -> AnyObject {
        return ["identifier": identifier, "checklists": try checklists.JSONEncode()]
    }
}
