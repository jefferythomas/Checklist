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

    func loadAllChecklists() -> Promise<Void> {
        return firstly {
            self.dataSource.fetch(ChecklistDataSource.Criteria())
        } .then { dataSet in
            self.checklists = dataSet.items
        }
    }
    
}