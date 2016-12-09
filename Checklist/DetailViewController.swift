//
//  DetailViewController.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    lazy var businessLogic = ChecklistBusinessLogic.sharedInstance
    var indexInBusinessLogicChecklist: Int?

    var checklist: Checklist? {
        get {
            guard let index = indexInBusinessLogicChecklist else {
                return nil
            }

            return businessLogic.checklists[index]
        }

        set(checklist) {
            guard let checklist = checklist, let index = businessLogic.checklists.index(of: checklist) else {
                indexInBusinessLogicChecklist = nil
                return
            }

            indexInBusinessLogicChecklist = index
        }
    }

    @IBOutlet var detailDescriptionLabel: UILabel?

    func configureView() {
        guard let checklist = checklist else {
            detailDescriptionLabel?.text = "No Content"
            return
        }

        detailDescriptionLabel?.text = checklist.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        if let splitViewController = splitViewController {
            navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            navigationItem.leftItemsSupplementBackButton = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }

}
