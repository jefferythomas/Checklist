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

    func deleteChecklist(from checklists: ChecklistDataSet, at index: Int) -> Promise<Void> {
        return firstly {
            self.dataSource.delete(dataSet: ChecklistDataSet(items: [checklists.items[index]]))
        } .then { dataSet in
            checklists.items.remove(at: index)
        }
    }
    
}
