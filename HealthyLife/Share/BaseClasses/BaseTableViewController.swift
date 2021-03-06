//
//  BaseTableViewController.swift
//  HealthyLife
//
//  Created by Duy Nguyen on 25/8/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class BaseTableViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var dataArray = [] {
        didSet {
            reloadData()
        }
    }
    
    var shownIndexes = [NSIndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tableView == nil {
            let table = UITableView(frame: view.frame)
            table.tag = 999
            view.addSubview(table)
            tableView = view.viewWithTag(999) as! UITableView
            tableView.snp_makeConstraints(closure: { (make) in
                make.edges.equalTo(view)
            })
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = Configuration.Colors.lightGray
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(5, 0, 30, 0)
        
//       tableView.estimatedRowHeight = 130
//       tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if !shownIndexes.contains(indexPath) {
            
            shownIndexes.append(indexPath)
        } else {
            return
        }
        
        // 1. set the initial state of the cell
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.layer.transform = transform
        // 2. UIView Animation method to the final state of the cell
        UIView.animateWithDuration(0.5) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
    }
    
    func reloadData() {
        tableView.reloadData()
        hideLoading()
        if dataArray.count == 0 {
            let noResultLabel = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, 60))
            noResultLabel.font = UIFont.italicSystemFontOfSize(16)
            noResultLabel.text = "No results found."
            noResultLabel.textAlignment = .Center
            noResultLabel.textColor = UIColor.darkGrayColor()
            tableView.tableFooterView = noResultLabel
        } else {
            tableView.tableFooterView = nil
        }
    }
}
