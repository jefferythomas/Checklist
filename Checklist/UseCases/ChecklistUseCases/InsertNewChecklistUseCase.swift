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

    func insertNewChecklist(title: String, at index: Int) -> Promise<[Checklist]> {
        let checklistsRaceConditionSafe = self.checklists
        assert(0 ... checklistsRaceConditionSafe.count ~= index)

        return firstly {
            self.dataSource.create()
        } .map { dataSet in
            dataSet.items[0].renamed(to: title) // After the new checklist is created, set the name
        } .then { checklist in
            self.dataSource.update(dataSet: ChecklistDataSet(items: [checklist]))
        } .done { dataSet in
            self.checklists = checklistsRaceConditionSafe.inserted(dataSet.items[0], at: index)
        } .map {
            self.checklists
        }
    }

}
