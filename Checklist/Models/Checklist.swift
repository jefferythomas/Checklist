//
//  Checklist.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/15/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

struct Checklist : Codable {

    let id: String
    let title: String
    let items: [ChecklistItem]

}

extension Checklist: Equatable {

    static func ==(lhs: Checklist, rhs: Checklist) -> Bool {
        return lhs.id == rhs.id
    }

}

extension Checklist: ChecklistFetchable {

    var idsToFetch: [String] { return [id] }
    var titlesToFetch: [String] { return [] }

}
