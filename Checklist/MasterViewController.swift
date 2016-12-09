//
//  MasterViewController.swift
//  Checklist
//
//  Created by Jeffery Thomas on 5/14/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    lazy var businessLogic = ChecklistBusinessLogic.sharedInstance
    lazy var defaultTitle = "Checklist"

    @IBAction func insertNewChecklist(_ sender: Any?) {
        insertNewChecklist(title: defaultTitle, at: IndexPath(row: 0, section: 0))
    }

    @IBAction func dissmissKeyboard(_ sender: Any?) {
        self.view.endEditing(true)
    }

    func insertNewChecklist(title: String, at indexPath: IndexPath) {
        businessLogic.insertNewChecklist(title: title, at: indexPath.row).then {
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        } .catch { error in
            print("Unable to insert new checklist to checklists: \(error)")
        }
    }

    func deleteChecklist(at indexPath: IndexPath) {
        businessLogic.deleteChecklist(at: indexPath.row).then {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        } .catch { error in
            print("Unable to delete checklist from checklists: \(error)")
        }
    }

    func renameChecklist(title: String, at indexPath: IndexPath) {
        businessLogic.renameChecklist(title: title, at: indexPath.row) .then {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } .catch { error in
                print("Unable to rename checklist at \(indexPath.row): \(error)")
        }
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let addAction = #selector(insertNewChecklist(_:))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: addAction)

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem = addButton

        self.businessLogic.loadAllChecklists().then {
            self.tableView.reloadData()
        } .catch { error in
            print("Unable to load all checklists: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)
    }

    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "showDetail":
            guard let indexPath = self.tableView.indexPathForSelectedRow else { break }
            guard let detailViewController = segue.detailViewControllerFromDestination() else { break }

            detailViewController.businessLogic = businessLogic
            detailViewController.checklist = businessLogic.checklists[indexPath.row]

        default:
            break
        }
    }

}

extension MasterViewController /* UITableViewDataSource, UITableViewDelegate */ {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessLogic.checklists.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TextFieldTableViewCell
        let title = businessLogic.checklists[indexPath.row].title

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
        case .delete: deleteChecklist(at: indexPath)
        case .insert: insertNewChecklist(title: defaultTitle, at: indexPath)
        default:      break
        }
    }

}

extension MasterViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let title = textField.text else { return }
        guard let indexPath = textField.indexPathOfSuperTableViewCell else { return }
        guard title != businessLogic.checklists[indexPath.row].title else { return }

        renameChecklist(title: title, at: indexPath)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dissmissKeyboard(textField)
        return true
    }

}

extension UIStoryboardSegue {

    func detailViewControllerFromDestination() -> DetailViewController? {
        if let detailViewController = self.destination as? DetailViewController {
            return detailViewController
        }

        if let navigationController = self.destination as? UINavigationController,
            let detailViewController = navigationController.topViewController as? DetailViewController {
            return detailViewController
        }

        return nil
    }

}
