//
//  LoadAllChecklistsUseCase.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit

extension ChecklistBusinessLogic {

    func loadAllChecklists() -> Promise<[Checklist]> {
        return firstly {
            self.dataSource.fetch(ChecklistDataSource.Criteria()) // fetching empty critera returns all checklists
        } .done { dataSet in
            self.checklists = dataSet.items
        } .map {
            self.checklists
        }
    }
    
}
