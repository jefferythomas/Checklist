//
//  ChecklistTests.swift
//  ChecklistTests
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import XCTest
import PromiseKit
@testable import Checklist

class ChecklistTests: XCTestCase {
    let dataSource: ChecklistDataSource = {
        let dataSource = ChecklistDataSource()

        let path = "/tmp/ChecklistTests\(UUID().uuidString)/"
        dataSource.baseUrl = URL(fileURLWithPath: path, isDirectory: true)

        return dataSource
    }()

    deinit {
        try? dataSource.fileManager.removeItem(at: dataSource.baseUrl)
    }

    func testChecklistItemInitWithTitle() {
        let item = ChecklistItem(title: "test")

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, false)
    }

    func testChecklistItemInitWithTitleChecked() {
        let item = ChecklistItem(title: "test", checked: true)

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, true)
    }

    func testChecklistItemDecode() {
        let json: [String: Any] = ["title": "test", "checked": true]

        let item = try? ChecklistItem.decode(json)

        XCTAssertEqual(item, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistItemDecodeArray() {
        let json = [["title": "test", "checked": true]]

        let items = try? [ChecklistItem].decode(json)

        XCTAssertEqual(items?.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistItemEncode() {
        let item = ChecklistItem(title: "test")

        let json = try? item.JSONEncode()

        let title = (json as? [String: AnyObject])?["title"] as? String
        let checked = (json as? [String: AnyObject])?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(checked, false)
    }

    func testChecklistInitWithId() {
        let checklist = Checklist(id: "id")

        XCTAssertEqual(checklist.id, "id")
        XCTAssertEqual(checklist.title, "")
        XCTAssertEqual(checklist.items, [])
    }

    func testChecklistInitWithIdTitle() {
        let checklist = Checklist(id: "id", title: "test")

        XCTAssertEqual(checklist.id, "id")
        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [])
    }

    func testChecklistInitIdItems() {
        let checklist = Checklist(id: "id", items: [ChecklistItem(title: "test")])

        XCTAssertEqual(checklist.id, "id")
        XCTAssertEqual(checklist.title, "")
        XCTAssertEqual(checklist.items, [ChecklistItem(title: "test")])
    }

    func testChecklistInitIdTitleItems() {
        let checklist = Checklist(id: "id", title: "test", items: [ChecklistItem(title: "test")])

        XCTAssertEqual(checklist.id, "id")
        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [ChecklistItem(title: "test")])
    }

    func testChecklistChecked() {
        var checklist = Checklist(id: "id", title: "test", items: [ChecklistItem(title: "test")])

        XCTAssertEqual(checklist.items.count, 1)
        XCTAssertEqual(checklist.items[0].checked, false)
        checklist.items[0].checked = true
        XCTAssertEqual(checklist.items[0].checked, true)
    }

    func testChecklistDecode() {
        let json: [String: Any] = ["id": "id", "title": "test", "items": [["title": "test", "checked": true]]]

        let checklist = try? Checklist.decode(json)

        XCTAssertEqual(checklist?.title, "test")
        XCTAssertEqual(checklist?.items.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistEncode() {
        let checklist = Checklist(id: "id", title: "test", items: [ChecklistItem(title: "test", checked: true)])

        let json = try? checklist.JSONEncode()

        let title = (json as? [String: AnyObject])?["title"] as? String
        let items = (json as? [String: AnyObject])?["items"] as? [[String: AnyObject]]
        let firstItemTitle = items?.first?["title"] as? String
        let firstItemChecked = items?.first?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(firstItemTitle, "test")
        XCTAssertEqual(firstItemChecked, true)
    }

    func testDataSet() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])
    }

    func testDataSetSortItems() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])

        dataSet.items.sort(by: >)
        XCTAssertEqual(dataSet.items, ["c", "b", "a"])
    }

    func testDataSetResetItems() {
        let dataSet = DataSet(items: ["a", "b", "c"])
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])

        dataSet.items.sort(by: >)
        XCTAssertEqual(dataSet.items, ["c", "b", "a"])

        dataSet.reset()
        XCTAssertEqual(dataSet.items, ["a", "b", "c"])
    }

    func testChecklistDataSourceUrlForId() {
        let url = dataSource.url(forId: "test")

        XCTAssertEqual(url.lastPathComponent, "test.json")
    }

    func testChecklistDataSourceCreateAndDelete() {
        let ex = expectation(description: "testChecklistDataSourceCreateAndDelete")

        firstly {
            self.dataSource.create()
        } .then { dataSet -> ChecklistDataSet in
            XCTAssertTrue(self._hasChecklist(id: dataSet.items[0].id, in: self.dataSource))
            return dataSet
        } .then { dataSet in
            self.dataSource.delete(dataSet: dataSet)
        } .then { dataSet in
            XCTAssertFalse(self._hasChecklist(id: dataSet.items[0].id, in: self.dataSource))
        } .then {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistById() {
        let ex = expectation(description: "testChecklistDataSourceCreateAndDeleteId")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { _ in
            XCTAssertTrue(self._hasChecklist(id: id, in: self.dataSource))
        } .then {
            self.dataSource.delete(ids: [id])
        } .then { _ in
            XCTAssertFalse(self._hasChecklist(id: id, in: self.dataSource))
        } .then {
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByTitle() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByTitle")

        firstly {
            self.dataSource.create()
        } .then { dataSet -> ChecklistDataSetPromise in
            dataSet.items[0].title = "test"
            return self.dataSource.update(dataSet: dataSet)
        } .then { _ in
            self.dataSource.fetch(ChecklistDataSource.Criteria(titles: ["test"]))
        } .then { dataSet -> ChecklistDataSet in
            XCTAssertEqual(dataSet.items.first?.title, "test")
            return dataSet
        } .then { dataSet in
            self.dataSource.delete(dataSet: dataSet)
        } .then { _ in
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByIdTitle() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByIdTitle")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { dataSet -> ChecklistDataSetPromise in
            dataSet.items[0].title = "test"
            return self.dataSource.update(dataSet: dataSet)
        } .then { _ in
            self.dataSource.fetch(ChecklistDataSource.Criteria(ids: [id], titles: ["test"]))
        } .then { dataSet in
            XCTAssertEqual(dataSet.items.first?.title, "test")
        } .then {
            self.dataSource.delete(ids: [id])
        } .then { _ in
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklistByChecklist() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklistByChecklist")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { dataSet in
            self.dataSource.fetch(dataSet.items[0])
        } .then { dataSet -> () in
            XCTAssertEqual(dataSet.items.count, 1)
            XCTAssertEqual(dataSet.items.first?.id, id)
        } .then {
            self.dataSource.delete(ids: [id])
        } .then { _ in
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchChecklists() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklists")
        let id = NSUUID().uuidString

        firstly {
            self.dataSource.create(id: id)
        } .then { _ in
            self.dataSource.fetch(ChecklistDataSource.Criteria())
        } .then { dataSet in
            XCTAssertTrue(dataSet.items.contains { checklist in checklist.id == id })
        } .then {
            self.dataSource.delete(ids: [id])
        } .then { _ in
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    // MARK: Private

    private func _hasChecklist(id: String, in dataSource: ChecklistDataSource) -> Bool {
        return dataSource.fileManager.fileExists(atPath: dataSource.url(forId: id).path)
    }

}
