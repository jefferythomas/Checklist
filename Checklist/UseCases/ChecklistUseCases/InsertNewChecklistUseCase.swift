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

    func insertNewChecklist(title: String, at index: Int) -> Promise<Void> {
        let checklistsRaceConditionSafe = self.checklists

        return firstly {
            self.dataSource.create()
        } .then { dataSet in
            Checklist(id: dataSet.items[0].id, title: title, items:[])
        } .then { checklist in
            self.dataSource.update(dataSet: ChecklistDataSet(items: [checklist]))
        } .then { dataSet in
            self.checklists = checklistsRaceConditionSafe.inserted(dataSet.items[0], at: index)
        }
    }

}

extension Array {

    func inserted(_ element: Element, at index: Int) -> Array {
        var result = self
        result.insert(element, at: index)
        return result
    }

}
