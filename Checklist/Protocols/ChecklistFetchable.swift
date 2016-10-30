//
//  ChecklistFetchable.swift
//  Checklist
//
//  Created by Jeffery Thomas on 10/26/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

protocol ChecklistFetchable {
    var idsToFetch: [String] { get }
    var titlesToFetch: [String] { get }
}
