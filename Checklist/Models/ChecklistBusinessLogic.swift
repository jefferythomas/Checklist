//
//  ChecklistBusinessLogic.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation

class ChecklistBusinessLogic {
    static let sharedInstance = ChecklistBusinessLogic()

    lazy var dataSource = ChecklistDataSource()
}
