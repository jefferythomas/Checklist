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

    func testChecklistItemInitWithChecked() {
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
        let item = ChecklistItem(title: "test", checked: false)

        let json = try? item.JSONEncode()

        let title = (json as? [String: AnyObject])?["title"] as? String
        let checked = (json as? [String: AnyObject])?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(checked, false)
    }

    func testChecklistInit() {
        let checklist = Checklist(id: "id", title: "test", items: [])

        XCTAssertEqual(checklist.id, "id")
        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [])
    }

    func testChecklistChecked() {
        var checklist = Checklist(id: "id", title: "test", items: [ChecklistItem(title: "test", checked: false)])

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
        let id = NSUUID().uuidString

        firstly {
            self._createChecklist(id: id, in: self.dataSource)
        } .then { _ in
            XCTAssertTrue(self._hasChecklist(id: id, in: self.dataSource))
        } .then {
            self._deleteChecklist(id: id, in: self.dataSource)
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

    func testChecklistDataSourceFetchChecklist() {
        let ex = expectation(description: "testChecklistDataSourceFetchChecklist")
        let id = NSUUID().uuidString

        firstly {
            self._createChecklist(id: id, in: self.dataSource)
        } .then { _ in
            self.dataSource.fetchChecklist(id: id)
        } .then { dataSet in
            XCTAssertEqual(dataSet.items.first?.id, id)
        } .then {
            self._deleteChecklist(id: id, in: self.dataSource)
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
            self._createChecklist(id: id, in: self.dataSource)
        } .then { _ in
            self.dataSource.fetchChecklists()
        } .then { dataSet in
            XCTAssertTrue(dataSet.items.contains { checklist in checklist.id == id })
        } .then {
            self._deleteChecklist(id: id, in: self.dataSource)
        } .then { _ in
            ex.fulfill()
        } .catch { error in
            XCTFail("error: \(error)")
            ex.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in XCTAssertNil(error) }
    }

    // MARK: Private

    private func _createChecklist(id: String, in dataSource: ChecklistDataSource) -> ChecklistDataSetPromise {
        return dataSource.updateChecklists(DataSet(items: [Checklist(id: id, title: id, items: [])]))
    }

    private func _deleteChecklist(id: String, in dataSource: ChecklistDataSource) -> ChecklistDataSetPromise {
        return dataSource.deleteChecklist(id: id)
    }

    private func _hasChecklist(id: String, in dataSource: ChecklistDataSource) -> Bool {
        return dataSource.fileManager.fileExists(atPath: dataSource.url(forId: id).path)
    }

}
