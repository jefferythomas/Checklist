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
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChecklistItemInitWithChecked() {
        let item = ChecklistItem(title: "test", checked: true)

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, true)
    }

    func testChecklistItemDecode() {
        let json = ["title": "test", "checked": true]

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
        let checklist = Checklist(title: "test", items: [])

        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [])
    }

    func testChecklistChecked() {
        var checklist = Checklist(title: "test", items: [ChecklistItem(title: "test", checked: false)])

        XCTAssertEqual(checklist.items.count, 1)
        XCTAssertEqual(checklist.items[0].checked, false)
        checklist.items[0].checked = true
        XCTAssertEqual(checklist.items[0].checked, true)
    }

    func testChecklistDecode() {
        let json = ["title": "test", "items": [["title": "test", "checked": true]]]

        let checklist = try? Checklist.decode(json)

        XCTAssertEqual(checklist?.title, "test")
        XCTAssertEqual(checklist?.items.first, ChecklistItem(title: "test", checked: true))
    }

    func testChecklistEncode() {
        let checklist = Checklist(title: "test", items: [ChecklistItem(title: "test", checked: true)])

        let json = try? checklist.JSONEncode()

        let title = (json as? [String: AnyObject])?["title"] as? String
        let items = (json as? [String: AnyObject])?["items"] as? [[String: AnyObject]]
        let firstItemTitle = items?.first?["title"] as? String
        let firstItemChecked = items?.first?["checked"] as? Bool

        XCTAssertEqual(title, "test")
        XCTAssertEqual(firstItemTitle, "test")
        XCTAssertEqual(firstItemChecked, true)
    }

    func testChecklistDataSourceURLForIdentifier() {
        let dataSource = ChecklistDataSource()

        let URL = try? dataSource.URLForIdentifier("test")

        XCTAssertEqual(URL?.lastPathComponent, "test.json")
    }

    func testChecklistDataSourceURLForIdentifierWithSpecialCharacters() {
        let dataSource = ChecklistDataSource()

        let URL = try? dataSource.URLForIdentifier("test test./")

        XCTAssertEqual(URL?.lastPathComponent, "test%20test%2E%2F.json")
    }

    func testChecklistDataSourceStore() {
        let expectation = expectationWithDescription("testChecklistDataSourceStore")

        let UUID = NSUUID().UUIDString
        let checklist = Checklist(title: "test", items: [])
        let initialDataSet = ChecklistDataSet(identifier: UUID, checklists: [checklist])

        let dataSource = ChecklistDataSource()

        firstly {
            return dataSource.updateChecklists(initialDataSet)
        } .then { storedDataSet -> () in
            let URL = try dataSource.URLForIdentifier(storedDataSet.identifier)

            XCTAssertEqual(storedDataSet.checklists.count, 1)
            XCTAssertEqual(storedDataSet.checklists.first?.title, "test")

            XCTAssertTrue(dataSource.fileManager.fileExistsAtPath(URL.path!))
            try dataSource.fileManager.removeItemAtURL(URL)
            XCTAssertFalse(dataSource.fileManager.fileExistsAtPath(URL.path!))
        } .recover { error in
            XCTFail("error: \(error)")
        } .always {
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetch() {
        let expectation = expectationWithDescription("testChecklistDataSourceFetch")

        let checklist = Checklist(title: "test", items: [])
        let initialDataSet = ChecklistDataSet(identifier: NSUUID().UUIDString, checklists: [checklist])
        let dataSource = ChecklistDataSource()

        firstly {
            return dataSource.updateChecklists(initialDataSet)
        } .then { storedDataSet in
            return dataSource.fetchChecklistsWithIdentifier(storedDataSet.identifier)
        } .then { fetchedDataSet -> () in
            let URL = try dataSource.URLForIdentifier(fetchedDataSet.identifier)

            XCTAssertEqual(fetchedDataSet.checklists.count, 1)
            XCTAssertEqual(fetchedDataSet.checklists.first?.title, "test")

            XCTAssertTrue(dataSource.fileManager.fileExistsAtPath(URL.path!))
            try dataSource.fileManager.removeItemAtURL(URL)
            XCTAssertFalse(dataSource.fileManager.fileExistsAtPath(URL.path!))
        } .recover { error in
                XCTFail("error: \(error)")
        } .always {
                expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0) { error in XCTAssertNil(error) }
    }

    func testChecklistDataSourceFetchCreate() {
        let expectation = expectationWithDescription("testChecklistDataSourceFetchCreate")

        let dataSource = ChecklistDataSource()

        firstly {
            return dataSource.fetchChecklistsWithIdentifier(NSUUID().UUIDString)
        } .then { fetchedDataSet -> () in
            let URL = try dataSource.URLForIdentifier(fetchedDataSet.identifier)

            XCTAssertEqual(fetchedDataSet.checklists.count, 0)

            XCTAssertFalse(dataSource.fileManager.fileExistsAtPath(URL.path!))
        } .recover { error in
            XCTFail("error: \(error)")
        } .always {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0) { error in XCTAssertNil(error) }
    }

}
