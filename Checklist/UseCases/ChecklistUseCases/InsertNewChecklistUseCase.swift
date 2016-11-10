//
//  InsertNewChecklistUseCase.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit

extension ChecklistBusinessLogic {

    func insertNewChecklist(title: String, into checklists: ChecklistDataSet, at index: Int) -> Promise<Void> {
        return firstly {
            self.dataSource.create()
        } .then { dataSet -> ChecklistDataSet in
            dataSet.items[0].title = title
            return dataSet
        } .then { dataSet in
            return self.dataSource.update(dataSet: dataSet)
        } .then { dataSet in
            checklists.items.insert(dataSet.items[0], at: index)
        }
    }

}
