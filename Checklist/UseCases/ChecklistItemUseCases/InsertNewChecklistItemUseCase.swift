//
//  InsertNewChecklistItemUseCase.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit

extension ChecklistBusinessLogic {

    func insertNewChecklistItem(title: String, at itemIndex: Int, intoChecklistAt index: Int) -> Promise<Void> {
        let checklistsRaceConditionSafe = self.checklists
        assert(0 ..< checklistsRaceConditionSafe.count ~= index)

        let item = ChecklistItem(title: title,
                                 checked: false)

        let checklist = checklistsRaceConditionSafe[index]._inserted(item, at: itemIndex)

        return firstly {
            self.dataSource.update(dataSet: ChecklistDataSet(items: [checklist]))
        } .then { dataSet in
            self.checklists = checklistsRaceConditionSafe.replaced(at: index, with: dataSet.items[0])
        }
    }
    
}

extension Checklist {

    fileprivate func _inserted(_ item: ChecklistItem, at itemIndex: Int) -> Checklist {
        return Checklist(id: id,
                         title: title,
                         items: items.inserted(item, at: itemIndex))
    }
    
}
