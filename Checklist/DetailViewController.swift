//
//  DetailViewController.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    lazy var businessLogic = ChecklistBusinessLogic.sharedInstance
    var indexInBusinessLogicChecklist: Int?
    lazy var defaultTitle = "Checklist Item"

    var checklist: Checklist? {
        get {
            guard let index = indexInBusinessLogicChecklist else { return nil }
            return businessLogic.checklists[index]
        }

        set(checklist) {
            guard let checklist = checklist else { return updateIndexInBusinessLogicChecklist(nil) }
            updateIndexInBusinessLogicChecklist(businessLogic.checklists.index(of: checklist))
        }
    }

    @IBAction func insertNewChecklistItem(_ sender: Any?) {
        insertNewChecklistItem(title: defaultTitle, at: IndexPath(row: 0, section: 0))
    }

    @IBAction func dissmissKeyboard(_ sender: Any?) {
        self.view.endEditing(true)
    }

    func tearChecklist() {
        guard let index = indexInBusinessLogicChecklist else { return }

        businessLogic.tearChecklist(at: index).done {
            self.tableView._reloadVisibleRows(with: .none)
        } .catch { error in
            print("Unable to tear checklist: \(error)")
        }
    }

    func insertNewChecklistItem(title: String, at indexPath: IndexPath) {
        guard let index = indexInBusinessLogicChecklist else { return }

        businessLogic.insertNewChecklistItem(title: defaultTitle, at: indexPath.row, intoChecklistAt: index).done {
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        } .catch { error in
            print("Unable to insert new checklist item: \(error)")
        }
    }

    func deleteChecklistItem(at indexPath: IndexPath) {
    }

    func renameChecklistItem(title: String, at indexPath: IndexPath) {
    }

    func updateIndexInBusinessLogicChecklist(_ index: Int?) {
        indexInBusinessLogicChecklist = index
    }

    func createLeftBarButtonItems() -> [UIBarButtonItem] {
        if let splitViewController = splitViewController {
            return [splitViewController.displayModeButtonItem, editButtonItem]
        } else {
            return [editButtonItem]
        }
    }

    func createRightBarButtonItems() -> [UIBarButtonItem] {
        let addAction = #selector(insertNewChecklistItem(_:))
        return [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: addAction)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItems = createLeftBarButtonItems()
        navigationItem.rightBarButtonItems = createRightBarButtonItems()
        navigationItem.leftItemsSupplementBackButton = true
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

}

extension DetailViewController /* UITableViewDataSource, UITableViewDelegate */ {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TextFieldTableViewCell
        let title = checklist?.items[indexPath.row].title

        cell.textTextField?.text = title

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        switch editingStyle {
        case .delete: deleteChecklistItem(at: indexPath)
        case .insert: insertNewChecklistItem(title: defaultTitle, at: indexPath)
        default:      break
        }
    }

}

extension DetailViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let title = textField.text else { return }
        guard let indexPath = textField.indexPathOfSuperTableViewCell else { return }
        guard title != checklist?.items[indexPath.row].title else { return }

        renameChecklistItem(title: title, at: indexPath)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dissmissKeyboard(textField)
        return true
    }
    
}

extension UITableView {
    fileprivate func _reloadVisibleRows(with animation: UITableViewRowAnimation) {
        reloadRows(at: indexPathsForVisibleRows ?? [], with: animation)
    }
}
