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

    func loadAllChecklists(into checklists: ChecklistDataSet) -> Promise<Void> {
        return firstly {
            self.dataSource.fetch(ChecklistDataSource.Criteria())
        } .then { dataSet in
            checklists.items = dataSet.items
        }
    }
    
}
