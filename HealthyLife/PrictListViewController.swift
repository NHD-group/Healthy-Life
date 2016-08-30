//
//  PrictListViewController.swift
//  HealthyLife
//
//  Created by admin on 8/29/16.
//  Copyright © 2016 NHD Group. All rights reserved.
//

import UIKit
import Firebase

class PrictListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var uid = String()
    
    let currentUid = (FIRAuth.auth()?.currentUser?.uid)!
    
    var check = Bool()
    
    var priceListRef = FIRDatabaseReference()
    
    var priceList = [String]()
    
    @IBOutlet weak var addEditButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)

       
        priceListRef = FIRDatabase.database().reference().child("videosTrailer").child(uid).child("priceList")
        priceListRef.queryLimitedToLast(10).observeEventType(.Value, withBlock: { (snapshot) in
           
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    
                    
                    
                        let key = snap.key
                        let price = snap.value as! String
                        
                        // Items are returned chronologically, but it's more fun with the newest jokes first.
                        
                        self.priceList.insert(price, atIndex: 0)
                    
                }
                
            }
            self.tableView.reloadData()
            
            // Be sure that the tableView updates when there is new data.
            
           
            
        })
        
        if uid != currentUid {
            addEditButton.title = nil
            tableView.allowsMultipleSelectionDuringEditing = true
        } else {
            tableView.allowsMultipleSelectionDuringEditing = false
            
        }
        
        
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "check")
        
        
     
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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

    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        
        
//        videoRef.child(videos[indexPath.row].key as! String).removeValue()
        
        
    }

    

    @IBAction func addAction(sender: AnyObject) {
        onBack()
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priceList.count
    }
   
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("priceList") as! pricelistCellTableViewCell
       cell.price = priceList[indexPath.row]
        return cell
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
