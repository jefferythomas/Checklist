//
//  DataSet.swift
//  Checklist
//
//  Created by Jeffery Thomas on 10/6/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

class DataSet<Element> {

    private(set) var items: [Element]

    init(items: [Element]) {
        self.items = items
        self._initialItems = items
    }

    func sort(by: ((Element, Element) -> Bool)?) {
        _sortBy = by
    }

    func filter(with: ((Element) -> Bool)?) {
        _filterWith = with
    }

    private let _initialItems: [Element]
    private var _sortBy: ((Element, Element) -> Bool)? { didSet { _updateItems() } }
    private var _filterWith: ((Element) -> Bool)? { didSet { _updateItems() } }

    private func _updateItems() {
        items = _initialItems
        if let sortBy = _sortBy { items = items.sorted(by: sortBy) }
        if let filterWith = _filterWith { items = items.filter(filterWith) }
    }

}
