//
//  DataSet.swift
//  Checklist
//
//  Created by Jeffery Thomas on 10/6/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

class DataSet<Element> {
    var items: [Element]
    private let _initialItems: [Element]

    init(items: [Element]) {
        self.items = items
        self._initialItems = items
    }

    func reset() {
        self.items = self._initialItems;
    }
}
