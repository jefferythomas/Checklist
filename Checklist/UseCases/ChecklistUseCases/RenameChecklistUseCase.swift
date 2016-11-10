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

    func renameChecklist(title: String, in checklists: ChecklistDataSet, at index: Int) -> Promise<Void> {
        return DispatchQueue.main.promise { () -> ChecklistDataSet in
            var checklist = checklists.items[index]

            checklist.title = title

            return ChecklistDataSet(items: [checklist])
        } .then { dataSet in
            return self.dataSource.update(dataSet: checklists)
        } .then { dataSet in
            checklists.items[index] = dataSet.items[0]
        }
    }
    
}
