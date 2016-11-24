//
//  TableViewExtensions.swift
//  Checklist
//
//  Created by Jeffery Thomas on 11/19/16.
//  Copyright © 2016 JLT Source. All rights reserved.
//

import UIKit

extension UIView {

    var superTableView: UITableView? {
        return superview is UITableView ? superview as? UITableView : superview?.superTableView
    }

    var superTableViewCell: UITableViewCell? {
        return superview is UITableViewCell ? superview as? UITableViewCell : superview?.superTableViewCell
    }

    var indexPathOfSuperTableViewCell: IndexPath? {
        guard let tableView = superTableView, let cell = superTableViewCell else { return nil }
        return tableView.indexPath(for: cell)
    }
    
}
