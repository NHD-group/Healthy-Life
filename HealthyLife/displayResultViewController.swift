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

    var currentUserID = DataService.currentUserID
    
    var results = [Result]()
    
    var resultRef: FIRDatabaseReference!
    var isAlreadyLoaded = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if isAlreadyLoaded {
            return
        }
        isAlreadyLoaded = true
        
        let ref = DataService.BaseRef
        
        showLoading()
        
        resultRef = ref.child("users").child(currentUserID).child("results_journal")
        resultRef.queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            // The snapshot is a current look at our jokes data.
            
            print(snapshot.value)
            
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
        
        
        // Do any additional setup after loading the view.
    }
   
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
            resultRef.child(results[indexPath.row].resultKey).removeValue()
        
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("result") as! displayCellTableViewCell
        cell.result = results[indexPath.row]
        return cell
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if results.count < 3 {
            return
        }
        
        let isUp = (scrollView.panGestureRecognizer.translationInView(scrollView.superview).y > 0)
        delegate?.pageViewControllerIsMoving(isUp)
    }
    
}
