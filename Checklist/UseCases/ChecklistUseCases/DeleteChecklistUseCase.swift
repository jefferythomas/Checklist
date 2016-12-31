//
//  DeleteChecklistUseCase.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/10/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit

extension ChecklistBusinessLogic {

    func deleteChecklist(at index: Int) -> Promise<[Checklist]> {
        let checklistsRaceConditionSafe = self.checklists
        assert(0 ..< checklistsRaceConditionSafe.count ~= index)

        let deletedChecklist = checklistsRaceConditionSafe[index]

        return firstly {
            self.dataSource.delete(dataSet: ChecklistDataSet(items: [deletedChecklist]))
        } .then { dataSet in
            self.checklists = checklistsRaceConditionSafe._removed(at: index)
        } .then {
            self.checklists
        }
    }
    
}

extension Array {

    fileprivate func _removed(at index: Int) -> Array {
        var result = self
        result.remove(at: index)
        return result
    }
    
}
