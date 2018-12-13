//
//  TearChecklistUseCase.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit

extension ChecklistBusinessLogic {

    func tearChecklist(at index: Int) -> Promise<Void> {
        let checklistsRaceConditionSafe = self.checklists
        assert(0 ..< checklistsRaceConditionSafe.count ~= index)

        let tornChecklist = checklistsRaceConditionSafe[index]._torn()

        return firstly {
            self.dataSource.update(dataSet: ChecklistDataSet(items: [tornChecklist]))
        } .done { dataSet in
            self.checklists = checklistsRaceConditionSafe.replaced(at: index, with: dataSet.items[0])
        }
    }
    
}

extension Checklist {

    fileprivate func _torn() -> Checklist {
        return Checklist(id: id,
                         title: title,
                         items: items.map { ChecklistItem(title: $0.title, checked: false) })
    }

}
