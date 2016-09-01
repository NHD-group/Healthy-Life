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
    var pricePerWeek: String?

    var check = Bool()
    
    var priceListRef = FIRDatabaseReference()
    var keys = [String]()
    
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
                        let key = snap.key
                        let price = snap.value as! String
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        self.keys.insert(key, atIndex: 0)
    
                        priceList.insert(price, atIndex: 0)
                    
                }
                
            }
            self.tableView.reloadData()
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
        priceListRef.child(keys[indexPath.row]).removeValue()
        
    }

    @IBAction func addAction(sender: AnyObject) {
        onBack()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("priceList") as! pricelistCellTableViewCell
        cell.price = dataArray[indexPath.row] as! String
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let price = dataArray[indexPath.row] as! String
        let vc = NHDPayPalViewController(nibName: String(NHDPayPalViewController), bundle: nil)
        vc.name = price
        vc.price = pricePerWeek!
        let navVC = BaseNavigationController(rootViewController: vc)
        Helper.getRootViewController()?.presentViewController(navVC, animated: true, completion: nil)

    }

}
