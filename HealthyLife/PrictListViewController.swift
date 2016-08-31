//
//  PrictListViewController.swift
//  HealthyLife
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class PrictListViewController: BaseTableViewController {
    
    var uid = String()
    
    var check = Bool()
    
    var priceListRef = FIRDatabaseReference()
    
    @IBOutlet weak var addEditButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Price List"
       
        showLoading()
        priceListRef = FIRDatabase.database().reference().child("videosTrailer").child(uid).child("priceList")
        priceListRef.queryLimitedToLast(10).observeEventType(.Value, withBlock: { (snapshot) in
           
            var priceList = [String]()

            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
//                        let key = snap.key
                        let price = snap.value as! String
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        priceList.insert(price, atIndex: 0)
                    
                }
                
            }
            self.dataArray = priceList
            
        })
        
        if uid != DataService.currentUserID {
            addEditButton.title = nil
            tableView.allowsMultipleSelectionDuringEditing = true
        } else {
            tableView.allowsMultipleSelectionDuringEditing = false
            
        }
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "check")
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    @IBAction func addAction(sender: AnyObject) {
        onBack()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("priceList") as! pricelistCellTableViewCell
       cell.price = dataArray[indexPath.row] as! String
        return cell
        
    }

}
