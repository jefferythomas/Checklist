//
//  RenameChecklistUseCase.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit

extension ChecklistBusinessLogic {

    func renameChecklist(title: String, at index: Int) -> Promise<Void> {
        let checklistsRaceConditionSafe = checklists
        assert(0 ..< checklistsRaceConditionSafe.count ~= index)

        let renamedChecklist = checklistsRaceConditionSafe[index].renamed(to: title)

        return firstly {
            self.dataSource.update(dataSet: ChecklistDataSet(items: [renamedChecklist]))
        } .then { dataSet in
            self.checklists = checklistsRaceConditionSafe.replaced(at: index, with: dataSet.items[0])
        }
    }
    
}
