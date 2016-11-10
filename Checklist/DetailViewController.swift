//
//  DetailViewController.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var checklist: Checklist? { didSet { self.configureView() } }

    @IBOutlet var detailDescriptionLabel: UILabel?

    func configureView() {
        if let checklist = self.checklist {
            self.detailDescriptionLabel?.text = checklist.title
        } else {
            self.detailDescriptionLabel?.text = "No Content"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()

        if let splitViewController = self.splitViewController {
            self.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
            self.navigationItem.leftItemsSupplementBackButton = true
        }
    }

}
