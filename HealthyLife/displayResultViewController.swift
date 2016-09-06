//
//  displayResultViewController.swift
//  HealthyLife
//
//  Created by admin on 8/18/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase 

class displayResultViewController: BaseTableViewController {
    
    weak var delegate: BaseScroolViewDelegate?

    var currentUserID = ""
    
    var results = [Result]()
    var resultRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoading()

        var resultRef = DataService.BaseRef
        resultRef = resultRef.child("users").child(currentUserID).child("results_journal")
        resultRef.queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in

            self.results = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our jokes array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let result = Result(key: key, dictionary: postDictionary)
                        
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.results.insert(result, atIndex: 0)
                    }
                }
                
            }
            
            // Be sure that the tableView updates when there is new data.
            
            self.dataArray = self.results
        })
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 100, 0)
        tableView.rowHeight = 140
        
        tableView.registerNib(UINib(nibName: String(displayCellTableViewCell), bundle: nil), forCellReuseIdentifier: String(displayCellTableViewCell))
    }
   
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        resultRef.child(results[indexPath.row].resultKey).removeValue()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(displayCellTableViewCell)) as! displayCellTableViewCell
        cell.result = results[indexPath.row]
        return cell
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let isUp = (scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0)
        delegate?.pageViewControllerIsMoving(isUp)
    }
    
}
