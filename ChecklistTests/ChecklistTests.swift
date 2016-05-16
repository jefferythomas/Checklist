//
//  ChecklistTests.swift
//  ChecklistTests
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import XCTest
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
    
    func testChecklistItemInitWithoutChecked() {
        let item = ChecklistItem(title: "test")

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, false)
    }

    func testChecklistItemInitWithChecked() {
        let item = ChecklistItem(title: "test", checked: true)

        XCTAssertEqual(item.title, "test")
        XCTAssertEqual(item.checked, true)
    }

    func testChecklistInit() {
        let checklist = Checklist(title: "test", items: [])

        XCTAssertEqual(checklist.title, "test")
        XCTAssertEqual(checklist.items, [])
    }

    func testChecklistChecked() {
        let checklist = Checklist(title: "test", items: [ChecklistItem(title: "test")])

        XCTAssertEqual(checklist.items.first?.checked, false)
        checklist.items.first?.checked = true
        XCTAssertEqual(checklist.items.first?.checked, true)
    }

}
