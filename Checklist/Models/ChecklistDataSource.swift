//
//  ChecklistDataSource.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/30/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import Foundation
import PromiseKit
import Decodable

typealias ChecklistDataSet = DataSet<Checklist>
typealias ChecklistDataSetPromise = Promise<ChecklistDataSet>

class ChecklistDataSource {
    // MARK: Data source API

    func create() -> ChecklistDataSetPromise {
        return create(id: uniqueId())
    }

    func create(id: String) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise {
            DataSet(items: [Checklist(id: id, title: "", items: [])])
        }.then { dataSet in
            self.update(dataSet: dataSet)
        }
    }

    func fetch(_ fetchable: ChecklistFetchable) -> ChecklistDataSetPromise {
        if fetchable.idsToFetch.count > 0, fetchable.titlesToFetch.count == 0 {
            return _specializedFetchUsingOnlyIds(fetchable.idsToFetch)
        }

        let isIncluded = _filterClosureForChecklist(fetchable: fetchable)

        return DispatchQueue.main.promise { () -> ChecklistDataSet in
            let enumerator = self.fileManager.enumerator(at: self.baseUrl, includingPropertiesForKeys: [])!

            let items = try enumerator.allObjects.map { url in
                return try Checklist._from(fileUrl: url as! URL)
            }.filter(isIncluded)

            return DataSet(items: items)
        }
    }

    func update(dataSet: ChecklistDataSet) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise {
            for checklist in dataSet.items {
                let url = self.url(forId: checklist.id)
                let json = try checklist.JSONEncode()

                let data = try JSONSerialization.data(withJSONObject: json)
                try data.write(to: url)
            }

            return dataSet // JLT: For now, echo back the input
        }
    }

    func delete(dataSet: ChecklistDataSet) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise {
            for checklist in dataSet.items {
                try self.fileManager.removeItem(at: self.url(forId: checklist.id))
            }

            return dataSet // JLT: For now, echo back the input
        }
    }

    func delete(ids: [String]) -> ChecklistDataSetPromise {
        return firstly {
            self.fetch(Criteria(ids: ids))
        }.then { dataSet in
            self.delete(dataSet: dataSet)
        }
    }

    // MARK: Auxlilary methods

    lazy var fileManager = FileManager.default

    var baseUrl: URL {
        get {
            if _baseUrl == nil { _baseUrl = _ensureDirectory(_defaultBaseUrl()) }
            return _baseUrl!
        }

        set {
            _baseUrl = _ensureDirectory(newValue)
        }
    }
    
    func url(forId id: String) -> URL {
        return baseUrl.appendingPathComponent(id).appendingPathExtension("json")
    }

    func uniqueId() -> String {
        return NSUUID().uuidString
    }

    // MARK: Private

    private var _baseUrl: URL?

    private func _defaultBaseUrl() -> URL {
        let urls = fileManager.urls(for: .documentDirectory, in: [.userDomainMask])
        return urls[0].appendingPathComponent("checklists", isDirectory: true)
    }

    private func _ensureDirectory(_ url: URL) -> URL {
        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            assert(isDir.boolValue, "\(url) exists, but is not a directory")
        } else {
            try! fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }

        return url
    }

    private func _specializedFetchUsingOnlyIds(_ ids: [String]) -> ChecklistDataSetPromise {
        return DispatchQueue.main.promise { () -> ChecklistDataSet in
            let checklists = try ids.map { id in try Checklist._from(fileUrl: self.url(forId: id)) }

            return DataSet(items: checklists)
        }
    }

    private func _filterClosureForChecklist(fetchable: ChecklistFetchable) -> (Checklist) -> Bool {
        let ids = fetchable.idsToFetch
        let titles = fetchable.titlesToFetch

        if ids.count > 0 && titles.count > 0 {
            return { checklist in ids.contains(checklist.id) && titles.contains(checklist.title) }
        } else if ids.count > 0 {
            return { checklist in ids.contains(checklist.id) }
        } else if titles.count > 0 {
            return { checklist in titles.contains(checklist.title) }
        } else {
            return { _ in true }
        }
    }
}

extension ChecklistDataSource {
    // The default implementation of ChecklistFetchable
    struct Criteria: ChecklistFetchable {
        let idsToFetch: [String]
        let titlesToFetch: [String]

        init(ids: [String] = [], titles: [String] = []) {
            idsToFetch = ids
            titlesToFetch = titles
        }
    }
}

fileprivate extension Checklist {
    // Deserialze a checklist from a file URL.
    static func _from(fileUrl: URL) throws -> Checklist {
        let data = try Data(contentsOf: fileUrl)
        let json = try JSONSerialization.jsonObject(with: data)
        return try Checklist.decode(json)
    }
}
