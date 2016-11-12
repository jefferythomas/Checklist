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
        let checklistsRaceConditionSafe = self.checklists

        let renamedChecklist = Checklist(id: self.checklists[index].id,
                                         title: title,
                                         items: self.checklists[index].items)

        return firstly {
            self.dataSource.update(dataSet: ChecklistDataSet(items: [renamedChecklist]))
        } .then { dataSet in
            self.checklists = checklistsRaceConditionSafe.replaced(at: index, with: dataSet.items[0])
        }
    }
    
}

extension Array {

    func replaced(at index: Int, with element: Element) -> Array {
        var result = self
        result[index] = element
        return result
    }

}
