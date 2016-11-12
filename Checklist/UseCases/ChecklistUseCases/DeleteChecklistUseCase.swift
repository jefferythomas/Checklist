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

    func deleteChecklist(at index: Int) -> Promise<Void> {
        let checklistsRaceConditionSafe = self.checklists

        return firstly {
            self.dataSource.delete(dataSet: ChecklistDataSet(items: [self.checklists[index]]))
        } .then { dataSet in
            self.checklists = checklistsRaceConditionSafe.removed(at: index)
        }
    }
    
}

extension Array {

    func removed(at index: Int) -> Array {
        var result = self
        result.remove(at: index)
        return result
    }
    
}
